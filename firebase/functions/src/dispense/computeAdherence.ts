/**
 * computeAdherence
 *
 * Triggered on any write to dispenseEvents/{eventId}.
 * Recalculates the rolling 30-day adherence percentage for the affected patient
 * and updates `patients/{patientId}.adherencePercent`.
 *
 * Formula: (taken events in last 30 days) / (taken + missed events in last 30 days) * 100
 * "manual" and "blocked" events are excluded from both numerator and denominator
 * since they represent special states rather than scheduled dose outcomes.
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export const computeAdherence = functions.firestore
  .document("dispenseEvents/{eventId}")
  .onWrite(async (change, context) => {
    // Get the patient ID from either the new or old document.
    const newData = change.after.exists ? change.after.data() : null;
    const oldData = change.before.exists ? change.before.data() : null;
    const patientId: string | undefined = newData?.patientId ?? oldData?.patientId;

    if (!patientId) {
      functions.logger.warn("[computeAdherence] No patientId found on event, skipping.");
      return null;
    }

    // Only recalculate when the status field changes or on create/delete.
    const statusChanged = newData?.status !== oldData?.status;
    const isCreateOrDelete = !change.before.exists || !change.after.exists;
    if (!statusChanged && !isCreateOrDelete) {
      return null;
    }

    // Query the last 30 days of dispense events for this patient.
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const thirtyDaysAgoTimestamp = admin.firestore.Timestamp.fromDate(thirtyDaysAgo);

    const eventsSnapshot = await db
      .collection("dispenseEvents")
      .where("patientId", "==", patientId)
      .where("scheduledTime", ">=", thirtyDaysAgoTimestamp)
      .get();

    let taken = 0;
    let missed = 0;

    for (const doc of eventsSnapshot.docs) {
      const status = doc.data().status as string;
      if (status === "taken") taken++;
      else if (status === "missed") missed++;
      // "manual" and "blocked" are intentionally excluded.
    }

    const total = taken + missed;
    const adherencePercent = total === 0 ? 100 : Math.round((taken / total) * 100);

    functions.logger.info(
      `[computeAdherence] Patient ${patientId}: ${taken} taken, ${missed} missed ` +
      `over 30 days → ${adherencePercent}% adherence.`
    );

    await db.collection("patients").doc(patientId).update({
      adherencePercent,
    });

    return null;
  });
