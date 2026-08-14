import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import { ConfirmModal } from '../components/ConfirmModal';
import {
  Search,
  UserPlus,
  Edit2,
  Trash2,
  Key,
  X,
  User,
  Mail,
  Phone,
  Smartphone,
  CheckCircle2,
  HeartHandshake
} from 'lucide-react';

export function UsersView() {
  const { users, createUser, updateUser, deleteUser, updateUserStatus, showToast, darkMode } = useApp();

  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');

  // Modals state
  const [selectedUser, setSelectedUser] = useState(null);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState(null);

  // Form states
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    deviceId: '',
    emergencyContact: ''
  });

  const filteredUsers = users.filter((u) => {
    const matchSearch =
      !search ||
      (u.name || '').toLowerCase().includes(search.toLowerCase()) ||
      (u.email || '').toLowerCase().includes(search.toLowerCase()) ||
      (u.deviceId || '').toLowerCase().includes(search.toLowerCase());
    const matchStatus = !statusFilter || (u.status || 'active') === statusFilter;
    return matchSearch && matchStatus;
  });

  const handleOpenAdd = () => {
    setFormData({
      name: '',
      email: '',
      phone: '',
      deviceId: 'SD-01' + (Math.floor(Math.random() * 80) + 20),
      emergencyContact: ''
    });
    setIsAddModalOpen(true);
  };

  const handleOpenEdit = (user, e) => {
    if (e) e.stopPropagation();
    setSelectedUser(user);
    setFormData({
      name: user.name || '',
      email: user.email || '',
      phone: user.phone || '',
      deviceId: user.deviceId || '',
      emergencyContact: user.emergencyContact || ''
    });
    setIsEditModalOpen(true);
  };

  const handleSaveAdd = async (e) => {
    e.preventDefault();
    if (!formData.name.trim() || !formData.email.trim()) {
      showToast('Please enter at least Name and Email', 'error');
      return;
    }
    await createUser({ ...formData, role: 'patient' });
    setIsAddModalOpen(false);
  };

  const handleSaveEdit = async (e) => {
    e.preventDefault();
    if (!selectedUser) return;
    await updateUser(selectedUser.id, formData);
    setIsEditModalOpen(false);
    setSelectedUser(null);
  };

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      
      {/* ── Page Header ── */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--text-main)', letterSpacing: '-0.02em', marginBottom: '4px' }}>
            User management
          </h1>
          <p style={{ fontSize: '13.5px', color: 'var(--text-subtle)' }}>
            SmartDose registered users, assigned dispensers, and emergency contacts.
          </p>
        </div>

        <button
          onClick={handleOpenAdd}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            padding: '10px 18px',
            borderRadius: '12px',
            border: 'none',
            backgroundColor: '#10B981',
            color: '#FFFFFF',
            fontSize: '13.5px',
            fontWeight: '700',
            cursor: 'pointer',
            boxShadow: '0 4px 14px rgba(16, 185, 129, 0.3)',
            transition: 'all 0.15s ease'
          }}
          onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = '#059669')}
          onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = '#10B981')}
        >
          <UserPlus size={17} strokeWidth={2.4} /> + Add New User
        </button>
      </div>

      {/* ── Search & Filter Toolbar ── */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px', flexWrap: 'wrap' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flex: 1, minWidth: '260px' }}>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              backgroundColor: 'var(--bg-card)',
              border: '1px solid var(--border-light)',
              borderRadius: '12px',
              padding: '0 14px',
              height: '42px',
              flex: 1,
              maxWidth: '380px',
              boxShadow: '0 1px 2px rgba(0,0,0,0.02)'
            }}
          >
            <Search size={16} style={{ color: 'var(--text-faint)' }} />
            <input
              type="text"
              placeholder="Search by name, email or device ID..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={{
                border: 'none',
                outline: 'none',
                fontSize: '13.5px',
                color: 'var(--text-main)',
                width: '100%',
                backgroundColor: 'transparent'
              }}
            />
          </div>

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            style={{
              height: '42px',
              padding: '0 14px',
              backgroundColor: 'var(--bg-card)',
              border: '1px solid var(--border-light)',
              borderRadius: '12px',
              fontSize: '13px',
              color: 'var(--text-main)',
              fontWeight: '500',
              outline: 'none',
              cursor: 'pointer'
            }}
          >
            <option value="">All Statuses</option>
            <option value="active">Active</option>
            <option value="inactive">Inactive</option>
            <option value="suspended">Suspended</option>
          </select>
        </div>

        <div style={{ fontSize: '13px', color: 'var(--text-subtle)', fontWeight: '500' }}>
          Showing <strong>{filteredUsers.length}</strong> users
        </div>
      </div>

      {/* ── Main Users Card ── */}
      <div
        style={{
          backgroundColor: 'var(--bg-card)',
          border: '1px solid var(--border-light)',
          borderRadius: '20px',
          overflow: 'hidden',
          boxShadow: 'var(--shadow-card)'
        }}
      >
        {filteredUsers.length === 0 ? (
          <div style={{ padding: '48px 24px', textAlign: 'center', color: 'var(--text-faint)', fontSize: '14px' }}>
            No users match the search criteria.
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {filteredUsers.map((user, idx) => (
              <div
                key={user.id}
                onClick={() => setSelectedUser(user)}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '18px 24px',
                  borderBottom: idx === filteredUsers.length - 1 ? 'none' : '1px solid var(--border-light)',
                  cursor: 'pointer',
                  transition: 'background 0.15s'
                }}
                onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = 'var(--bg-hover)')}
                onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = 'transparent')}
              >
                <div>
                  <div style={{ fontSize: '14.5px', fontWeight: '700', color: 'var(--text-main)' }}>
                    {user.name}
                  </div>
                  <div style={{ fontSize: '12.5px', color: 'var(--text-subtle)', marginTop: '3px' }}>
                    {user.email}
                    {user.adherencePercent != null && ` • adherence ${user.adherencePercent}%`}
                    {user.schedulesCount != null && ` • ${user.schedulesCount} schedules`}
                    {user.deviceId && ` • Device: ${user.deviceId}`}
                  </div>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                  <StatusBadge status={user.status || 'active'} />
                  
                  {/* Action icon buttons */}
                  <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }} onClick={(e) => e.stopPropagation()}>
                    <button
                      onClick={(e) => handleOpenEdit(user, e)}
                      title="Edit User"
                      style={{
                        padding: '7px',
                        border: 'none',
                        background: 'none',
                        color: 'var(--text-subtle)',
                        cursor: 'pointer',
                        borderRadius: '8px',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        transition: 'all 0.15s'
                      }}
                      onMouseEnter={(e) => {
                        e.currentTarget.style.backgroundColor = 'var(--bg-hover)';
                        e.currentTarget.style.color = '#059669';
                      }}
                      onMouseLeave={(e) => {
                        e.currentTarget.style.backgroundColor = 'transparent';
                        e.currentTarget.style.color = 'var(--text-subtle)';
                      }}
                    >
                      <Edit2 size={16} />
                    </button>

                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        setDeleteTarget(user);
                      }}
                      title="Delete User"
                      style={{
                        padding: '7px',
                        border: 'none',
                        background: 'none',
                        color: 'var(--text-faint)',
                        cursor: 'pointer',
                        borderRadius: '8px',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        transition: 'all 0.15s'
                      }}
                      onMouseEnter={(e) => {
                        e.currentTarget.style.backgroundColor = '#FEE2E2';
                        e.currentTarget.style.color = '#DC2626';
                      }}
                      onMouseLeave={(e) => {
                        e.currentTarget.style.backgroundColor = 'transparent';
                        e.currentTarget.style.color = 'var(--text-faint)';
                      }}
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* ── CREATE USER MODAL (Mounted via Portal directly to body) ── */}
      {isAddModalOpen &&
        createPortal(
          <div className="modal-overlay" onClick={() => setIsAddModalOpen(false)}>
            <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <div
                    style={{
                      width: '42px',
                      height: '42px',
                      borderRadius: '12px',
                      backgroundColor: darkMode ? 'rgba(16, 185, 129, 0.2)' : '#ECFDF5',
                      color: darkMode ? '#34D399' : '#059669',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}
                  >
                    <UserPlus size={22} strokeWidth={2.4} />
                  </div>
                  <div>
                    <h3 style={{ fontSize: '18px', fontWeight: '800', color: 'var(--text-main)', margin: 0, letterSpacing: '-0.01em' }}>
                      Create New User
                    </h3>
                    <p style={{ fontSize: '12.5px', color: 'var(--text-subtle)', margin: '2px 0 0' }}>
                      Register user account & pair dispenser hardware.
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => setIsAddModalOpen(false)}
                  style={{
                    background: 'none',
                    border: 'none',
                    color: 'var(--text-faint)',
                    cursor: 'pointer',
                    padding: '6px',
                    borderRadius: '8px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center'
                  }}
                >
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleSaveAdd} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '6px' }}>
                    Full Name *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Maria Santos"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    style={{
                      width: '100%',
                      height: '44px',
                      padding: '0 14px',
                      borderRadius: '10px',
                      border: '1px solid var(--border-input)',
                      backgroundColor: 'var(--bg-input)',
                      color: 'var(--text-main)',
                      fontSize: '14px',
                      outline: 'none',
                      boxSizing: 'border-box'
                    }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '6px' }}>
                    Email Address *
                  </label>
                  <input
                    type="email"
                    required
                    placeholder="maria@example.com"
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    style={{
                      width: '100%',
                      height: '44px',
                      padding: '0 14px',
                      borderRadius: '10px',
                      border: '1px solid var(--border-input)',
                      backgroundColor: 'var(--bg-input)',
                      color: 'var(--text-main)',
                      fontSize: '14px',
                      outline: 'none',
                      boxSizing: 'border-box'
                    }}
                  />
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '6px' }}>
                      Phone Number
                    </label>
                    <input
                      type="text"
                      placeholder="+63 917 555 0199"
                      value={formData.phone}
                      onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                      style={{
                        width: '100%',
                        height: '44px',
                        padding: '0 14px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '14px',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    />
                  </div>

                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '6px' }}>
                      Dispenser Unit ID
                    </label>
                    <input
                      type="text"
                      placeholder="SD-0125"
                      value={formData.deviceId}
                      onChange={(e) => setFormData({ ...formData, deviceId: e.target.value })}
                      style={{
                        width: '100%',
                        height: '44px',
                        padding: '0 14px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '13.5px',
                        fontFamily: 'monospace',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    />
                  </div>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '6px' }}>
                    Emergency Contact Name & Phone
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Carlos Santos (+63 917 555 0100)"
                    value={formData.emergencyContact}
                    onChange={(e) => setFormData({ ...formData, emergencyContact: e.target.value })}
                    style={{
                      width: '100%',
                      height: '44px',
                      padding: '0 14px',
                      borderRadius: '10px',
                      border: '1px solid var(--border-input)',
                      backgroundColor: 'var(--bg-input)',
                      color: 'var(--text-main)',
                      fontSize: '14px',
                      outline: 'none',
                      boxSizing: 'border-box'
                    }}
                  />
                </div>

                {/* Action Buttons */}
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '12px' }}>
                  <button
                    type="button"
                    onClick={() => setIsAddModalOpen(false)}
                    style={{
                      height: '42px',
                      padding: '0 20px',
                      borderRadius: '10px',
                      border: '1px solid var(--border-input)',
                      backgroundColor: 'transparent',
                      color: 'var(--text-muted)',
                      fontSize: '13.5px',
                      fontWeight: '600',
                      cursor: 'pointer'
                    }}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    style={{
                      height: '42px',
                      padding: '0 24px',
                      borderRadius: '10px',
                      border: 'none',
                      backgroundColor: '#10B981',
                      color: '#FFFFFF',
                      fontSize: '13.5px',
                      fontWeight: '700',
                      cursor: 'pointer',
                      boxShadow: '0 4px 12px rgba(16, 185, 129, 0.3)'
                    }}
                  >
                    Save User
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ── EDIT USER MODAL (Mounted via Portal directly to body) ── */}
      {isEditModalOpen &&
        selectedUser &&
        createPortal(
          <div
            className="modal-overlay"
            onClick={() => {
              setIsEditModalOpen(false);
              setSelectedUser(null);
            }}
          >
            <div className="modal-dialog" onClick={(e) => e.stopPropagation()}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <div
                    style={{
                      width: '42px',
                      height: '42px',
                      borderRadius: '12px',
                      backgroundColor: darkMode ? 'rgba(16, 185, 129, 0.2)' : '#ECFDF5',
                      color: darkMode ? '#34D399' : '#059669',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}
                  >
                    <Edit2 size={20} strokeWidth={2.4} />
                  </div>
                  <div>
                    <h3 style={{ fontSize: '18px', fontWeight: '800', color: 'var(--text-main)', margin: 0, letterSpacing: '-0.01em' }}>
                      Edit User Profile
                    </h3>
                    <p style={{ fontSize: '12.5px', color: 'var(--text-subtle)', margin: '2px 0 0' }}>
                      Update account details and dispenser mapping.
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => {
                    setIsEditModalOpen(false);
                    setSelectedUser(null);
                  }}
                  style={{
                    background: 'none',
                    border: 'none',
                    color: 'var(--text-faint)',
                    cursor: 'pointer',
                    padding: '6px',
                    borderRadius: '8px'
                  }}
                >
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleSaveEdit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '6px' }}>
                    Full Name
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    style={{
                      width: '100%',
                      height: '44px',
                      padding: '0 14px',
                      borderRadius: '10px',
                      border: '1px solid var(--border-input)',
                      backgroundColor: 'var(--bg-input)',
                      color: 'var(--text-main)',
                      fontSize: '14px',
                      outline: 'none',
                      boxSizing: 'border-box'
                    }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '6px' }}>
                    Email Address
                  </label>
                  <input
                    type="email"
                    required
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    style={{
                      width: '100%',
                      height: '44px',
                      padding: '0 14px',
                      borderRadius: '10px',
                      border: '1px solid var(--border-input)',
                      backgroundColor: 'var(--bg-input)',
                      color: 'var(--text-main)',
                      fontSize: '14px',
                      outline: 'none',
                      boxSizing: 'border-box'
                    }}
                  />
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '6px' }}>
                      Phone Number
                    </label>
                    <input
                      type="text"
                      value={formData.phone}
                      onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                      style={{
                        width: '100%',
                        height: '44px',
                        padding: '0 14px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '14px',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    />
                  </div>

                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '6px' }}>
                      Dispenser Unit ID
                    </label>
                    <input
                      type="text"
                      value={formData.deviceId}
                      onChange={(e) => setFormData({ ...formData, deviceId: e.target.value })}
                      style={{
                        width: '100%',
                        height: '44px',
                        padding: '0 14px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '13.5px',
                        fontFamily: 'monospace',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    />
                  </div>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '6px' }}>
                    Emergency Contact Name & Phone
                  </label>
                  <input
                    type="text"
                    value={formData.emergencyContact}
                    onChange={(e) => setFormData({ ...formData, emergencyContact: e.target.value })}
                    style={{
                      width: '100%',
                      height: '44px',
                      padding: '0 14px',
                      borderRadius: '10px',
                      border: '1px solid var(--border-input)',
                      backgroundColor: 'var(--bg-input)',
                      color: 'var(--text-main)',
                      fontSize: '14px',
                      outline: 'none',
                      boxSizing: 'border-box'
                    }}
                  />
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '12px' }}>
                  <button
                    type="button"
                    onClick={() => {
                      setIsEditModalOpen(false);
                      setSelectedUser(null);
                    }}
                    style={{
                      height: '42px',
                      padding: '0 20px',
                      borderRadius: '10px',
                      border: '1px solid var(--border-input)',
                      backgroundColor: 'transparent',
                      color: 'var(--text-muted)',
                      fontSize: '13.5px',
                      fontWeight: '600',
                      cursor: 'pointer'
                    }}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    style={{
                      height: '42px',
                      padding: '0 24px',
                      borderRadius: '10px',
                      border: 'none',
                      backgroundColor: '#10B981',
                      color: '#FFFFFF',
                      fontSize: '13.5px',
                      fontWeight: '700',
                      cursor: 'pointer',
                      boxShadow: '0 4px 12px rgba(16, 185, 129, 0.3)'
                    }}
                  >
                    Update User
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ── DELETE USER MODAL ── */}
      {deleteTarget && (
        <ConfirmModal
          isOpen={true}
          onClose={() => setDeleteTarget(null)}
          onConfirm={() => deleteUser(deleteTarget.id)}
          title={`Delete "${deleteTarget.name}"?`}
          message={`Are you sure you want to remove ${deleteTarget.name} and unassign their dispenser unit?`}
          confirmText="Delete User"
          isDanger={true}
        />
      )}

    </div>
  );
}
