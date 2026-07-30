/**
 * firmwareAction
 *
 * HTTPS Callable function. Performs admin-only firmware management actions:
 *   - "deploy": Marks a firmwareUpdate as the active version and queues OTA push
 *   - "rollback": Marks a firmwareUpdate as "rolled_back" and queues rollback command
 *
 * Authorization: Requires `admin: true` custom claim.
 *
 * Both actions write a pendingFirmwareCommand to the target device(s) that the
 * firmware OTA client polls and executes. If no deviceId is specified, the command
 * is queued for ALL online devices (fleet-wide update).
 *
 * All actions are logged to systemLogs.
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

type FirmwareActionType = "deploy" | "rollback";

interface FirmwareActionRequest {
  updateId: string;       // The firmwareUpdates/{updateId} document ID
  action: FirmwareActionType;
  deviceId?: string;      // Optional: target a specific device; omit for fleet-wide
}

export const firmwareAction = functions.https.onCall(
  async (data: FirmwareActionRequest, context) => {
    // 1. Verify authentication and admin claim.
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
    }
    if (!context.auth.token.admin) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Admin privileges required to perform firmware actions."
      );
    }

    const { updateId, action, deviceId } = data;
    const callerUid = context.auth.uid;

    // 2. Validate inputs.
    if (!updateId || typeof updateId !== "string") {
      throw new functions.https.HttpsError("invalid-argument", "updateId is required.");
    }
    if (action !== "deploy" && action !== "rollback") {
      throw new functions.https.HttpsError("invalid-argument", `action must be "deploy" or "rollback".`);
    }

    // 3. Verify the firmware update document exists.
    const updateRef = db.collection("firmwareUpdates").doc(updateId);
    const updateDoc = await updateRef.get();
    if (!updateDoc.exists) {
      throw new functions.https.HttpsError("not-found", `Firmware update ${updateId} not found.`);
    }

    const updateData = updateDoc.data()!;
    const version: string = updateData.version;

    // 4. Validate state transitions.
    if (action === "rollback" && updateData.status !== "available") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        `Cannot roll back a firmware update with status "${updateData.status}".`
      );
    }

    functions.logger.info(
      `[firmwareAction] Admin ${callerUid} performing "${action}" on firmware ${updateId} (v${version}). ` +
      `Target device: ${deviceId ?? "all"}.`
    );

    try {
      const batch = db.batch();

      // 5. Update the firmware record status.
      if (action === "rollback") {
        batch.update(updateRef, { status: "rolled_back" });
      }
      // For deploy, status stays "available" — the firmware confirms deployment.

      // 6. Queue the command on the target device(s).
      const command = {
        type: action === "deploy" ? "firmware_update" : "firmware_rollback",
        updateId,
        version,
        issuedAt: admin.firestore.FieldValue.serverTimestamp(),
        issuedBy: callerUid,
      };

      if (deviceId) {
        // Target a single device.
        const deviceRef = db.collection("devices").doc(deviceId);
        const deviceDoc = await deviceRef.get();
        if (!deviceDoc.exists) {
          throw new functions.https.HttpsError("not-found", `Device ${deviceId} not found.`);
        }
        batch.update(deviceRef, { pendingFirmwareCommand: command });
      } else {
        // Fleet-wide: queue for all online devices.
        const devicesSnapshot = await db
          .collection("devices")
          .where("status", "==", "online")
          .get();

        for (const deviceDoc of devicesSnapshot.docs) {
          batch.update(deviceDoc.ref, { pendingFirmwareCommand: command });
        }

        functions.logger.info(
          `[firmwareAction] Fleet-wide ${action}: queued for ${devicesSnapshot.size} online devices.`
        );
      }

      // 7. Log to systemLogs.
      const logRef = db.collection("systemLogs").doc();
      batch.set(logRef, {
        type: "firmwareUpdate",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        deviceId: deviceId ?? null,
        patientId: null,
        userId: callerUid,
        details: `Admin ${callerUid} performed firmware ${action} for update ${updateId} (v${version}). ` +
                 `Target: ${deviceId ?? "all online devices"}.`,
      });

      await batch.commit();

      functions.logger.info(`[firmwareAction] "${action}" queued successfully for update ${updateId}.`);
      return {
        success: true,
        message: `Firmware ${action} queued successfully for version ${version}.`,
        targetCount: deviceId ? 1 : undefined,
      };
    } catch (error) {
      if (error instanceof functions.https.HttpsError) throw error;
      functions.logger.error("[firmwareAction] Error:", error);
      throw new functions.https.HttpsError("internal", `Failed to perform firmware action: ${action}.`);
    }
  }
);
