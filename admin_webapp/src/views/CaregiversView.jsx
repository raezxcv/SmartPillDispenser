import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import { ConfirmModal } from '../components/ConfirmModal';
import { HeartHandshake, UserPlus, Phone, Mail, Edit2, Trash2, X, Search } from 'lucide-react';

export function CaregiversView() {
  const { caregivers, users, createContact, updateContact, deleteContact, showToast } = useApp();

  const [searchTerm, setSearchTerm] = useState('');
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [editingContact, setEditingContact] = useState(null);
  const [deleteTarget, setDeleteTarget] = useState(null);

  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    email: '',
    patientName: '',
    patientId: '',
    relationship: 'Family Member',
    pairingStatus: 'paired',
    smsAlerts: true
  });

  const filteredCaregivers = caregivers.filter((cg) => {
    const term = searchTerm.toLowerCase();
    return (
      !searchTerm ||
      (cg.name || '').toLowerCase().includes(term) ||
      (cg.patientName || '').toLowerCase().includes(term) ||
      (cg.phone || '').toLowerCase().includes(term)
    );
  });

  const handleOpenAdd = () => {
    setFormData({
      name: '',
      phone: '',
      email: '',
      patientName: users[0]?.name || 'Amara Reyes',
      patientId: users[0]?.id || 'usr_01',
      relationship: 'Family Member',
      pairingStatus: 'paired',
      smsAlerts: true
    });
    setIsAddOpen(true);
  };

  const handleOpenEdit = (contact) => {
    setEditingContact(contact);
    setFormData({
      name: contact.name || '',
      phone: contact.phone || '',
      email: contact.email || '',
      patientName: contact.patientName || '',
      patientId: contact.patientId || '',
      relationship: contact.relationship || 'Family Member',
      pairingStatus: contact.pairingStatus || 'paired',
      smsAlerts: contact.smsAlerts ?? true
    });
  };

  const handleSaveAdd = async (e) => {
    e.preventDefault();
    if (!formData.name.trim() || !formData.phone.trim()) {
      showToast('Please enter at least Name and Phone', 'error');
      return;
    }
    await createContact(formData);
    setIsAddOpen(false);
  };

  const handleSaveEdit = async (e) => {
    e.preventDefault();
    if (!editingContact) return;
    await updateContact(editingContact.id, formData);
    setEditingContact(null);
  };

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      
      {/* ── Header ── */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
            Caregiver Contacts
          </h1>
          <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
            Verified family members, trusted caregivers and emergency dispatch recipients.
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
          <UserPlus size={17} strokeWidth={2.4} /> + Add Caregiver Contact
        </button>
      </div>

      {/* ── Search Toolbar ── */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px', flexWrap: 'wrap' }}>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            backgroundColor: '#FFFFFF',
            border: '1px solid #E6EFE9',
            borderRadius: '12px',
            padding: '0 14px',
            height: '42px',
            flex: 1,
            maxWidth: '380px'
          }}
        >
          <Search size={16} style={{ color: '#9CA3AF' }} />
          <input
            type="text"
            placeholder="Search by contact name, patient, or phone..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            style={{
              border: 'none',
              outline: 'none',
              fontSize: '13.5px',
              color: '#111827',
              width: '100%',
              backgroundColor: 'transparent'
            }}
          />
        </div>

        <div style={{ fontSize: '13px', color: '#6B7280', fontWeight: '500' }}>
          Showing <strong>{filteredCaregivers.length}</strong> caregiver contacts
        </div>
      </div>

      {/* ── Caregivers Table ── */}
      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', overflow: 'hidden', boxShadow: 'var(--shadow-card)' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '13.5px' }}>
          <thead>
            <tr style={{ borderBottom: '1px solid #E6EFE9', backgroundColor: '#F9FBFA' }}>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Caregiver</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Assigned Patient</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Relationship</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Phone Number</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Pairing Status</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>SMS Dispatch</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase', textAlign: 'right' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredCaregivers.length === 0 ? (
              <tr>
                <td colSpan={7} style={{ padding: '48px 24px', textAlign: 'center' }}>
                  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
                    <HeartHandshake size={36} color="#9CA3AF" style={{ marginBottom: '10px' }} />
                    <div style={{ fontSize: '15px', fontWeight: '700', color: '#111827' }}>No caregiver contacts yet</div>
                    <div style={{ fontSize: '13px', color: '#6B7280', marginTop: '4px' }}>
                      Click <strong>+ Add Caregiver Contact</strong> to register trusted family members.
                    </div>
                  </div>
                </td>
              </tr>
            ) : (
              filteredCaregivers.map((cg, idx) => (
                <tr key={cg.id} style={{ borderBottom: idx === filteredCaregivers.length - 1 ? 'none' : '1px solid #F0F5F2' }}>
                  <td style={{ padding: '16px 20px' }}>
                    <div style={{ fontWeight: '700', color: '#111827' }}>{cg.name}</div>
                    <div style={{ fontSize: '12px', color: '#6B7280' }}>{cg.email || '—'}</div>
                  </td>
                  <td style={{ padding: '16px 20px', fontWeight: '700', color: '#111827' }}>
                    {cg.patientName}
                  </td>
                  <td style={{ padding: '16px 20px', color: '#4B5563' }}>
                    {cg.relationship}
                  </td>
                  <td style={{ padding: '16px 20px', color: '#374151', fontFamily: 'monospace' }}>
                    {cg.phone}
                  </td>
                  <td style={{ padding: '16px 20px' }}>
                    <StatusBadge status={cg.pairingStatus === 'paired' ? 'active' : 'warning'} />
                  </td>
                  <td style={{ padding: '16px 20px' }}>
                    <span style={{ fontSize: '12px', fontWeight: '600', color: cg.smsAlerts ? '#059669' : '#9CA3AF' }}>
                      {cg.smsAlerts ? '✓ Enabled' : 'Disabled'}
                    </span>
                  </td>
                  <td style={{ padding: '16px 20px', textAlign: 'right' }}>
                    <div style={{ display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
                      <button
                        onClick={() => handleOpenEdit(cg)}
                        title="Edit Contact"
                        style={{ padding: '6px', border: 'none', background: 'none', color: '#6B7280', cursor: 'pointer', borderRadius: '6px' }}
                      >
                        <Edit2 size={16} />
                      </button>
                      <button
                        onClick={() => setDeleteTarget(cg)}
                        title="Delete Contact"
                        style={{ padding: '6px', border: 'none', background: 'none', color: '#9CA3AF', cursor: 'pointer', borderRadius: '6px' }}
                        onMouseEnter={(e) => { e.currentTarget.style.color = '#DC2626'; }}
                        onMouseLeave={(e) => { e.currentTarget.style.color = '#9CA3AF'; }}
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* ── ADD CAREGIVER MODAL (Portal) ── */}
      {isAddOpen &&
        createPortal(
          <div className="modal-overlay" onClick={() => setIsAddOpen(false)}>
            <div className="modal-dialog" style={{ maxWidth: '440px' }} onClick={(e) => e.stopPropagation()}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <div style={{ width: '38px', height: '38px', borderRadius: '10px', backgroundColor: '#ECFDF5', color: '#059669', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <HeartHandshake size={20} strokeWidth={2.4} />
                  </div>
                  <div>
                    <h3 style={{ fontSize: '17px', fontWeight: '800', color: '#111827', margin: 0 }}>
                      Add Caregiver Contact
                    </h3>
                    <p style={{ fontSize: '12px', color: '#6B7280', margin: '2px 0 0' }}>
                      Register trusted contact for emergency dispatch.
                    </p>
                  </div>
                </div>
                <button onClick={() => setIsAddOpen(false)} style={{ background: 'none', border: 'none', color: '#9CA3AF', cursor: 'pointer', padding: '6px' }}>
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleSaveAdd} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#374151', marginBottom: '5px' }}>
                    Caregiver Name *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Carlos Reyes"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    style={{ width: '100%', height: '42px', padding: '0 14px', borderRadius: '10px', border: '1px solid #D1D5DB', fontSize: '13.5px', outline: 'none', boxSizing: 'border-box' }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#374151', marginBottom: '5px' }}>
                    Phone Number *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="+63 917 555 0199"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    style={{ width: '100%', height: '42px', padding: '0 14px', borderRadius: '10px', border: '1px solid #D1D5DB', fontSize: '13.5px', outline: 'none', boxSizing: 'border-box' }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#374151', marginBottom: '5px' }}>
                    Assigned Patient
                  </label>
                  <select
                    value={formData.patientName}
                    onChange={(e) => setFormData({ ...formData, patientName: e.target.value })}
                    style={{ width: '100%', height: '42px', padding: '0 14px', borderRadius: '10px', border: '1px solid #D1D5DB', fontSize: '13.5px', outline: 'none', boxSizing: 'border-box', backgroundColor: '#FFFFFF' }}
                  >
                    {users.map((u) => (
                      <option key={u.id} value={u.name}>{u.name}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#374151', marginBottom: '5px' }}>
                    Relationship
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Spouse, Daughter, Son"
                    value={formData.relationship}
                    onChange={(e) => setFormData({ ...formData, relationship: e.target.value })}
                    style={{ width: '100%', height: '42px', padding: '0 14px', borderRadius: '10px', border: '1px solid #D1D5DB', fontSize: '13.5px', outline: 'none', boxSizing: 'border-box' }}
                  />
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '8px' }}>
                  <button type="button" onClick={() => setIsAddOpen(false)} style={{ height: '40px', padding: '0 18px', borderRadius: '10px', border: '1px solid #D1D5DB', backgroundColor: '#FFFFFF', color: '#4B5563', fontSize: '13px', fontWeight: '600', cursor: 'pointer' }}>
                    Cancel
                  </button>
                  <button type="submit" style={{ height: '40px', padding: '0 22px', borderRadius: '10px', border: 'none', backgroundColor: '#10B981', color: '#FFFFFF', fontSize: '13.5px', fontWeight: '700', cursor: 'pointer', boxShadow: '0 3px 10px rgba(16, 185, 129, 0.3)' }}>
                    Save Contact
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ── EDIT CAREGIVER MODAL (Portal) ── */}
      {editingContact &&
        createPortal(
          <div className="modal-overlay" onClick={() => setEditingContact(null)}>
            <div className="modal-dialog" style={{ maxWidth: '440px' }} onClick={(e) => e.stopPropagation()}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <div style={{ width: '38px', height: '38px', borderRadius: '10px', backgroundColor: '#ECFDF5', color: '#059669', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <Edit2 size={20} strokeWidth={2.4} />
                  </div>
                  <div>
                    <h3 style={{ fontSize: '17px', fontWeight: '800', color: '#111827', margin: 0 }}>
                      Edit Caregiver Contact
                    </h3>
                    <p style={{ fontSize: '12px', color: '#6B7280', margin: '2px 0 0' }}>
                      Update caregiver information and assigned patient.
                    </p>
                  </div>
                </div>
                <button onClick={() => setEditingContact(null)} style={{ background: 'none', border: 'none', color: '#9CA3AF', cursor: 'pointer', padding: '6px' }}>
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleSaveEdit} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#374151', marginBottom: '5px' }}>
                    Caregiver Name
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    style={{ width: '100%', height: '42px', padding: '0 14px', borderRadius: '10px', border: '1px solid #D1D5DB', fontSize: '13.5px', outline: 'none', boxSizing: 'border-box' }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#374151', marginBottom: '5px' }}>
                    Phone Number
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    style={{ width: '100%', height: '42px', padding: '0 14px', borderRadius: '10px', border: '1px solid #D1D5DB', fontSize: '13.5px', outline: 'none', boxSizing: 'border-box' }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#374151', marginBottom: '5px' }}>
                    Assigned Patient
                  </label>
                  <select
                    value={formData.patientName}
                    onChange={(e) => setFormData({ ...formData, patientName: e.target.value })}
                    style={{ width: '100%', height: '42px', padding: '0 14px', borderRadius: '10px', border: '1px solid #D1D5DB', fontSize: '13.5px', outline: 'none', boxSizing: 'border-box', backgroundColor: '#FFFFFF' }}
                  >
                    {users.map((u) => (
                      <option key={u.id} value={u.name}>{u.name}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#374151', marginBottom: '5px' }}>
                    Relationship
                  </label>
                  <input
                    type="text"
                    value={formData.relationship}
                    onChange={(e) => setFormData({ ...formData, relationship: e.target.value })}
                    style={{ width: '100%', height: '42px', padding: '0 14px', borderRadius: '10px', border: '1px solid #D1D5DB', fontSize: '13.5px', outline: 'none', boxSizing: 'border-box' }}
                  />
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '8px' }}>
                  <button type="button" onClick={() => setEditingContact(null)} style={{ height: '40px', padding: '0 18px', borderRadius: '10px', border: '1px solid #D1D5DB', backgroundColor: '#FFFFFF', color: '#4B5563', fontSize: '13px', fontWeight: '600', cursor: 'pointer' }}>
                    Cancel
                  </button>
                  <button type="submit" style={{ height: '40px', padding: '0 22px', borderRadius: '10px', border: 'none', backgroundColor: '#10B981', color: '#FFFFFF', fontSize: '13.5px', fontWeight: '700', cursor: 'pointer', boxShadow: '0 3px 10px rgba(16, 185, 129, 0.3)' }}>
                    Update Contact
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ── DELETE CONFIRMATION MODAL ── */}
      {deleteTarget && (
        <ConfirmModal
          isOpen={true}
          onClose={() => setDeleteTarget(null)}
          onConfirm={() => deleteContact(deleteTarget.id, deleteTarget.name)}
          title={`Delete "${deleteTarget.name}"?`}
          message={`Are you sure you want to remove ${deleteTarget.name} from caregiver contacts?`}
          confirmText="Delete Contact"
          isDanger={true}
        />
      )}

    </div>
  );
}
