/**
 * Smart Pill Dispenser — Admin Web App
 * Firebase Auth + Firestore data loading for dashboard.html
 *
 * Replace the firebaseConfig values with your real project keys.
 */

import { initializeApp }
  from "https://www.gstatic.com/firebasejs/10.14.0/firebase-app.js";
import {
  getAuth,
  onAuthStateChanged,
  signOut,
} from "https://www.gstatic.com/firebasejs/10.14.0/firebase-auth.js";
import {
  getFirestore,
  collection,
  getDocs,
  doc,
  getDoc,
  query,
  orderBy,
  limit,
  where,
  onSnapshot,
  serverTimestamp,
  addDoc,
} from "https://www.gstatic.com/firebasejs/10.14.0/firebase-firestore.js";

// ─── Firebase Config ─────────────────────────────────────────────────────────
const firebaseConfig = {
  apiKey:            "REPLACE_WITH_YOUR_WEB_API_KEY",
  authDomain:        "smart-pill-dispenser-baa02.firebaseapp.com",
  projectId:         "smart-pill-dispenser-baa02",
  storageBucket:     "smart-pill-dispenser-baa02.firebasestorage.app",
  messagingSenderId: "REPLACE_WITH_YOUR_SENDER_ID",
  appId:             "REPLACE_WITH_YOUR_WEB_APP_ID",
};

const app  = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db   = getFirestore(app);

// ─── Utility helpers ──────────────────────────────────────────────────────────
const $ = (id) => document.getElementById(id);

function showToast(msg, durationMs = 3000) {
  const toast = $("toast");
  toast.textContent = msg;
  toast.classList.add("show");
  setTimeout(() => toast.classList.remove("show"), durationMs);
}

function formatDate(ts) {
  if (!ts) return "—";
  const d = ts.toDate ? ts.toDate() : new Date(ts);
  return d.toLocaleDateString("en-PH", {
    year: "numeric", month: "short", day: "numeric",
  });
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

// ─── Auth guard — redirect to login if not admin ──────────────────────────────
let currentAdmin = null;

onAuthStateChanged(auth, async (user) => {
  if (!user) {
    window.location.href = "index.html";
    return;
  }

  // Verify admin role
  const userDoc = await getDoc(doc(db, "users", user.uid));
  if (!userDoc.exists() || userDoc.data().role !== "admin") {
    await signOut(auth);
    window.location.href = "index.html";
    return;
  }

  currentAdmin = { uid: user.uid, ...userDoc.data() };
  const name    = currentAdmin.name || user.email || "Admin";
  const initial = name.charAt(0).toUpperCase();

  // Populate admin identity in UI
  if ($("admin-name-label"))   $("admin-name-label").textContent   = name;
  if ($("admin-avatar-initials")) $("admin-avatar-initials").textContent = initial;
  if ($("topbar-avatar"))      $("topbar-avatar").textContent      = initial;
  if ($("settings-avatar"))    $("settings-avatar").textContent    = initial;
  if ($("settings-name"))      $("settings-name").textContent      = name;
  if ($("settings-email"))     $("settings-email").textContent     = user.email || "—";

  // Load all dashboard data
  loadUsers();
  loadPatients();
  loadAlerts();
});

// ─── Sign Out ─────────────────────────────────────────────────────────────────
$("signout-btn")?.addEventListener("click", async () => {
  await signOut(auth);
  window.location.href = "index.html";
});

// ═══════════════════════════════════════════════════════════════════════════════
// DATA LOADERS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Load Users ──────────────────────────────────────────────────────────────
let allUsers = [];

async function loadUsers() {
  try {
    const snap = await getDocs(
      query(collection(db, "users"), orderBy("createdAt", "desc"))
    );

    allUsers = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

    // Filter out admins for the user management view
    const nonAdmins = allUsers.filter((u) => u.role !== "admin");
    const patients   = allUsers.filter((u) => u.role === "patient");
    const caregivers = allUsers.filter((u) => u.role === "caregiver");

    // Update KPI
    if ($("kpi-users"))     $("kpi-users").textContent = nonAdmins.length;
    if ($("kpi-users-sub")) $("kpi-users-sub").textContent =
      `${nonAdmins.length} registered SmartDose users`;
    if ($("badge-users"))   $("badge-users").textContent = nonAdmins.length;

    // Populate users table
    renderUsersTable(nonAdmins);

    // Recent registrations (overview panel — latest 5)
    renderRecentUsers(nonAdmins.slice(0, 5));

  } catch (err) {
    console.error("loadUsers:", err);
    showToast("Failed to load users.");
  }
}

function renderUsersTable(users) {
  const tbody = $("users-body");
  if (!tbody) return;

  if (users.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" class="table-loading">No users found.</td></tr>`;
    return;
  }

  tbody.innerHTML = users.map((u) => `
    <tr>
      <td style="font-weight:600;color:var(--text-primary);">${u.name || "—"}</td>
      <td>${u.email || "—"}</td>
      <td>${roleBadge(u.role)}</td>
      <td>${u.phone || "—"}</td>
      <td>${formatDate(u.createdAt)}</td>
      <td>${statusBadge(u.status)}</td>
      <td>
        <button class="tbl-btn" onclick="viewUser('${u.id}')">View</button>
        <button class="tbl-btn tbl-btn-danger" onclick="confirmSuspend('${u.id}', '${u.name}')">Suspend</button>
      </td>
    </tr>
  `).join("");
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
      <td>${statusBadge(u.status)}</td>
    </tr>
  `).join("");
}

// User search & filter
$("user-search")?.addEventListener("input", filterUsers);
$("role-filter")?.addEventListener("change", filterUsers);

function filterUsers() {
  const search = ($("user-search")?.value || "").toLowerCase();
  const role   = $("role-filter")?.value || "";

  const filtered = allUsers
    .filter((u) => u.role !== "admin")
    .filter((u) => {
      const matchRole   = !role || u.role === role;
      const matchSearch = !search ||
        (u.name  || "").toLowerCase().includes(search) ||
        (u.email || "").toLowerCase().includes(search);
      return matchRole && matchSearch;
    });

  renderUsersTable(filtered);
}

// Placeholder actions (extend as needed)
window.viewUser = (uid) => showToast(`Viewing user: ${uid}`);
window.confirmSuspend = (uid, name) => {
  if (confirm(`Suspend user "${name}"? They will lose access.`)) {
    showToast(`User "${name}" suspended (Firestore update needed).`);
  }
};

// ─── Load Patients (Devices section) ─────────────────────────────────────────
async function loadPatients() {
  try {
    const snap = await getDocs(collection(db, "patients"));
    const patients = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

    // KPI
    const withDevice = patients.filter((p) => p.deviceId);
    if ($("kpi-devices"))     $("kpi-devices").textContent = withDevice.length;
    if ($("kpi-devices-sub")) $("kpi-devices-sub").textContent =
      `${patients.length} total patients`;
    if ($("badge-devices"))   $("badge-devices").textContent = withDevice.length;

    // Avg adherence
    if (patients.length > 0) {
      const avg = Math.round(
        patients.reduce((sum, p) => sum + (p.adherencePercent || 0), 0) / patients.length
      );
      if ($("kpi-adherence")) $("kpi-adherence").textContent = `${avg}%`;
    } else {
      if ($("kpi-adherence")) $("kpi-adherence").textContent = "—";
    }

    // Devices table
    const tbody = $("devices-body");
    if (!tbody) return;

    if (patients.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" class="table-loading">No devices registered.</td></tr>`;
      return;
    }

    tbody.innerHTML = patients.map((p) => `
      <tr>
        <td style="font-family:monospace;color:var(--brand);">${p.deviceId || "Not assigned"}</td>
        <td style="font-weight:600;color:var(--text-primary);">${p.name || "—"}</td>
        <td>${faceEnrollBadge(p.faceEnrollmentStatus)}</td>
        <td>${adherenceBar(p.adherencePercent || 0)}</td>
        <td><span class="badge badge-green">Active</span></td>
      </tr>
    `).join("");

  } catch (err) {
    console.error("loadPatients:", err);
  }
}

function faceEnrollBadge(status) {
  const map = {
    enrolled:   ["badge-green",  "Enrolled"],
    pending:    ["badge-amber",  "Pending"],
    not_started:["badge-gray",   "Not Started"],
  };
  const [cls, label] = map[status] || ["badge-gray", status || "Unknown"];
  return `<span class="badge ${cls}">${label}</span>`;
}

// ─── Load Alerts ──────────────────────────────────────────────────────────────
async function loadAlerts() {
  try {
    // Try to load from 'alerts' collection; gracefully handle empty
    let alerts = [];
    try {
      const snap = await getDocs(
        query(collection(db, "alerts"), orderBy("createdAt", "desc"), limit(50))
      );
      alerts = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    } catch (_) {
      // Collection may not exist yet
    }

    const active = alerts.filter((a) => a.status !== "resolved");
    if ($("kpi-alerts"))     $("kpi-alerts").textContent = active.length;
    if ($("kpi-alerts-sub")) $("kpi-alerts-sub").textContent =
      `${alerts.filter((a) => a.status === "resolved").length} resolved`;
    if ($("badge-alerts"))   $("badge-alerts").textContent = active.length;

    const tbody = $("alerts-body");
    if (!tbody) return;

    if (alerts.length === 0) {
      tbody.innerHTML = `<tr><td colspan="6" class="table-loading">No alerts found. All clear! ✓</td></tr>`;
      return;
    }

    tbody.innerHTML = alerts.map((a) => `
      <tr>
        <td style="font-weight:600;color:var(--text-primary);">${a.type || "Alert"}</td>
        <td>${a.patientName || a.patientId || "—"}</td>
        <td style="max-width:260px;">${a.message || "—"}</td>
        <td>${severityBadge(a.severity)}</td>
        <td>${formatDate(a.createdAt)}</td>
        <td>${statusBadge(a.status || "active")}</td>
      </tr>
    `).join("");

  } catch (err) {
    console.error("loadAlerts:", err);
  }
}

// ─── Load Audit Logs ──────────────────────────────────────────────────────────
// Real-time listener for live log updates
const logsRef = collection(db, "audit_logs");
const logsQuery = query(logsRef, orderBy("timestamp", "desc"), limit(100));

onSnapshot(logsQuery, (snap) => {
  const logs = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
  const tbody = $("logs-body");
  if (!tbody) return;

  if (logs.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" class="table-loading">No audit logs yet.</td></tr>`;
    return;
  }

  tbody.innerHTML = logs.map((l) => `
    <tr>
      <td style="font-family:monospace;font-size:12px;white-space:nowrap;">${
        l.timestamp?.toDate
          ? l.timestamp.toDate().toLocaleString("en-PH")
          : "—"
      }</td>
      <td style="font-weight:600;color:var(--text-primary);">${l.adminName || l.adminId || "System"}</td>
      <td>${l.action || "—"}</td>
      <td style="color:var(--text-secondary);">${l.target || "—"}</td>
      <td><span class="badge ${l.result === "success" ? "badge-green" : "badge-red"}">${l.result || "—"}</span></td>
    </tr>
  `).join("");
}, (err) => {
  // Graceful fallback if audit_logs collection doesn't exist
  const tbody = $("logs-body");
  if (tbody) tbody.innerHTML = `<tr><td colspan="5" class="table-loading">Audit logs not yet available.</td></tr>`;
});

// ─── Log admin action helper ───────────────────────────────────────────────────
async function logAction(action, target, result = "success") {
  if (!currentAdmin) return;
  try {
    await addDoc(collection(db, "audit_logs"), {
      adminId:   currentAdmin.uid,
      adminName: currentAdmin.name || "Admin",
      action,
      target,
      result,
      timestamp: serverTimestamp(),
    });
  } catch (_) {}
}
