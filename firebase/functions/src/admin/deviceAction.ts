/**
 * deviceAction
 *
 * HTTPS Callable function. Performs admin-only device actions:
 *   - "restart": Sends a restart command to the device
 *   - "disable": Marks device status as "offline" and prevents future commands
 *   - "remove": Unlinks device from patient and removes from devices collection
 *   - "reassign": Reassigns device to a different patient
 *
 * Authorization: Requires `admin: true` custom claim.
 *
 * All actions write a pendingCommand to the device document that the firmware
 * polls and executes. The firmware clears the pendingCommand once executed.
 *
 * All actions are logged to systemLogs regardless of outcome.
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

type DeviceActionType = "restart" | "disable" | "remove" | "reassign";

interface DeviceActionRequest {
  deviceId: string;
  action: DeviceActionType;
  newPatientId?: string; // Required for "reassign"
}

export const deviceAction = functions.https.onCall(
  async (data: DeviceActionRequest, context) => {
    // 1. Verify authentication and admin claim.
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }
    if (!context.auth.token.admin) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Admin privileges required to perform device actions."
      );
    }

    const { deviceId, action, newPatientId } = data;

    // 2. Validate inputs.
    if (!deviceId || typeof deviceId !== "string") {
      throw new functions.https.HttpsError("invalid-argument", "deviceId is required.");
    }
    const validActions: DeviceActionType[] = ["restart", "disable", "remove", "reassign"];
    if (!validActions.includes(action)) {
      throw new functions.https.HttpsError("invalid-argument", `action must be one of: ${validActions.join(", ")}.`);
    }
    if (action === "reassign" && !newPatientId) {
      throw new functions.https.HttpsError("invalid-argument", "newPatientId is required for reassign action.");
    }

    // 3. Verify the device exists.
    const deviceRef = db.collection("devices").doc(deviceId);
    const deviceDoc = await deviceRef.get();
    if (!deviceDoc.exists) {
      throw new functions.https.HttpsError("not-found", `Device ${deviceId} not found.`);
    }

    const deviceData = deviceDoc.data()!;
    const callerUid = context.auth.uid;

    functions.logger.info(
      `[deviceAction] Admin ${callerUid} performing action "${action}" on device ${deviceId}.`
    );

    try {
      const batch = db.batch();
      let logDetails = "";

      switch (action) {
        case "restart":
          // Write a pendingCommand that the firmware polls.
          batch.update(deviceRef, {
            "pendingCommand.type": "restart",
            "pendingCommand.issuedAt": admin.firestore.FieldValue.serverTimestamp(),
            "pendingCommand.issuedBy": callerUid,
          });
          logDetails = `Admin ${callerUid} issued restart command to device ${deviceId}.`;
          break;

        case "disable":
          batch.update(deviceRef, {
            status: "offline",
            "pendingCommand.type": "disable",
            "pendingCommand.issuedAt": admin.firestore.FieldValue.serverTimestamp(),
            "pendingCommand.issuedBy": callerUid,
          });
          logDetails = `Admin ${callerUid} disabled device ${deviceId}.`;
          break;

        case "remove": {
          // Unlink from patient, then delete device doc.
          const patientId = deviceData.patientId;
          if (patientId) {
            const patientRef = db.collection("patients").doc(patientId);
            batch.update(patientRef, { deviceId: admin.firestore.FieldValue.delete() });
          }
          batch.delete(deviceRef);
          logDetails = `Admin ${callerUid} removed device ${deviceId} (was linked to patient ${deviceData.patientId ?? "none"}).`;
          break;
        }

        case "reassign": {
          // Verify new patient exists.
          const newPatientRef = db.collection("patients").doc(newPatientId!);
          const newPatientDoc = await newPatientRef.get();
          if (!newPatientDoc.exists) {
            throw new functions.https.HttpsError("not-found", `Patient ${newPatientId} not found.`);
          }

          // Remove device from old patient.
          if (deviceData.patientId) {
            batch.update(db.collection("patients").doc(deviceData.patientId), {
              deviceId: admin.firestore.FieldValue.delete(),
            });
          }

          // Assign to new patient.
          batch.update(deviceRef, { patientId: newPatientId });
          batch.update(newPatientRef, { deviceId });
          logDetails = `Admin ${callerUid} reassigned device ${deviceId} from patient ${deviceData.patientId ?? "none"} to ${newPatientId}.`;
          break;
        }
      }

      // Log to systemLogs.
      const logRef = db.collection("systemLogs").doc();
      batch.set(logRef, {
        type: "deviceConnect",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        deviceId,
        patientId: deviceData.patientId ?? null,
        userId: callerUid,
        details: logDetails,
      });

      await batch.commit();

      functions.logger.info(`[deviceAction] Action "${action}" completed for device ${deviceId}.`);
      return { success: true, message: `Device action "${action}" completed successfully.` };
    } catch (error) {
      if (error instanceof functions.https.HttpsError) throw error;
      functions.logger.error("[deviceAction] Error:", error);
      throw new functions.https.HttpsError("internal", `Failed to perform device action: ${action}.`);
    }
  }
);
