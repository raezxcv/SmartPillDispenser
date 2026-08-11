import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import { ConfirmModal } from '../components/ConfirmModal';
import {
  User,
  Mail,
  Shield,
  Key,
  Save,
  UserPlus,
  Bell,
  CheckCircle2,
  Lock,
  Flame,
  RefreshCw,
  Trash2,
  X
} from 'lucide-react';

export function SettingsView() {
  const { currentUser, admins, updateAdminName, addNewAdmin, deleteAdmin, seedLiveFirestoreFleet, firestoreConnected, showToast } = useApp();

  // Profile form
  const [profileName, setProfileName] = useState(currentUser.name);

  // Add Admin Modal
  const [isAddAdminOpen, setIsAddAdminOpen] = useState(false);
  const [newAdminName, setNewAdminName] = useState('');
  const [newAdminEmail, setNewAdminEmail] = useState('');
  const [newAdminPassword, setNewAdminPassword] = useState('');
  const [isSavingAdmin, setIsSavingAdmin] = useState(false);

  // Delete Admin Target
  const [deleteTarget, setDeleteTarget] = useState(null);
  const [isSeeding, setIsSeeding] = useState(false);

  // Settings preferences
  const [smsAlerts, setSmsAlerts] = useState(true);
  const [pushNotifications, setPushNotifications] = useState(true);
  const [heartbeatInterval, setHeartbeatInterval] = useState('30');

  const handleProfileSave = (e) => {
    e.preventDefault();
    updateAdminName(profileName);
  };

  const handlePasswordReset = () => {
    showToast(`Password reset link dispatched to ${currentUser.email}`, 'success');
  };

  const handleCreateAdmin = async (e) => {
    e.preventDefault();
    if (!newAdminName.trim() || !newAdminEmail.trim() || !newAdminPassword) {
      showToast('Please fill in all admin fields.', 'error');
      return;
    }
    setIsSavingAdmin(true);
    await addNewAdmin(newAdminName, newAdminEmail, newAdminPassword);
    setNewAdminName('');
    setNewAdminEmail('');
    setNewAdminPassword('');
    setIsSavingAdmin(false);
    setIsAddAdminOpen(false);
  };

  const handleSeedDatabase = async () => {
    setIsSeeding(true);
    await seedLiveFirestoreFleet();
    setIsSeeding(false);
  };

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '24px', maxWidth: '980px', margin: '0 auto' }}>
      
      {/* ── Page Header ── */}
      <div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
          Settings & Administration
        </h1>
        <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
          Manage your administrator profile, console administrators table, live database sync, and system preferences.
        </p>
      </div>

      {/* ── Section 1: Administrator Profile (Single Column) ── */}
      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', padding: '24px', boxShadow: 'var(--shadow-card)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '20px' }}>
          <div
            style={{
              width: '52px',
              height: '52px',
              borderRadius: '50%',
              backgroundColor: '#BE123C',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '22px',
              fontWeight: '800',
              boxShadow: '0 3px 10px rgba(190, 18, 60, 0.28)'
            }}
          >
            {currentUser.initial || 'A'}
          </div>
          <div>
            <h3 style={{ fontSize: '17px', fontWeight: '800', color: '#111827', margin: 0 }}>
              {currentUser.name}
            </h3>
            <div style={{ fontSize: '13px', color: '#6B7280', marginTop: '2px' }}>
              {currentUser.email || 'Super Administrator'}
            </div>
          </div>
        </div>

        <form onSubmit={handleProfileSave} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '14px' }}>
            <div>
              <label style={{ display: 'block', fontSize: '11.5px', fontWeight: '700', color: '#4B5563', textTransform: 'uppercase', marginBottom: '5px' }}>
                Display Name
              </label>
              <input
                type="text"
                value={profileName}
                onChange={(e) => setProfileName(e.target.value)}
                style={{
                  width: '100%',
                  height: '42px',
                  padding: '0 14px',
                  borderRadius: '10px',
                  border: '1px solid #D1D5DB',
                  fontSize: '13.5px',
                  outline: 'none',
                  boxSizing: 'border-box'
                }}
              />
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '11.5px', fontWeight: '700', color: '#4B5563', textTransform: 'uppercase', marginBottom: '5px' }}>
                Email Address (Firebase Identity)
              </label>
              <input
                type="text"
                value={currentUser.email}
                disabled
                style={{
                  width: '100%',
                  height: '42px',
                  padding: '0 14px',
                  borderRadius: '10px',
                  border: '1px solid #E5E7EB',
                  backgroundColor: '#F9FAFB',
                  color: '#6B7280',
                  fontSize: '13.5px',
                  boxSizing: 'border-box'
                }}
              />
            </div>
          </div>

          <div style={{ display: 'flex', gap: '10px', marginTop: '6px' }}>
            <button
              type="submit"
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                padding: '9px 18px',
                borderRadius: '10px',
                backgroundColor: '#10B981',
                color: '#FFFFFF',
                fontSize: '13px',
                fontWeight: '700',
                border: 'none',
                cursor: 'pointer',
                boxShadow: '0 2px 8px rgba(16, 185, 129, 0.25)'
              }}
            >
              <Save size={15} /> Save Changes
            </button>

            <button
              type="button"
              onClick={handlePasswordReset}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                padding: '9px 16px',
                borderRadius: '10px',
                backgroundColor: '#FFFFFF',
                color: '#374151',
                fontSize: '13px',
                fontWeight: '600',
                border: '1px solid #D1D5DB',
                cursor: 'pointer'
              }}
            >
              <Key size={15} /> Reset Password
            </button>
          </div>
        </form>
      </div>

      {/* ── Section 2: Console Administrators Table with Top-Right Modal Button ── */}
      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', overflow: 'hidden', boxShadow: 'var(--shadow-card)' }}>
        <div style={{ padding: '20px 24px', borderBottom: '1px solid #E6EFE9', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
          <div>
            <h3 style={{ fontSize: '17px', fontWeight: '800', color: '#111827', margin: 0 }}>
              Console Administrators ({admins.length})
            </h3>
            <p style={{ fontSize: '12.5px', color: '#6B7280', margin: '2px 0 0' }}>
              Authorized administrators with credentials to access the SmartDose console.
            </p>
          </div>

          <button
            type="button"
            onClick={() => setIsAddAdminOpen(true)}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              padding: '9px 16px',
              borderRadius: '10px',
              backgroundColor: '#10B981',
              color: '#FFFFFF',
              fontSize: '13px',
              fontWeight: '700',
              border: 'none',
              cursor: 'pointer',
              boxShadow: '0 2px 8px rgba(16, 185, 129, 0.3)',
              transition: 'all 0.15s'
            }}
            onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = '#059669')}
            onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = '#10B981')}
          >
            <UserPlus size={16} strokeWidth={2.4} /> + Add Administrator
          </button>
        </div>

        {/* Admins Table */}
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '13.5px' }}>
          <thead>
            <tr style={{ borderBottom: '1px solid #E6EFE9', backgroundColor: '#F9FBFA' }}>
              <th style={{ padding: '12px 24px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Administrator</th>
              <th style={{ padding: '12px 24px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Email Address</th>
              <th style={{ padding: '12px 24px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Role</th>
              <th style={{ padding: '12px 24px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Status</th>
              <th style={{ padding: '12px 24px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase', textAlign: 'right' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {admins.map((adm, idx) => (
              <tr key={adm.id} style={{ borderBottom: idx === admins.length - 1 ? 'none' : '1px solid #F0F5F2' }}>
                <td style={{ padding: '16px 24px' }}>
                  <div style={{ fontWeight: '700', color: '#111827' }}>{adm.name}</div>
                </td>
                <td style={{ padding: '16px 24px', color: '#4B5563', fontFamily: 'monospace' }}>
                  {adm.email}
                </td>
                <td style={{ padding: '16px 24px' }}>
                  <span style={{ backgroundColor: '#F3F4F6', color: '#374151', padding: '3px 8px', borderRadius: '6px', fontSize: '12px', fontWeight: '700' }}>
                    Super Admin
                  </span>
                </td>
                <td style={{ padding: '16px 24px' }}>
                  <StatusBadge status={adm.status || 'active'} />
                </td>
                <td style={{ padding: '16px 24px', textAlign: 'right' }}>
                  {adm.email !== currentUser.email && (
                    <button
                      onClick={() => setDeleteTarget(adm)}
                      title="Remove Admin Access"
                      style={{
                        padding: '6px',
                        border: 'none',
                        background: 'none',
                        color: '#9CA3AF',
                        cursor: 'pointer',
                        borderRadius: '6px',
                        transition: 'all 0.15s'
                      }}
                      onMouseEnter={(e) => {
                        e.currentTarget.style.backgroundColor = '#FEE2E2';
                        e.currentTarget.style.color = '#DC2626';
                      }}
                      onMouseLeave={(e) => {
                        e.currentTarget.style.backgroundColor = 'transparent';
                        e.currentTarget.style.color = '#9CA3AF';
                      }}
                    >
                      <Trash2 size={16} />
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* ── Section 3: Live Firebase Cloud Sync ── */}
      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', padding: '24px', boxShadow: 'var(--shadow-card)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '14px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div
              style={{
                width: '44px',
                height: '44px',
                borderRadius: '12px',
                backgroundColor: '#FEF3C7',
                color: '#D97706',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
              }}
            >
              <Flame size={24} strokeWidth={2.4} />
            </div>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <h3 style={{ fontSize: '16.5px', fontWeight: '800', color: '#111827', margin: 0 }}>
                  Live Firebase Firestore Database
                </h3>
                <span
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '4px',
                    backgroundColor: firestoreConnected ? '#D1FAE5' : '#FEF3C7',
                    color: firestoreConnected ? '#047857' : '#B45309',
                    fontSize: '11px',
                    fontWeight: '700',
                    padding: '2px 8px',
                    borderRadius: '9999px'
                  }}
                >
                  <span style={{ width: '6px', height: '6px', borderRadius: '50%', backgroundColor: firestoreConnected ? '#10B981' : '#F59E0B' }} />
                  {firestoreConnected ? 'Live Cloud Connected' : 'Online / Ready'}
                </span>
              </div>
              <div style={{ fontSize: '12.5px', color: '#6B7280', marginTop: '2px' }}>
                Project: <code>smart-pill-dispenser-baa02</code> • Schema: <code>users</code>, <code>admins</code>, <code>contacts</code>, <code>devices</code>, <code>alerts</code>, <code>schedules</code>
              </div>
            </div>
          </div>

          <button
            type="button"
            disabled={isSeeding}
            onClick={handleSeedDatabase}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              padding: '10px 18px',
              borderRadius: '10px',
              backgroundColor: '#10B981',
              color: '#FFFFFF',
              fontSize: '13.5px',
              fontWeight: '700',
              border: 'none',
              cursor: 'pointer',
              boxShadow: '0 4px 12px rgba(16, 185, 129, 0.3)',
              transition: 'all 0.15s'
            }}
          >
            <RefreshCw size={16} className={isSeeding ? 'animate-spin' : ''} />
            {isSeeding ? 'Syncing...' : 'Sync / Seed Live Firestore Fleet'}
          </button>
        </div>
      </div>

      {/* ── Section 4: System & Gateway Preferences ── */}
      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', padding: '24px', boxShadow: 'var(--shadow-card)' }}>
        <h3 style={{ fontSize: '16.5px', fontWeight: '800', color: '#111827', marginBottom: '14px' }}>
          Gateway & Fleet Preferences
        </h3>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <label style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', cursor: 'pointer' }}>
            <div>
              <div style={{ fontSize: '13.5px', fontWeight: '600', color: '#111827' }}>SMS Emergency Gateway</div>
              <div style={{ fontSize: '12px', color: '#6B7280' }}>Dispatch instant SMS alerts to paired caregiver contacts</div>
            </div>
            <input
              type="checkbox"
              checked={smsAlerts}
              onChange={(e) => { setSmsAlerts(e.target.checked); showToast('SMS Gateway updated'); }}
              style={{ width: '18px', height: '18px', accentColor: '#10B981', cursor: 'pointer' }}
            />
          </label>

          <label style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', cursor: 'pointer' }}>
            <div>
              <div style={{ fontSize: '13.5px', fontWeight: '600', color: '#111827' }}>FCM Push Notifications</div>
              <div style={{ fontSize: '12px', color: '#6B7280' }}>Send real-time alerts to caregiver mobile devices</div>
            </div>
            <input
              type="checkbox"
              checked={pushNotifications}
              onChange={(e) => { setPushNotifications(e.target.checked); showToast('FCM Push notifications updated'); }}
              style={{ width: '18px', height: '18px', accentColor: '#10B981', cursor: 'pointer' }}
            />
          </label>

          <div style={{ borderTop: '1px solid #F0F5F2', paddingTop: '12px' }}>
            <label style={{ display: 'block', fontSize: '11.5px', fontWeight: '700', color: '#4B5563', textTransform: 'uppercase', marginBottom: '5px' }}>
              Controller Heartbeat Frequency
            </label>
            <select
              value={heartbeatInterval}
              onChange={(e) => { setHeartbeatInterval(e.target.value); showToast('Heartbeat frequency updated'); }}
              style={{
                width: '100%',
                height: '40px',
                padding: '0 12px',
                borderRadius: '10px',
                border: '1px solid #D1D5DB',
                fontSize: '13px',
                outline: 'none',
                backgroundColor: '#FFFFFF'
              }}
            >
              <option value="15">15 Seconds (Real-time tracking)</option>
              <option value="30">30 Seconds (Recommended)</option>
              <option value="60">60 Seconds (Power-save mode)</option>
            </select>
          </div>
        </div>
      </div>

      {/* ── ADD ADMINISTRATOR MODAL (Mounted via Portal directly to body) ── */}
      {isAddAdminOpen &&
        createPortal(
          <div className="modal-overlay" onClick={() => setIsAddAdminOpen(false)}>
            <div className="modal-dialog" style={{ maxWidth: '440px' }} onClick={(e) => e.stopPropagation()}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <div style={{ width: '38px', height: '38px', borderRadius: '10px', backgroundColor: '#ECFDF5', color: '#059669', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <UserPlus size={20} strokeWidth={2.4} />
                  </div>
                  <div>
                    <h3 style={{ fontSize: '17px', fontWeight: '800', color: '#111827', margin: 0 }}>
                      Add Administrator
                    </h3>
                    <p style={{ fontSize: '12px', color: '#6B7280', margin: '2px 0 0' }}>
                      Create console credentials in Firebase.
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => setIsAddAdminOpen(false)}
                  style={{ background: 'none', border: 'none', color: '#9CA3AF', cursor: 'pointer', padding: '6px' }}
                >
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleCreateAdmin} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#374151', marginBottom: '5px' }}>
                    Admin Full Name *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Dr. Maria Santos"
                    value={newAdminName}
                    onChange={(e) => setNewAdminName(e.target.value)}
                    style={{
                      width: '100%',
                      height: '42px',
                      padding: '0 14px',
                      borderRadius: '10px',
                      border: '1px solid #D1D5DB',
                      fontSize: '13.5px',
                      outline: 'none',
                      boxSizing: 'border-box'
                    }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#374151', marginBottom: '5px' }}>
                    Admin Email Address *
                  </label>
                  <input
                    type="email"
                    required
                    placeholder="maria.santos@smartpill.com"
                    value={newAdminEmail}
                    onChange={(e) => setNewAdminEmail(e.target.value)}
                    style={{
                      width: '100%',
                      height: '42px',
                      padding: '0 14px',
                      borderRadius: '10px',
                      border: '1px solid #D1D5DB',
                      fontSize: '13.5px',
                      outline: 'none',
                      boxSizing: 'border-box'
                    }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#374151', marginBottom: '5px' }}>
                    Temporary Password *
                  </label>
                  <input
                    type="password"
                    required
                    placeholder="••••••••"
                    value={newAdminPassword}
                    onChange={(e) => setNewAdminPassword(e.target.value)}
                    style={{
                      width: '100%',
                      height: '42px',
                      padding: '0 14px',
                      borderRadius: '10px',
                      border: '1px solid #D1D5DB',
                      fontSize: '13.5px',
                      outline: 'none',
                      boxSizing: 'border-box'
                    }}
                  />
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '10px' }}>
                  <button
                    type="button"
                    onClick={() => setIsAddAdminOpen(false)}
                    style={{
                      height: '40px',
                      padding: '0 18px',
                      borderRadius: '10px',
                      border: '1px solid #D1D5DB',
                      backgroundColor: '#FFFFFF',
                      color: '#4B5563',
                      fontSize: '13px',
                      fontWeight: '600',
                      cursor: 'pointer'
                    }}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={isSavingAdmin}
                    style={{
                      height: '40px',
                      padding: '0 22px',
                      borderRadius: '10px',
                      border: 'none',
                      backgroundColor: '#10B981',
                      color: '#FFFFFF',
                      fontSize: '13.5px',
                      fontWeight: '700',
                      cursor: 'pointer',
                      boxShadow: '0 3px 10px rgba(16, 185, 129, 0.3)'
                    }}
                  >
                    {isSavingAdmin ? 'Creating...' : 'Create Admin'}
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ── DELETE ADMIN CONFIRMATION ── */}
      {deleteTarget && (
        <ConfirmModal
          isOpen={true}
          onClose={() => setDeleteTarget(null)}
          onConfirm={() => deleteAdmin(deleteTarget.id, deleteTarget.name)}
          title={`Remove Administrator "${deleteTarget.name}"?`}
          message={`Are you sure you want to revoke console access for ${deleteTarget.email}?`}
          confirmText="Remove Access"
          isDanger={true}
        />
      )}

    </div>
  );
}
