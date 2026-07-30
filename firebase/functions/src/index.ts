/**
 * MedSync Cloud Functions — index.ts
 *
 * Exports all Cloud Functions for the MedSync medication dispensing system.
 * Admin authentication uses Firebase Custom Claims (admin: true) set server-side.
 * No client app should ever write directly to hardware-originated collections.
 */

import * as admin from "firebase-admin";

admin.initializeApp();

export { onDispenseEventMissed } from "./dispense/onDispenseEventMissed";
export { computeAdherence } from "./dispense/computeAdherence";
export { onEmergencyRequest } from "./emergency/onEmergencyRequest";
export { setAdminClaim } from "./admin/setAdminClaim";
export { seedFirstAdmin } from "./admin/seedFirstAdmin";
export { deviceAction } from "./admin/deviceAction";
export { firmwareAction } from "./admin/firmwareAction";
