/**
 * onEmergencyRequest
 *
 * Triggered when a new emergencyRequests/{requestId} document is created.
 * Sends an FCM push notification to the appropriate party:
 *   - Patient-initiated → notify all linked caregivers
 *   - Caregiver-initiated → notify the patient
 *
 * The actual dispense is handled by the firmware listening to this collection.
 * The Cloud Function is responsible for notification only.
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();
const messaging = admin.messaging();

export const onEmergencyRequest = functions.firestore
  .document("emergencyRequests/{requestId}")
  .onCreate(async (snapshot, context) => {
    const requestId = context.params.requestId;
    const request = snapshot.data();

    const { patientId, initiatedBy, requestedBy } = request;

    if (!patientId || !initiatedBy) {
      functions.logger.warn(`[onEmergencyRequest] Missing fields on request ${requestId}.`);
      return null;
    }

    const patientDoc = await db.collection("patients").doc(patientId).get();
    if (!patientDoc.exists) {
      functions.logger.warn(`[onEmergencyRequest] Patient ${patientId} not found.`);
      return null;
    }

    const patientName = patientDoc.data()!.name ?? "Unknown Patient";

    if (initiatedBy === "patient") {
      // Notify all linked caregivers.
      await _notifyCaregivers(patientDoc, patientName, requestId, request);
    } else if (initiatedBy === "caregiver") {
      // Notify the patient.
      await _notifyPatient(patientId, patientName, requestId, request, requestedBy);
    }

    // Write a system log entry.
    await db.collection("systemLogs").add({
      type: "emergencyDispense",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      deviceId: patientDoc.data()!.deviceId ?? null,
      patientId,
      userId: requestedBy ?? null,
      details: `Emergency dispense requested by ${initiatedBy}. Request ID: ${requestId}. Compartment: ${request.compartment ?? "N/A"}.`,
    });

    return null;
  });

async function _notifyCaregivers(
  patientDoc: FirebaseFirestore.DocumentSnapshot,
  patientName: string,
  requestId: string,
  request: FirebaseFirestore.DocumentData
): Promise<void> {
  const caregiverIds: string[] = patientDoc.data()!.caregiverIds ?? [];
  if (caregiverIds.length === 0) return;

  const caregiverDocs = await Promise.all(
    caregiverIds.map((uid) => db.collection("users").doc(uid).get())
  );
  const tokens = caregiverDocs
    .filter((d) => d.exists && d.data()!.fcmToken)
    .map((d) => d.data()!.fcmToken as string);

  if (tokens.length === 0) return;

  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: {
      title: "🚨 Emergency Dispense Requested",
      body: `${patientName} is requesting an emergency medication dispense.`,
    },
    data: {
      type: "emergency_request",
      requestId,
      patientId: patientDoc.id,
    },
    android: {
      priority: "high",
      notification: { channelId: "emergency_alerts", priority: "max" },
    },
  };

  const response = await messaging.sendEachForMulticast(message);
  functions.logger.info(
    `[onEmergencyRequest] Caregiver FCM: ${response.successCount} success, ${response.failureCount} failure.`
  );
}

async function _notifyPatient(
  patientId: string,
  patientName: string,
  requestId: string,
  request: FirebaseFirestore.DocumentData,
  requestedBy: string
): Promise<void> {
  const patientUserDoc = await db.collection("users").doc(patientId).get();
  const token = patientUserDoc.exists ? patientUserDoc.data()!.fcmToken : null;
  if (!token) return;

  // Get caregiver name for the notification.
  const caregiverDoc = await db.collection("users").doc(requestedBy).get();
  const caregiverName = caregiverDoc.exists
    ? (caregiverDoc.data()!.name ?? "Your caregiver")
    : "Your caregiver";

  const compartment = request.compartment ? `(Compartment ${request.compartment})` : "";

  const message: admin.messaging.Message = {
    token,
    notification: {
      title: "💊 Medication Being Dispensed",
      body: `${caregiverName} has initiated an emergency dispense for you ${compartment}.`.trim(),
    },
    data: {
      type: "emergency_dispensed",
      requestId,
      patientId,
    },
    android: {
      priority: "high",
      notification: { channelId: "medication_alerts", priority: "high" },
    },
  };

  await messaging.send(message);
  functions.logger.info(`[onEmergencyRequest] Patient FCM sent to ${patientId}.`);
}
