/**
 * seedFirstAdmin
 *
 * HTTPS Callable function. One-time bootstrap to create the very first admin account.
 *
 * SECURITY: This function is protected by a shared secret (`SEED_SECRET`) stored in
 * Firebase environment config / Secret Manager. After seeding, either:
 *   a) Delete this function and redeploy, OR
 *   b) Set SEED_USED=true in config so subsequent calls are rejected.
 *
 * The caller must provide the correct `seedSecret` in the request body.
 *
 * Usage:
 *   const seedFirstAdmin = httpsCallable(functions, 'seedFirstAdmin');
 *   await seedFirstAdmin({ targetUid: 'uid', seedSecret: 'your-secret' });
 *
 * Set the secret in Firebase:
 *   firebase functions:config:set smart_pill_dispenser.seed_secret="YOUR_RANDOM_SECRET"
 *   firebase functions:config:set smart_pill_dispenser.seed_used="false"
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

interface SeedFirstAdminRequest {
  targetUid: string;
  seedSecret: string;
}

export const seedFirstAdmin = functions.https.onCall(
  async (data: SeedFirstAdminRequest, context) => {
    // 1. Check if the seed secret env var is configured.
    const config = functions.config();
    const expectedSecret: string | undefined = config.smart_pill_dispenser?.seed_secret || config.medsync?.seed_secret;
    const seedUsed: string | undefined = config.smart_pill_dispenser?.seed_used || config.medsync?.seed_used;

    if (!expectedSecret) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Seed secret is not configured. Set smart_pill_dispenser.seed_secret in Firebase config."
      );
    }

    // 2. Reject if already used.
    if (seedUsed === "true") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "First admin has already been seeded. This function is disabled."
      );
    }

    // 3. Validate the provided secret.
    const { targetUid, seedSecret } = data;
    if (!seedSecret || seedSecret !== expectedSecret) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Invalid seed secret."
      );
    }

    if (!targetUid || typeof targetUid !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "targetUid must be a non-empty string."
      );
    }

    try {
      // 4. Check that the target UID exists in Firebase Auth.
      const userRecord = await admin.auth().getUser(targetUid);

      // 5. Set the admin custom claim.
      await admin.auth().setCustomUserClaims(targetUid, { admin: true });

      // 6. Create the adminUsers directory entry.
      await db.collection("adminUsers").doc(targetUid).set({
        name: userRecord.displayName ?? "",
        email: userRecord.email ?? "",
        grantedAt: admin.firestore.FieldValue.serverTimestamp(),
        grantedBy: "seed",
      });

      // 7. Log the action.
      await db.collection("systemLogs").add({
        type: "login",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        deviceId: null,
        patientId: null,
        userId: targetUid,
        details: `First admin seeded: ${userRecord.email}. UID: ${targetUid}.`,
      });

      functions.logger.info(`[seedFirstAdmin] Admin claim set for first admin UID: ${targetUid}.`);

      return {
        success: true,
        message: `Admin claim granted to ${userRecord.email}. IMPORTANT: Disable this function after seeding.`,
      };
    } catch (error) {
      functions.logger.error("[seedFirstAdmin] Error:", error);
      throw new functions.https.HttpsError("internal", "Failed to seed first admin.");
    }
  }
);
