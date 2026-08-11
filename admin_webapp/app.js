/**
 * Smart Pill Dispenser — Admin Web App v2.0
 * Firebase Auth + Firestore + Chart.js dashboard
 *
 * Firebase project: smart-pill-dispenser-baa02
 */

import { initializeApp }
  from "https://www.gstatic.com/firebasejs/10.14.0/firebase-app.js";
import {
  getAuth,
  onAuthStateChanged,
  signOut,
  sendPasswordResetEmail,
} from "https://www.gstatic.com/firebasejs/10.14.0/firebase-auth.js";
import {
  getFirestore,
  collection,
  getDocs,
  doc,
  getDoc,
  updateDoc,
  query,
  orderBy,
  limit,
  where,
  onSnapshot,
  serverTimestamp,
  addDoc,
  Timestamp,
} from "https://www.gstatic.com/firebasejs/10.14.0/firebase-firestore.js";

// ─── Firebase Config ───────────────────────────────────────────────────────────
const firebaseConfig = {
  apiKey:            "AIzaSyDfPRQ-uUKxFcVa5M1hkkKYNWZ9e4Ef4v4",
  authDomain:        "smart-pill-dispenser-baa02.firebaseapp.com",
  projectId:         "smart-pill-dispenser-baa02",
  storageBucket:     "smart-pill-dispenser-baa02.firebasestorage.app",
  messagingSenderId: "757028886151",
  appId:             "1:757028886151:android:d7e93028db8ad37babca22",
};

const app  = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db   = getFirestore(app);

// ─── Chart.js (dynamic import) ────────────────────────────────────────────────
let Chart;
(async () => {
  const mod = await import("https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js");
  Chart = mod.default ?? window.Chart;
})();

// ─── Utility helpers ──────────────────────────────────────────────────────────
const $ = (id) => document.getElementById(id);

function showToast(msg, type = "default") {
  const toast = $("toast");
  toast.textContent = msg;
  toast.className = `toast show${type === "success" ? " toast-success" : type === "error" ? " toast-error" : ""}`;
  clearTimeout(toast._timer);
  toast._timer = setTimeout(() => toast.classList.remove("show"), 3500);
}

function formatDate(ts) {
  if (!ts) return "—";
  const d = ts.toDate ? ts.toDate() : (ts.seconds ? new Date(ts.seconds * 1000) : new Date(ts));
  return d.toLocaleDateString("en-PH", { year: "numeric", month: "short", day: "numeric" });
}

function formatDateTime(ts) {
  if (!ts) return "—";
  const d = ts.toDate ? ts.toDate() : (ts.seconds ? new Date(ts.seconds * 1000) : new Date(ts));
  return d.toLocaleString("en-PH");
}

function roleBadge(role) {
  const map = {
    user:      ["badge-green", "User"],
    patient:   ["badge-green", "Patient"],
    caregiver: ["badge-blue",  "Caregiver"],
    admin:     ["badge-red",   "Admin"],
  };
  const [cls, label] = map[role] || ["badge-gray", role || "Unknown"];
  return `<span class="badge ${cls}">${label}</span>`;
}

function statusBadge(status) {
  const map = { active: "badge-green", suspended: "badge-red", pending: "badge-amber" };
  const cls = map[status] || "badge-gray";
  return `<span class="badge ${cls}">${status || "unknown"}</span>`;
}

function severityBadge(sev) {
  const map = { high: "badge-red", medium: "badge-amber", low: "badge-blue", info: "badge-gray" };
  const cls = map[(sev || "").toLowerCase()] || "badge-gray";
  return `<span class="badge ${cls}">${sev || "—"}</span>`;
}

function alertStatusBadge(status) {
  const map = { active: "badge-amber", resolved: "badge-green", dismissed: "badge-gray" };
  const cls = map[status] || "badge-gray";
  return `<span class="badge ${cls}">${status || "active"}</span>`;
}

function adherenceBar(pct = 0) {
  const color = pct >= 80 ? "#10B981" : pct >= 50 ? "#F59E0B" : "#EF4444";
  return `
    <div class="adh-bar-wrap">
      <div class="adh-bar">
        <div class="adh-fill" style="width:${pct}%; background:${color};"></div>
      </div>
      <span class="adh-pct">${pct}%</span>
    </div>`;
}

function faceEnrollBadge(status) {
  const map = {
    enrolled:    ["badge-green", "Enrolled"],
    pending:     ["badge-amber", "Pending"],
    not_started: ["badge-gray",  "Not Started"],
  };
  const [cls, label] = map[status] || ["badge-gray", status || "Unknown"];
  return `<span class="badge ${cls}">${label}</span>`;
}

// ─── Auth guard ───────────────────────────────────────────────────────────────
let currentAdmin = null;

onAuthStateChanged(auth, async (user) => {
  if (!user) { window.location.href = "index.html"; return; }

  // Verify admin role in Firestore
  const userDoc = await getDoc(doc(db, "users", user.uid));
  if (!userDoc.exists() || userDoc.data().role !== "admin") {
    await signOut(auth);
    window.location.href = "index.html";
    return;
  }

  currentAdmin = { uid: user.uid, email: user.email, ...userDoc.data() };
  const name    = currentAdmin.name || user.email || "Admin";
  const initial = name.charAt(0).toUpperCase();

  // Populate identity in UI
  if ($("admin-name-label"))    $("admin-name-label").textContent    = name;
  if ($("admin-avatar-initials")) $("admin-avatar-initials").textContent = initial;
  if ($("topbar-avatar"))       $("topbar-avatar").textContent       = initial;
  if ($("settings-avatar"))     $("settings-avatar").textContent     = initial;
  if ($("settings-name"))       $("settings-name").textContent       = name;
  if ($("settings-email"))      $("settings-email").textContent      = user.email || "—";
  if ($("settings-name-input")) $("settings-name-input").value       = name;

  // Load all data
  loadUsers();
  loadDevices();
  loadAlerts();
  startAuditLogListener();
  setTimeout(loadOverviewCharts, 800); // wait for Chart.js import
});

// ─── Sign Out ─────────────────────────────────────────────────────────────────
$("signout-btn")?.addEventListener("click", async () => {
  await logAction("sign_out", "session", "success");
  await signOut(auth);
  window.location.href = "index.html";
});

// ═══════════════════════════════════════════════════════════════════════════════
// CONFIRM MODAL
// ═══════════════════════════════════════════════════════════════════════════════

let _confirmResolve = null;

function openConfirm({ title, body, okLabel = "Confirm", danger = true }) {
  $("confirm-title").textContent = title;
  $("confirm-body").textContent  = body;
  $("confirm-ok-btn").textContent = okLabel;
  $("confirm-ok-btn").className  = `btn-modal-confirm${danger ? "" : " green"}`;
  $("confirm-icon").textContent  = danger ? "⚠️" : "✅";
  $("modal-confirm").classList.add("open");

  return new Promise((resolve) => {
    _confirmResolve = resolve;
  });
}

function closeConfirm(result) {
  $("modal-confirm").classList.remove("open");
  if (_confirmResolve) { _confirmResolve(result); _confirmResolve = null; }
}

$("confirm-cancel-btn").addEventListener("click", () => closeConfirm(false));
$("confirm-ok-btn").addEventListener("click",     () => closeConfirm(true));
$("modal-confirm").addEventListener("click", (e) => {
  if (e.target === $("modal-confirm")) closeConfirm(false);
});

// ═══════════════════════════════════════════════════════════════════════════════
// USERS
// ═══════════════════════════════════════════════════════════════════════════════

let allUsers = [];
const USERS_PER_PAGE = 20;
let usersPage = 0;
let filteredUsers = [];

async function loadUsers() {
  try {
    const snap = await getDocs(
      query(collection(db, "users"), orderBy("createdAt", "desc"))
    );
    allUsers = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

    const nonAdmins = allUsers.filter((u) => u.role !== "admin");

    // KPI
    if ($("kpi-users"))     $("kpi-users").textContent = nonAdmins.length;
    if ($("kpi-users-sub")) $("kpi-users-sub").textContent = `${nonAdmins.length} registered SmartDose users`;
    if ($("badge-users"))   $("badge-users").textContent = nonAdmins.length;

    filteredUsers = nonAdmins;
    usersPage = 0;
    renderUsersTable();
    renderRecentUsers(nonAdmins.slice(0, 5));
  } catch (err) {
    console.error("loadUsers:", err);
    showToast("Failed to load users.", "error");
  }
}

function renderUsersTable() {
  const tbody = $("users-body");
  if (!tbody) return;

  const total = filteredUsers.length;
  const start = usersPage * USERS_PER_PAGE;
  const end   = Math.min(start + USERS_PER_PAGE, total);
  const page  = filteredUsers.slice(start, end);

  if (page.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" class="table-loading">No users found.</td></tr>`;
    $("users-pagination").style.display = "none";
    return;
  }

  tbody.innerHTML = page.map((u) => `
    <tr>
      <td style="font-weight:600;color:var(--text-primary);">${u.name || "—"}</td>
      <td>${u.email || "—"}</td>
      <td>${roleBadge(u.role)}</td>
      <td>${u.phone || "—"}</td>
      <td>${formatDate(u.createdAt)}</td>
      <td>${statusBadge(u.status || "active")}</td>
      <td>
        <button class="tbl-btn" onclick="viewUser('${u.id}')">View</button>
        ${(u.status === "suspended")
          ? `<button class="tbl-btn tbl-btn-success" onclick="reinstateUser('${u.id}','${(u.name||"").replace(/'/g,"\\'")}')">Reinstate</button>`
          : `<button class="tbl-btn tbl-btn-danger" onclick="suspendUser('${u.id}','${(u.name||"").replace(/'/g,"\\'")}')">Suspend</button>`
        }
      </td>
    </tr>
  `).join("");

  // Pagination bar
  const pagBar = $("users-pagination");
  pagBar.style.display = "flex";
  $("users-page-info").textContent = `Showing ${start + 1}–${end} of ${total}`;
  $("users-prev-btn").disabled = (usersPage === 0);
  $("users-next-btn").disabled = (end >= total);
}

function renderRecentUsers(users) {
  const tbody = $("recent-users-body");
  if (!tbody) return;
  if (users.length === 0) {
    tbody.innerHTML = `<tr><td colspan="4" class="table-loading">No users yet.</td></tr>`;
    return;
  }
  tbody.innerHTML = users.map((u) => `
    <tr>
      <td style="font-weight:600;color:var(--text-primary);">${u.name || "—"}</td>
      <td>${roleBadge(u.role)}</td>
      <td>${formatDate(u.createdAt)}</td>
      <td>${statusBadge(u.status || "active")}</td>
    </tr>
  `).join("");
}

// ─── User search & filter ─────────────────────────────────────────────────────
$("user-search")?.addEventListener("input", filterUsers);
$("role-filter")?.addEventListener("change", filterUsers);

function filterUsers() {
  const search = ($("user-search")?.value || "").toLowerCase();
  const role   = $("role-filter")?.value || "";
  filteredUsers = allUsers
    .filter((u) => u.role !== "admin")
    .filter((u) => {
      const matchRole   = !role || u.role === role;
      const matchSearch = !search ||
        (u.name  || "").toLowerCase().includes(search) ||
        (u.email || "").toLowerCase().includes(search) ||
        (u.phone || "").toLowerCase().includes(search);
      return matchRole && matchSearch;
    });
  usersPage = 0;
  renderUsersTable();
}

// ─── Pagination ───────────────────────────────────────────────────────────────
$("users-prev-btn")?.addEventListener("click", () => { usersPage--; renderUsersTable(); });
$("users-next-btn")?.addEventListener("click", () => { usersPage++; renderUsersTable(); });

// ─── View User Modal ─────────────────────────────────────────────────────────
window.viewUser = async (uid) => {
  const u = allUsers.find((x) => x.id === uid);
  if (!u) return;

  $("modal-user-avatar").textContent = (u.name || "U").charAt(0).toUpperCase();
  $("modal-user-name").textContent   = u.name || "—";
  $("modal-user-email").textContent  = u.email || "—";
  $("modal-user-role").innerHTML     = roleBadge(u.role);
  $("modal-user-status").innerHTML   = statusBadge(u.status || "active");
  $("modal-user-phone").textContent  = u.phone || "—";
  $("modal-user-joined").textContent = formatDate(u.createdAt);

  // Try to pull patient-specific data
  let deviceId = "—";
  let adherence = "—";
  try {
    const patDoc = await getDoc(doc(db, "patients", uid));
    if (patDoc.exists()) {
      deviceId  = patDoc.data().deviceId  || "Not assigned";
      adherence = patDoc.data().adherencePercent != null
        ? `${patDoc.data().adherencePercent}%` : "—";
    }
  } catch (_) {}

  $("modal-user-device").textContent    = deviceId;
  $("modal-user-adherence").textContent = adherence;

  // Action buttons
  const isSuspended = u.status === "suspended";
  $("modal-user-actions").innerHTML = `
    ${isSuspended
      ? `<button class="btn-user-action success" onclick="reinstateUser('${uid}','${(u.name||"").replace(/'/g,"\\'")}'); closeUserModal();">✅ Reinstate</button>`
      : `<button class="btn-user-action danger" onclick="suspendUser('${uid}','${(u.name||"").replace(/'/g,"\\'")}'); closeUserModal();">🚫 Suspend</button>`
    }
    <button class="btn-user-action" onclick="resetPassword('${u.email || ""}')">🔑 Reset Password</button>
  `;

  $("modal-user").classList.add("open");
};

window.closeUserModal = () => $("modal-user").classList.remove("open");
$("user-modal-close-btn").addEventListener("click", window.closeUserModal);
$("modal-user").addEventListener("click", (e) => {
  if (e.target === $("modal-user")) window.closeUserModal();
});

// ─── Suspend user ─────────────────────────────────────────────────────────────
window.suspendUser = async (uid, name) => {
  const ok = await openConfirm({
    title:   `Suspend "${name}"?`,
    body:    `This user will lose access to SmartDose. You can reinstate them at any time.`,
    okLabel: "Suspend",
    danger:  true,
  });
  if (!ok) return;
  try {
    await updateDoc(doc(db, "users", uid), { status: "suspended" });
    await logAction("suspend_user", name || uid, "success");
    showToast(`"${name}" has been suspended.`, "success");
    loadUsers();
  } catch (err) {
    await logAction("suspend_user", name || uid, "failure");
    showToast("Failed to suspend user.", "error");
  }
};

// ─── Reinstate user ───────────────────────────────────────────────────────────
window.reinstateUser = async (uid, name) => {
  const ok = await openConfirm({
    title:   `Reinstate "${name}"?`,
    body:    `This will restore their access to SmartDose.`,
    okLabel: "Reinstate",
    danger:  false,
  });
  if (!ok) return;
  try {
    await updateDoc(doc(db, "users", uid), { status: "active" });
    await logAction("reinstate_user", name || uid, "success");
    showToast(`"${name}" has been reinstated.`, "success");
    loadUsers();
  } catch (err) {
    await logAction("reinstate_user", name || uid, "failure");
    showToast("Failed to reinstate user.", "error");
  }
};

// ─── Reset password ───────────────────────────────────────────────────────────
window.resetPassword = async (email) => {
  if (!email) { showToast("No email address on record.", "error"); return; }
  try {
    await sendPasswordResetEmail(auth, email);
    await logAction("reset_password", email, "success");
    showToast(`Password reset email sent to ${email}`, "success");
  } catch (err) {
    showToast("Could not send reset email.", "error");
  }
};

// ═══════════════════════════════════════════════════════════════════════════════
// DEVICES
// ═══════════════════════════════════════════════════════════════════════════════

let allDevices = [];

async function loadDevices() {
  try {
    // Pull from patients collection (each patient doc has deviceId + adherence)
    const patSnap = await getDocs(collection(db, "patients"));
    const patients = patSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

    // Try to pull last dispense per device from dispensingLogs
    let lastDispenseMap = {};
    try {
      const logSnap = await getDocs(
        query(collection(db, "dispensingLogs"), orderBy("timestamp", "desc"), limit(200))
      );
      logSnap.docs.forEach((d) => {
        const data = d.data();
        if (data.deviceId && !lastDispenseMap[data.deviceId]) {
          lastDispenseMap[data.deviceId] = data.timestamp;
        }
      });
    } catch (_) {}

    allDevices = patients;

    const withDevice = patients.filter((p) => p.deviceId);
    if ($("kpi-devices"))     $("kpi-devices").textContent = withDevice.length;
    if ($("kpi-devices-sub")) $("kpi-devices-sub").textContent = `${patients.length} total patients`;
    if ($("badge-devices"))   $("badge-devices").textContent = withDevice.length;

    // Avg adherence
    if (patients.length > 0) {
      const avg = Math.round(
        patients.reduce((s, p) => s + (p.adherencePercent || 0), 0) / patients.length
      );
      if ($("kpi-adherence")) $("kpi-adherence").textContent = `${avg}%`;
    } else {
      if ($("kpi-adherence")) $("kpi-adherence").textContent = "—";
    }

    renderDevicesTable(patients, lastDispenseMap);
    bindDeviceSearch(patients, lastDispenseMap);
  } catch (err) {
    console.error("loadDevices:", err);
  }
}

function renderDevicesTable(patients, lastDispenseMap = {}) {
  const tbody = $("devices-body");
  if (!tbody) return;
  if (patients.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="table-loading">No devices registered.</td></tr>`;
    return;
  }
  tbody.innerHTML = patients.map((p) => `
    <tr>
      <td style="font-family:monospace;color:var(--brand);">${p.deviceId || "Not assigned"}</td>
      <td style="font-weight:600;color:var(--text-primary);">${p.name || "—"}</td>
      <td>${faceEnrollBadge(p.faceEnrollmentStatus)}</td>
      <td>${adherenceBar(p.adherencePercent || 0)}</td>
      <td>${formatDate(lastDispenseMap[p.deviceId]) || "—"}</td>
      <td><span class="badge badge-green">Active</span></td>
    </tr>
  `).join("");
}

function bindDeviceSearch(patients, lastDispenseMap) {
  $("device-search")?.addEventListener("input", () => {
    const q = ($("device-search").value || "").toLowerCase();
    const filtered = q
      ? patients.filter((p) =>
          (p.name || "").toLowerCase().includes(q) ||
          (p.deviceId || "").toLowerCase().includes(q)
        )
      : patients;
    renderDevicesTable(filtered, lastDispenseMap);
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS  (real-time)
// ═══════════════════════════════════════════════════════════════════════════════

let allAlerts = [];

function loadAlerts() {
  try {
    const q = query(collection(db, "alerts"), orderBy("createdAt", "desc"), limit(100));
    onSnapshot(q, (snap) => {
      allAlerts = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

      const active = allAlerts.filter((a) => a.status !== "resolved" && a.status !== "dismissed");
      if ($("kpi-alerts"))     $("kpi-alerts").textContent = active.length;
      if ($("kpi-alerts-sub")) $("kpi-alerts-sub").textContent =
        `${allAlerts.filter((a) => a.status === "resolved").length} resolved`;
      if ($("badge-alerts"))   $("badge-alerts").textContent = active.length;

      renderAlertsTable(allAlerts);
    }, () => {
      // alerts collection may not exist yet
      if ($("alerts-body")) $("alerts-body").innerHTML = `<tr><td colspan="7" class="table-loading">No alerts found. All clear! ✓</td></tr>`;
    });
  } catch (err) {
    console.error("loadAlerts:", err);
  }
}

function renderAlertsTable(alerts) {
  const tbody = $("alerts-body");
  if (!tbody) return;

  const sevFilter    = ($("severity-filter")?.value    || "").toLowerCase();
  const statusFilter = $("alert-status-filter")?.value || "";

  const filtered = alerts.filter((a) => {
    const matchSev    = !sevFilter    || (a.severity || "").toLowerCase() === sevFilter;
    const matchStatus = !statusFilter || (a.status   || "active") === statusFilter;
    return matchSev && matchStatus;
  });

  if (filtered.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" class="table-loading">No alerts found. All clear! ✓</td></tr>`;
    return;
  }

  tbody.innerHTML = filtered.map((a) => `
    <tr>
      <td style="font-weight:600;color:var(--text-primary);">${a.type || "Alert"}</td>
      <td>${a.patientName || a.patientId || "—"}</td>
      <td style="max-width:220px;">${a.message || "—"}</td>
      <td>${severityBadge(a.severity)}</td>
      <td style="white-space:nowrap;">${formatDateTime(a.createdAt)}</td>
      <td>${alertStatusBadge(a.status || "active")}</td>
      <td>
        ${(a.status !== "resolved")
          ? `<button class="tbl-btn tbl-btn-success" onclick="resolveAlert('${a.id}')">Resolve</button>`
          : ""}
        ${(a.status !== "dismissed")
          ? `<button class="tbl-btn" onclick="dismissAlert('${a.id}')">Dismiss</button>`
          : ""}
      </td>
    </tr>
  `).join("");
}

// Alert filters
$("severity-filter")?.addEventListener("change",      () => renderAlertsTable(allAlerts));
$("alert-status-filter")?.addEventListener("change",  () => renderAlertsTable(allAlerts));

window.resolveAlert = async (id) => {
  const ok = await openConfirm({
    title:   "Resolve Alert?",
    body:    "Mark this alert as resolved. This cannot be undone.",
    okLabel: "Resolve",
    danger:  false,
  });
  if (!ok) return;
  try {
    await updateDoc(doc(db, "alerts", id), {
      status:     "resolved",
      resolvedAt: serverTimestamp(),
      resolvedBy: currentAdmin?.uid || "admin",
    });
    await logAction("resolve_alert", id, "success");
    showToast("Alert marked as resolved.", "success");
  } catch (err) {
    showToast("Failed to resolve alert.", "error");
  }
};

window.dismissAlert = async (id) => {
  try {
    await updateDoc(doc(db, "alerts", id), { status: "dismissed" });
    await logAction("dismiss_alert", id, "success");
    showToast("Alert dismissed.", "success");
  } catch (err) {
    showToast("Failed to dismiss alert.", "error");
  }
};

// ═══════════════════════════════════════════════════════════════════════════════
// AUDIT LOGS  (real-time)
// ═══════════════════════════════════════════════════════════════════════════════

let allLogs = [];

function startAuditLogListener() {
  const logsQ = query(collection(db, "audit_logs"), orderBy("timestamp", "desc"), limit(200));
  onSnapshot(logsQ, (snap) => {
    allLogs = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    renderLogsTable();
  }, () => {
    const tbody = $("logs-body");
    if (tbody) tbody.innerHTML = `<tr><td colspan="5" class="table-loading">Audit logs not yet available.</td></tr>`;
  });
}

function renderLogsTable() {
  const tbody = $("logs-body");
  if (!tbody) return;

  const fromDate   = $("log-from-date")?.value;
  const toDate     = $("log-to-date")?.value;
  const actionType = $("log-action-filter")?.value || "";

  const filtered = allLogs.filter((l) => {
    const ts = l.timestamp?.toDate ? l.timestamp.toDate() : null;
    if (fromDate && ts && ts < new Date(fromDate)) return false;
    if (toDate   && ts && ts > new Date(toDate + "T23:59:59")) return false;
    if (actionType && l.action !== actionType) return false;
    return true;
  });

  if (filtered.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" class="table-loading">No audit logs match the current filters.</td></tr>`;
    return;
  }

  tbody.innerHTML = filtered.map((l) => `
    <tr>
      <td style="font-family:monospace;font-size:12px;white-space:nowrap;">${formatDateTime(l.timestamp)}</td>
      <td style="font-weight:600;color:var(--text-primary);">${l.adminName || l.adminId || "System"}</td>
      <td>${l.action || "—"}</td>
      <td style="color:var(--text-secondary);">${l.target || "—"}</td>
      <td><span class="badge ${l.result === "success" ? "badge-green" : "badge-red"}">${l.result || "—"}</span></td>
    </tr>
  `).join("");
}

// Log filters
$("log-from-date")?.addEventListener("change",    renderLogsTable);
$("log-to-date")?.addEventListener("change",      renderLogsTable);
$("log-action-filter")?.addEventListener("change", renderLogsTable);

// ─── Export CSV ───────────────────────────────────────────────────────────────
$("export-logs-btn")?.addEventListener("click", () => {
  const fromDate   = $("log-from-date")?.value;
  const toDate     = $("log-to-date")?.value;
  const actionType = $("log-action-filter")?.value || "";

  const rows = allLogs.filter((l) => {
    const ts = l.timestamp?.toDate ? l.timestamp.toDate() : null;
    if (fromDate && ts && ts < new Date(fromDate)) return false;
    if (toDate   && ts && ts > new Date(toDate + "T23:59:59")) return false;
    if (actionType && l.action !== actionType) return false;
    return true;
  });

  if (rows.length === 0) { showToast("No logs to export.", "error"); return; }

  const header = ["Timestamp", "Admin", "Action", "Target", "Result"];
  const csv = [
    header.join(","),
    ...rows.map((l) => [
      formatDateTime(l.timestamp),
      l.adminName || l.adminId || "System",
      l.action || "",
      l.target || "",
      l.result || "",
    ].map((v) => `"${String(v).replace(/"/g, '""')}"`).join(",")),
  ].join("\n");

  const blob = new Blob([csv], { type: "text/csv" });
  const url  = URL.createObjectURL(blob);
  const a    = document.createElement("a");
  a.href     = url;
  a.download = `audit_logs_${new Date().toISOString().slice(0,10)}.csv`;
  a.click();
  URL.revokeObjectURL(url);
  showToast("CSV exported successfully.", "success");
});

// ─── Log admin action helper ───────────────────────────────────────────────────
async function logAction(action, target, result = "success") {
  if (!currentAdmin) return;
  try {
    await addDoc(collection(db, "audit_logs"), {
      adminId:   currentAdmin.uid,
      adminName: currentAdmin.name || "Admin",
      action,
      target:    String(target),
      result,
      timestamp: serverTimestamp(),
    });
  } catch (_) {}
}

// ═══════════════════════════════════════════════════════════════════════════════
// SETTINGS — Editable Profile
// ═══════════════════════════════════════════════════════════════════════════════

$("save-profile-btn")?.addEventListener("click", async () => {
  const name = ($("settings-name-input")?.value || "").trim();
  if (!name) { showToast("Name cannot be empty.", "error"); return; }
  if (!currentAdmin) return;
  try {
    await updateDoc(doc(db, "users", currentAdmin.uid), { name });
    currentAdmin.name = name;
    const initial = name.charAt(0).toUpperCase();
    if ($("admin-name-label"))    $("admin-name-label").textContent    = name;
    if ($("admin-avatar-initials")) $("admin-avatar-initials").textContent = initial;
    if ($("topbar-avatar"))       $("topbar-avatar").textContent       = initial;
    if ($("settings-avatar"))     $("settings-avatar").textContent     = initial;
    if ($("settings-name"))       $("settings-name").textContent       = name;
    await logAction("update_profile", `name → ${name}`, "success");
    showToast("Profile updated successfully.", "success");
  } catch (err) {
    showToast("Failed to save profile.", "error");
  }
});

$("change-password-btn")?.addEventListener("click", async () => {
  const email = currentAdmin?.email;
  if (!email) { showToast("No email on record.", "error"); return; }
  const ok = await openConfirm({
    title:   "Change Password?",
    body:    `A password reset email will be sent to ${email}.`,
    okLabel: "Send Email",
    danger:  false,
  });
  if (!ok) return;
  try {
    await sendPasswordResetEmail(auth, email);
    await logAction("reset_password", email, "success");
    showToast(`Password reset email sent to ${email}`, "success");
  } catch (err) {
    showToast("Could not send reset email.", "error");
  }
});

// ═══════════════════════════════════════════════════════════════════════════════
// OVERVIEW CHARTS  (Chart.js)
// ═══════════════════════════════════════════════════════════════════════════════

async function loadOverviewCharts() {
  if (!Chart) {
    // Chart.js not loaded yet — retry
    setTimeout(loadOverviewCharts, 500);
    return;
  }
  await Promise.all([buildDispensingChart(), buildAlertTypesChart()]);
}

async function buildDispensingChart() {
  const canvas = $("chart-dispensing");
  if (!canvas) return;

  // Build last-7-days labels
  const labels = [];
  const taken  = [];
  const missed = [];

  const now = new Date();
  for (let i = 6; i >= 0; i--) {
    const d = new Date(now);
    d.setDate(d.getDate() - i);
    labels.push(d.toLocaleDateString("en-PH", { weekday: "short", month: "short", day: "numeric" }));
    taken.push(0);
    missed.push(0);
  }

  // Try to load dispensingLogs
  try {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - 7);
    const snap = await getDocs(
      query(
        collection(db, "dispensingLogs"),
        where("timestamp", ">=", Timestamp.fromDate(cutoff)),
        orderBy("timestamp", "asc"),
        limit(500)
      )
    );
    snap.docs.forEach((d) => {
      const data = d.data();
      const ts   = data.timestamp?.toDate ? data.timestamp.toDate() : null;
      if (!ts) return;
      const daysAgo = Math.floor((now - ts) / 86400000);
      const idx = 6 - daysAgo;
      if (idx < 0 || idx > 6) return;
      if (data.taken || data.status === "taken") taken[idx]++;
      else missed[idx]++;
    });
  } catch (_) {
    // Collection may not exist yet — chart still renders with zeros
  }

  new Chart(canvas, {
    type: "bar",
    data: {
      labels,
      datasets: [
        {
          label: "Taken",
          data: taken,
          backgroundColor: "rgba(16,185,129,0.7)",
          borderRadius: 6,
        },
        {
          label: "Missed",
          data: missed,
          backgroundColor: "rgba(239,68,68,0.5)",
          borderRadius: 6,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { labels: { color: "#94A3B8", font: { family: "Inter", size: 12 } } },
      },
      scales: {
        x: { ticks: { color: "#64748B", font: { size: 11 } }, grid: { color: "rgba(255,255,255,0.04)" } },
        y: { ticks: { color: "#64748B", precision: 0 }, grid: { color: "rgba(255,255,255,0.04)" }, beginAtZero: true },
      },
    },
  });
}

async function buildAlertTypesChart() {
  const canvas = $("chart-alert-types");
  if (!canvas) return;

  // Tally alerts by type from allAlerts (already loaded)
  const typeCounts = {};
  allAlerts.forEach((a) => {
    const t = a.type || "Other";
    typeCounts[t] = (typeCounts[t] || 0) + 1;
  });

  const labels = Object.keys(typeCounts);
  const data   = Object.values(typeCounts);

  if (labels.length === 0) {
    // No alerts yet — show a placeholder donut
    labels.push("No alerts");
    data.push(1);
  }

  const palette = [
    "rgba(16,185,129,0.75)",
    "rgba(239,68,68,0.75)",
    "rgba(245,158,11,0.75)",
    "rgba(59,130,246,0.75)",
    "rgba(139,92,246,0.75)",
    "rgba(236,72,153,0.75)",
  ];

  new Chart(canvas, {
    type: "doughnut",
    data: {
      labels,
      datasets: [{
        data,
        backgroundColor: labels.map((_, i) => palette[i % palette.length]),
        borderWidth: 2,
        borderColor: "#111620",
        hoverOffset: 6,
      }],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      cutout: "68%",
      plugins: {
        legend: {
          position: "right",
          labels: { color: "#94A3B8", font: { family: "Inter", size: 12 }, padding: 14 },
        },
      },
    },
  });
}
