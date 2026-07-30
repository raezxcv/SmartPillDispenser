/**
 * setAdminClaim
 *
 * HTTPS Callable function. Sets the `admin: true` custom claim on a target user.
 *
 * Authorization: Only existing admins (users who already have `admin: true` custom claim)
 * may call this function. This prevents privilege escalation from non-admin accounts.
 *
 * Usage (from Admin Dashboard):
 *   const setAdminClaim = httpsCallable(functions, 'setAdminClaim');
 *   await setAdminClaim({ targetUid: 'uid-to-promote', revoke: false });
 *
 * To revoke admin access, pass `revoke: true`.
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

interface SetAdminClaimRequest {
  targetUid: string;
  revoke?: boolean;
}

export const setAdminClaim = functions.https.onCall(
  async (data: SetAdminClaimRequest, context) => {
    // 1. Verify the caller is authenticated.
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be signed in to perform this action."
      );
    }

    // 2. Verify the caller has the admin custom claim.
    if (!context.auth.token.admin) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can grant or revoke admin access."
      );
    }

    // 3. Validate the request payload.
    const { targetUid, revoke = false } = data;
    if (!targetUid || typeof targetUid !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "targetUid must be a non-empty string."
      );
    }

    // Prevent self-revocation (lockout prevention).
    if (revoke && targetUid === context.auth.uid) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "You cannot revoke your own admin access."
      );
    }

    try {
      // 4. Set or revoke the custom claim.
      await admin.auth().setCustomUserClaims(targetUid, {
        admin: !revoke,
      });

      // 5. Update the adminUsers directory in Firestore.
      const adminUsersRef = db.collection("adminUsers").doc(targetUid);
      if (revoke) {
        await adminUsersRef.delete();
      } else {
        const userRecord = await admin.auth().getUser(targetUid);
        await adminUsersRef.set({
          name: userRecord.displayName ?? "",
          email: userRecord.email ?? "",
          grantedAt: admin.firestore.FieldValue.serverTimestamp(),
          grantedBy: context.auth.uid,
        });
      }

      // 6. Log the action.
      await db.collection("systemLogs").add({
        type: "login", // closest existing type; extend enum if needed
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        deviceId: null,
        patientId: null,
        userId: context.auth.uid,
        details: `Admin claim ${revoke ? "revoked from" : "granted to"} user ${targetUid} by ${context.auth.uid}.`,
      });

      functions.logger.info(
        `[setAdminClaim] Admin claim ${revoke ? "revoked from" : "set for"} UID: ${targetUid} by ${context.auth.uid}.`
      );

      return { success: true, message: `Admin claim ${revoke ? "revoked" : "granted"} successfully.` };
    } catch (error) {
      functions.logger.error("[setAdminClaim] Error:", error);
      throw new functions.https.HttpsError("internal", "Failed to update admin claim.");
    }
  }
);
