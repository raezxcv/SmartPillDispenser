/**
 * onDispenseEventMissed
 *
 * Triggered when a new dispenseEvent document is created by the firmware.
 * Schedules a check 20 minutes after `scheduledTime`. If the event is still
 * not "taken" at that point:
 *   1. Sets the event status to "missed"
 *   2. Sets the device trayStatus to "blocked"
 *   3. Writes a systemLog entry
 *   4. Sends an FCM push notification to all linked caregivers
 *
 * NOTE: The 20-minute timer is implemented using a scheduled retry pattern
 * via Cloud Tasks / the Firebase Admin SDK's scheduled function approach.
 * For simplicity in this implementation, we use a Firestore onCreate trigger
 * combined with a setTimeout-equivalent via Cloud Tasks enqueue.
 * In production, replace with Cloud Tasks for reliable delivery.
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();
const messaging = admin.messaging();

const MISSED_DOSE_WINDOW_MS = 20 * 60 * 1000; // 20 minutes

export const onDispenseEventMissed = functions.firestore
  .document("dispenseEvents/{eventId}")
  .onCreate(async (snapshot, context) => {
    const eventId = context.params.eventId;
    const event = snapshot.data();

    // Only watch events that start in a "waiting" or undefined state.
    // "manual", "blocked" events created retroactively don't need a timer.
    if (event.status === "taken" || event.status === "missed" || event.status === "blocked") {
      functions.logger.info(`[onDispenseEventMissed] Event ${eventId} already terminal, skipping.`);
      return null;
    }

    const scheduledTime: FirebaseFirestore.Timestamp = event.scheduledTime;
    if (!scheduledTime) {
      functions.logger.warn(`[onDispenseEventMissed] Event ${eventId} has no scheduledTime.`);
      return null;
    }

    const now = Date.now();
    const scheduledMs = scheduledTime.toMillis();
    const windowEnd = scheduledMs + MISSED_DOSE_WINDOW_MS;
    const delay = Math.max(0, windowEnd - now);

    functions.logger.info(
      `[onDispenseEventMissed] Event ${eventId} scheduled at ${scheduledTime.toDate().toISOString()}. ` +
      `Checking for missed dose in ${Math.round(delay / 1000)}s.`
    );

    // Wait for the 20-minute window to expire.
    // In a production system, use Cloud Tasks instead of setTimeout for reliability.
    await new Promise((resolve) => setTimeout(resolve, delay));

    // Re-read the event to check current status (it may have been taken during the delay).
    const freshSnapshot = await db.collection("dispenseEvents").doc(eventId).get();
    if (!freshSnapshot.exists) {
      functions.logger.warn(`[onDispenseEventMissed] Event ${eventId} was deleted.`);
      return null;
    }

    const freshEvent = freshSnapshot.data()!;
    if (freshEvent.status === "taken") {
      functions.logger.info(`[onDispenseEventMissed] Event ${eventId} was taken — no action needed.`);
      return null;
    }

    // Mark as missed and block the tray in a single batch.
    const batch = db.batch();

    // Update the dispense event status.
    batch.update(db.collection("dispenseEvents").doc(eventId), {
      status: "missed",
    });

    // Block the device tray.
    if (event.deviceId) {
      batch.update(db.collection("devices").doc(event.deviceId), {
        trayStatus: "blocked",
        trayBlockedSince: admin.firestore.FieldValue.serverTimestamp(),
        trayBlockedReason: eventId,
      });
    } else {
      // Look up deviceId from the patient record.
      const patientDoc = await db.collection("patients").doc(event.patientId).get();
      if (patientDoc.exists) {
        const deviceId = patientDoc.data()!.deviceId;
        if (deviceId) {
          batch.update(db.collection("devices").doc(deviceId), {
            trayStatus: "blocked",
            trayBlockedSince: admin.firestore.FieldValue.serverTimestamp(),
            trayBlockedReason: eventId,
          });
        }
      }
    }

    // Write a system log entry.
    const logRef = db.collection("systemLogs").doc();
    batch.set(logRef, {
      type: "missedDose",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      deviceId: event.deviceId ?? null,
      patientId: event.patientId ?? null,
      userId: null,
      details: `Missed dose for schedule ${event.scheduleId} at compartment ${event.compartment}. Event ID: ${eventId}.`,
    });

    await batch.commit();
    functions.logger.info(`[onDispenseEventMissed] Event ${eventId} marked missed, tray blocked.`);

    // Send FCM to all linked caregivers.
    await _notifyCaregiversOfMissedDose(event.patientId, event, eventId);

    return null;
  });

/**
 * Fetch linked caregivers for the given patientId and send them an FCM alert.
 */
async function _notifyCaregiversOfMissedDose(
  patientId: string,
  event: FirebaseFirestore.DocumentData,
  eventId: string
): Promise<void> {
  const patientDoc = await db.collection("patients").doc(patientId).get();
  if (!patientDoc.exists) return;

  const caregiverIds: string[] = patientDoc.data()!.caregiverIds ?? [];
  if (caregiverIds.length === 0) return;

  // Fetch FCM tokens for all caregivers.
  const caregiverDocs = await Promise.all(
    caregiverIds.map((uid) => db.collection("users").doc(uid).get())
  );

  const tokens: string[] = caregiverDocs
    .filter((d) => d.exists && d.data()!.fcmToken)
    .map((d) => d.data()!.fcmToken as string);

  if (tokens.length === 0) return;

  const patientName = patientDoc.data()!.name ?? "your patient";
  const medicineLabel = event.medicineName
    ? `${event.medicineName} (${event.compartment})`
    : `Compartment ${event.compartment}`;

  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: {
      title: "⚠️ Missed Dose Alert",
      body: `${patientName} missed their ${medicineLabel} dose. The tray is now blocked.`,
    },
    data: {
      type: "missed_dose",
      eventId,
      patientId,
      compartment: event.compartment ?? "",
    },
    android: {
      priority: "high",
      notification: {
        channelId: "missed_dose_alerts",
        priority: "max",
        defaultSound: true,
        defaultVibrateTimings: true,
      },
    },
  };

  const response = await messaging.sendEachForMulticast(message);
  functions.logger.info(
    `[onDispenseEventMissed] FCM sent: ${response.successCount} success, ${response.failureCount} failure.`
  );
}
