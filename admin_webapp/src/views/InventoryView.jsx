import React, { useState, useEffect, useRef } from 'react';
import { createPortal } from 'react-dom';
import { useApp } from '../context/AppContext';
import { ConfirmModal } from '../components/ConfirmModal';
import {
  Package,
  Plus,
  Edit2,
  Trash2,
  X,
  Search,
  CheckCircle2,
  AlertTriangle,
  XCircle,
  MoreVertical,
  RotateCcw
} from 'lucide-react';

export function InventoryView() {
  const { compartments, users, devices, saveCompartment, clearCompartment, refillCompartmentSlot, showToast, darkMode } = useApp();

  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [activeMenuSlot, setActiveMenuSlot] = useState(null);
  const menuRef = useRef(null);

  // Close 3-dot menu on outside click
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (menuRef.current && !menuRef.current.contains(e.target)) {
        setActiveMenuSlot(null);
      }
    };
    if (activeMenuSlot) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [activeMenuSlot]);

  // Modal states
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingComp, setEditingComp] = useState(null);
  const [clearTarget, setClearTarget] = useState(null);

  const [formData, setFormData] = useState({
    compartmentNumber: 1,
    medicationName: '',
    dosage: '',
    stockCount: 20,
    maxCapacity: 30,
    patientName: '',
    patientUid: '',
    deviceId: '',
    scheduleTime: '08:00 AM',
    frequency: 'Daily'
  });

  const openConfigureModal = (comp = null, defaultSlot = 1) => {
    setActiveMenuSlot(null);
    if (comp) {
      setEditingComp(comp);
      setFormData({
        compartmentNumber: comp.compartmentNumber || 1,
        medicationName: comp.medicationName || '',
        dosage: comp.dosage || '',
        stockCount: comp.stockCount ?? 20,
        maxCapacity: comp.maxCapacity || 30,
        patientName: comp.patientName || (users[0]?.name || 'Unassigned'),
        patientUid: comp.patientUid || (users[0]?.id || ''),
        deviceId: comp.deviceId || (devices[0]?.deviceId || 'SD-0119'),
        scheduleTime: comp.scheduleTime || '08:00 AM',
        frequency: comp.frequency || 'Daily'
      });
    } else {
      setEditingComp(null);
      setFormData({
        compartmentNumber: defaultSlot,
        medicationName: '',
        dosage: '',
        stockCount: 30,
        maxCapacity: 30,
        patientName: users[0]?.name || 'Unassigned',
        patientUid: users[0]?.id || '',
        deviceId: devices[0]?.deviceId || 'SD-0119',
        scheduleTime: '08:00 AM',
        frequency: 'Daily'
      });
    }
    setIsModalOpen(true);
  };

  const handleFormSubmit = async (e) => {
    e.preventDefault();
    if (!formData.medicationName.trim()) {
      showToast('Please enter a medication name', 'error');
      return;
    }
    await saveCompartment(formData);
    setIsModalOpen(false);
  };

  const handleClearConfirm = async () => {
    if (clearTarget) {
      await clearCompartment(clearTarget.compartmentNumber);
      setClearTarget(null);
    }
  };

  const filteredCompartments = compartments.filter(item => {
    const matchSearch =
      !search ||
      item.comp.toLowerCase().includes(search.toLowerCase()) ||
      (item.medicationName || '').toLowerCase().includes(search.toLowerCase()) ||
      (item.patientName || '').toLowerCase().includes(search.toLowerCase()) ||
      (item.deviceId || '').toLowerCase().includes(search.toLowerCase());

    let matchStatus = true;
    if (statusFilter === 'good') matchStatus = item.status === 'good';
    else if (statusFilter === 'low') matchStatus = item.status === 'low';
    else if (statusFilter === 'empty') matchStatus = item.status === 'empty' || item.stockCount === 0;

    return matchSearch && matchStatus;
  });

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      
      {/* ── Page Header ── */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--text-main)', letterSpacing: '-0.02em', marginBottom: '4px' }}>
            Compartment inventory
          </h1>
          <p style={{ fontSize: '13.5px', color: 'var(--text-subtle)' }}>
            SmartDose 10-compartment hardware slots, assigned medications, and stock capacity.
          </p>
        </div>

        <button
          onClick={() => openConfigureModal(null, 1)}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            padding: '10px 18px',
            borderRadius: '12px',
            border: 'none',
            backgroundColor: '#00A36C',
            color: '#FFFFFF',
            fontSize: '13.5px',
            fontWeight: '700',
            cursor: 'pointer',
            boxShadow: '0 4px 14px rgba(0, 163, 108, 0.3)',
            transition: 'all 0.15s ease'
          }}
          onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = '#008b5c')}
          onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = '#00A36C')}
        >
          <Plus size={17} strokeWidth={2.4} /> + Add / Configure Compartment
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
              placeholder="Search by compartment, medication, or patient..."
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
              fontWeight: '600',
              outline: 'none',
              cursor: 'pointer'
            }}
          >
            <option value="">All Statuses</option>
            <option value="good">Well Stocked</option>
            <option value="low">Low Stock</option>
            <option value="empty">Empty</option>
          </select>
        </div>

        <div style={{ fontSize: '13px', color: 'var(--text-subtle)', fontWeight: '500' }}>
          Showing <strong>{filteredCompartments.length}</strong> of 10 compartments
        </div>
      </div>

      {/* ── Main 10-Compartment Table (overflow: visible to avoid clipping dropdowns) ── */}
      <div
        style={{
          backgroundColor: 'var(--bg-card)',
          border: '1px solid var(--border-light)',
          borderRadius: '18px',
          boxShadow: 'var(--shadow-card)',
          position: 'relative'
        }}
      >
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '13.5px' }}>
          <thead>
            <tr style={{ borderBottom: '1px solid var(--border-light)', backgroundColor: 'var(--bg-subtle)' }}>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase', borderTopLeftRadius: '18px' }}>Slot</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase' }}>Assigned Medication</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase' }}>Stock Fill Level</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase' }}>Status</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase' }}>Patient & Dispenser</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase' }}>Schedule</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase', textAlign: 'right', borderTopRightRadius: '18px' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredCompartments.map((comp, idx) => {
              const stock = comp.stockCount ?? 0;
              const maxCap = comp.maxCapacity || 30;
              const fillPct = Math.min(100, Math.round((stock / maxCap) * 100));
              const isEmpty = stock === 0 || !comp.medicationName;
              const isLow = stock > 0 && stock <= 5;
              const isMenuOpen = activeMenuSlot === comp.compartmentNumber;
              const isNearBottom = idx >= filteredCompartments.length - 3;

              return (
                <tr
                  key={comp.id || comp.compartmentNumber}
                  style={{
                    borderBottom: idx === filteredCompartments.length - 1 ? 'none' : '1px solid var(--border-light)',
                    position: isMenuOpen ? 'relative' : 'static',
                    zIndex: isMenuOpen ? 50 : 1
                  }}
                >
                  {/* Slot Badge */}
                  <td style={{ padding: '16px 20px' }}>
                    <span
                      style={{
                        padding: '4px 10px',
                        borderRadius: '8px',
                        backgroundColor: darkMode ? 'rgba(16, 185, 129, 0.2)' : '#ECFDF5',
                        color: darkMode ? '#34D399' : '#00A36C',
                        fontWeight: '800',
                        fontSize: '13px',
                        fontFamily: 'monospace'
                      }}
                    >
                      C{comp.compartmentNumber}
                    </span>
                  </td>

                  {/* Assigned Medication */}
                  <td style={{ padding: '16px 20px' }}>
                    {comp.medicationName ? (
                      <div>
                        <div style={{ fontWeight: '700', color: 'var(--text-main)' }}>{comp.medicationName}</div>
                        <div style={{ fontSize: '12px', color: 'var(--text-subtle)' }}>{comp.dosage || 'Standard dose'}</div>
                      </div>
                    ) : (
                      <span style={{ color: 'var(--text-faint)', fontStyle: 'italic' }}>Unassigned Slot</span>
                    )}
                  </td>

                  {/* Stock Fill Level Bar */}
                  <td style={{ padding: '16px 20px', minWidth: '180px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', marginBottom: '4px' }}>
                      <span style={{ fontWeight: '700', color: isEmpty ? '#DC2626' : isLow ? '#D97706' : 'var(--text-main)' }}>
                        {stock} / {maxCap} pills
                      </span>
                      <span style={{ color: 'var(--text-subtle)' }}>{fillPct}%</span>
                    </div>
                    <div style={{ height: '7px', width: '100%', backgroundColor: 'var(--border-input)', borderRadius: '4px', overflow: 'hidden' }}>
                      <div
                        style={{
                          width: `${fillPct}%`,
                          height: '100%',
                          backgroundColor: isEmpty ? '#EF4444' : isLow ? '#F59E0B' : '#10B981',
                          borderRadius: '4px',
                          transition: 'width 0.3s ease'
                        }}
                      />
                    </div>
                  </td>

                  {/* Status Badge */}
                  <td style={{ padding: '16px 20px' }}>
                    {isEmpty ? (
                      <span
                        style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '5px',
                          padding: '4px 10px',
                          borderRadius: '8px',
                          backgroundColor: darkMode ? 'rgba(239, 68, 68, 0.18)' : '#FEE2E2',
                          color: darkMode ? '#F87171' : '#DC2626',
                          border: darkMode ? '1px solid rgba(239, 68, 68, 0.35)' : '1px solid #FECACA',
                          fontSize: '12px',
                          fontWeight: '700'
                        }}
                      >
                        <XCircle size={13} /> Empty
                      </span>
                    ) : isLow ? (
                      <span
                        style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '5px',
                          padding: '4px 10px',
                          borderRadius: '8px',
                          backgroundColor: darkMode ? 'rgba(245, 158, 11, 0.18)' : '#FEF3C7',
                          color: darkMode ? '#FBBF24' : '#B45309',
                          border: darkMode ? '1px solid rgba(245, 158, 11, 0.35)' : '1px solid #FDE68A',
                          fontSize: '12px',
                          fontWeight: '700'
                        }}
                      >
                        <AlertTriangle size={13} /> Low Stock
                      </span>
                    ) : (
                      <span
                        style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '5px',
                          padding: '4px 10px',
                          borderRadius: '8px',
                          backgroundColor: darkMode ? 'rgba(16, 185, 129, 0.18)' : '#D1FAE5',
                          color: darkMode ? '#34D399' : '#047857',
                          border: darkMode ? '1px solid rgba(16, 185, 129, 0.35)' : '1px solid #A7F3D0',
                          fontSize: '12px',
                          fontWeight: '700'
                        }}
                      >
                        <CheckCircle2 size={13} /> Well Stocked
                      </span>
                    )}
                  </td>

                  {/* Patient & Dispenser */}
                  <td style={{ padding: '16px 20px' }}>
                    <div style={{ fontWeight: '600', color: 'var(--text-main)' }}>{comp.patientName || 'Unassigned'}</div>
                    <div style={{ fontSize: '11.5px', color: 'var(--text-faint)', fontFamily: 'monospace' }}>{comp.deviceId}</div>
                  </td>

                  {/* Schedule */}
                  <td style={{ padding: '16px 20px', color: 'var(--text-muted)', fontSize: '12.5px' }}>
                    {comp.scheduleTime && comp.scheduleTime !== '--:--' ? (
                      <div>
                        <strong>{comp.scheduleTime}</strong>
                        <div style={{ color: 'var(--text-faint)', fontSize: '11.5px' }}>{comp.frequency}</div>
                      </div>
                    ) : (
                      <span style={{ color: 'var(--text-faint)' }}>--:--</span>
                    )}
                  </td>

                  {/* 3-Dot Actions Menu */}
                  <td style={{ padding: '16px 20px', textAlign: 'right', position: 'relative', zIndex: isMenuOpen ? 100 : 'auto' }}>
                    <div style={{ display: 'inline-block', position: 'relative' }}>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          setActiveMenuSlot(isMenuOpen ? null : comp.compartmentNumber);
                        }}
                        title="More options"
                        style={{
                          padding: '6px',
                          borderRadius: '8px',
                          border: '1px solid var(--border-light)',
                          backgroundColor: isMenuOpen ? 'var(--bg-hover)' : 'transparent',
                          color: 'var(--text-muted)',
                          cursor: 'pointer',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          transition: 'all 0.15s'
                        }}
                        onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = 'var(--bg-hover)')}
                        onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = isMenuOpen ? 'var(--bg-hover)' : 'transparent')}
                      >
                        <MoreVertical size={16} />
                      </button>

                      {/* 3-Dot Popover Menu (Smart Upward/Downward Positioning) */}
                      {isMenuOpen && (
                        <div
                          ref={menuRef}
                          style={{
                            position: 'absolute',
                            ...(isNearBottom ? { bottom: '38px', top: 'auto' } : { top: '38px', bottom: 'auto' }),
                            right: 0,
                            width: '190px',
                            backgroundColor: 'var(--bg-card)',
                            borderRadius: '12px',
                            border: '1px solid var(--border-light)',
                            boxShadow: '0 12px 28px rgba(0, 0, 0, 0.28), 0 4px 10px rgba(0, 0, 0, 0.15)',
                            padding: '6px',
                            zIndex: 9999,
                            display: 'flex',
                            flexDirection: 'column',
                            gap: '3px',
                            animation: 'scaleUpModal 0.15s ease-out forwards'
                          }}
                          onClick={(e) => e.stopPropagation()}
                        >
                          {/* Edit / Configure Option */}
                          <button
                            onClick={() => {
                              setActiveMenuSlot(null);
                              openConfigureModal(comp, comp.compartmentNumber);
                            }}
                            style={{
                              display: 'flex',
                              alignItems: 'center',
                              gap: '8px',
                              width: '100%',
                              padding: '8px 10px',
                              border: 'none',
                              borderRadius: '8px',
                              backgroundColor: 'transparent',
                              color: 'var(--text-main)',
                              fontSize: '12.5px',
                              fontWeight: '600',
                              cursor: 'pointer',
                              textAlign: 'left',
                              transition: 'background 0.15s'
                            }}
                            onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = 'var(--bg-hover)')}
                            onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = 'transparent')}
                          >
                            <Edit2 size={14} color="#059669" />
                            <span>Edit / Configure</span>
                          </button>

                          {/* Refill to Full Option */}
                          <button
                            onClick={() => {
                              setActiveMenuSlot(null);
                              refillCompartmentSlot(comp.compartmentNumber);
                            }}
                            style={{
                              display: 'flex',
                              alignItems: 'center',
                              gap: '8px',
                              width: '100%',
                              padding: '8px 10px',
                              border: 'none',
                              borderRadius: '8px',
                              backgroundColor: 'transparent',
                              color: '#00A36C',
                              fontSize: '12.5px',
                              fontWeight: '600',
                              cursor: 'pointer',
                              textAlign: 'left',
                              transition: 'background 0.15s'
                            }}
                            onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = 'var(--bg-hover)')}
                            onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = 'transparent')}
                          >
                            <RotateCcw size={14} color="#00A36C" />
                            <span>Refill to Full (30)</span>
                          </button>

                          {/* Clear Slot Option */}
                          {comp.medicationName && (
                            <button
                              onClick={() => {
                                setActiveMenuSlot(null);
                                setClearTarget(comp);
                              }}
                              style={{
                                display: 'flex',
                                alignItems: 'center',
                                gap: '8px',
                                width: '100%',
                                padding: '8px 10px',
                                border: 'none',
                                borderRadius: '8px',
                                backgroundColor: 'transparent',
                                color: '#DC2626',
                                fontSize: '12.5px',
                                fontWeight: '600',
                                cursor: 'pointer',
                                textAlign: 'left',
                                transition: 'background 0.15s'
                              }}
                              onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = '#FEE2E2')}
                              onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = 'transparent')}
                            >
                              <Trash2 size={14} color="#DC2626" />
                              <span>Clear Slot</span>
                            </button>
                          )}
                        </div>
                      )}
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* ── CONFIGURE COMPARTMENT MODAL ── */}
      {isModalOpen &&
        createPortal(
          <div className="modal-overlay" onClick={() => setIsModalOpen(false)}>
            <div className="modal-dialog" style={{ maxWidth: '480px' }} onClick={(e) => e.stopPropagation()}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <div style={{ width: '40px', height: '40px', borderRadius: '12px', backgroundColor: darkMode ? 'rgba(16, 185, 129, 0.2)' : '#ECFDF5', color: darkMode ? '#34D399' : '#00A36C', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <Package size={22} strokeWidth={2.4} />
                  </div>
                  <div>
                    <h3 style={{ fontSize: '18px', fontWeight: '800', color: 'var(--text-main)', margin: 0 }}>
                      {editingComp ? `Configure Compartment C${formData.compartmentNumber}` : 'Add / Set Compartment'}
                    </h3>
                    <p style={{ fontSize: '12px', color: 'var(--text-subtle)', margin: '2px 0 0' }}>
                      Assign medication, capacity and patient schedule to hardware slot.
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => setIsModalOpen(false)}
                  style={{ background: 'none', border: 'none', color: 'var(--text-faint)', cursor: 'pointer', padding: '6px' }}
                >
                  <X size={20} />
                </button>
              </div>

              <form onSubmit={handleFormSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                {/* Slot Selector & Patient */}
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '12px' }}>
                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '5px' }}>
                      Hardware Slot
                    </label>
                    <select
                      value={formData.compartmentNumber}
                      disabled={!!editingComp}
                      onChange={(e) => setFormData({ ...formData, compartmentNumber: Number(e.target.value) })}
                      style={{
                        width: '100%',
                        height: '42px',
                        padding: '0 10px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '13.5px',
                        fontWeight: '700',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    >
                      {Array.from({ length: 10 }, (_, i) => i + 1).map((num) => (
                        <option key={num} value={num}>Compartment {num} (C{num})</option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '5px' }}>
                      Assigned Patient
                    </label>
                    <select
                      value={formData.patientName}
                      onChange={(e) => {
                        const selectedUser = users.find(u => u.name === e.target.value);
                        setFormData({
                          ...formData,
                          patientName: e.target.value,
                          patientUid: selectedUser?.id || '',
                          deviceId: selectedUser?.deviceId || formData.deviceId
                        });
                      }}
                      style={{
                        width: '100%',
                        height: '42px',
                        padding: '0 12px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '13.5px',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    >
                      <option value="Unassigned">Unassigned</option>
                      {users.map((u) => (
                        <option key={u.id} value={u.name}>{u.name} ({u.deviceId || 'No Unit'})</option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Medication Name & Dosage */}
                <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '12px' }}>
                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '5px' }}>
                      Medication Name *
                    </label>
                    <input
                      type="text"
                      required
                      placeholder="e.g. Metformin"
                      value={formData.medicationName}
                      onChange={(e) => setFormData({ ...formData, medicationName: e.target.value })}
                      style={{
                        width: '100%',
                        height: '42px',
                        padding: '0 14px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '13.5px',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    />
                  </div>

                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '5px' }}>
                      Dosage
                    </label>
                    <input
                      type="text"
                      placeholder="500mg"
                      value={formData.dosage}
                      onChange={(e) => setFormData({ ...formData, dosage: e.target.value })}
                      style={{
                        width: '100%',
                        height: '42px',
                        padding: '0 12px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '13.5px',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    />
                  </div>
                </div>

                {/* Current Stock & Max Capacity */}
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '5px' }}>
                      Current Stock (Pills)
                    </label>
                    <input
                      type="number"
                      min="0"
                      max={formData.maxCapacity}
                      value={formData.stockCount}
                      onChange={(e) => setFormData({ ...formData, stockCount: Number(e.target.value) })}
                      style={{
                        width: '100%',
                        height: '42px',
                        padding: '0 12px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '13.5px',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    />
                  </div>

                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '5px' }}>
                      Max Slot Capacity
                    </label>
                    <input
                      type="number"
                      min="1"
                      max="100"
                      value={formData.maxCapacity}
                      onChange={(e) => setFormData({ ...formData, maxCapacity: Number(e.target.value) })}
                      style={{
                        width: '100%',
                        height: '42px',
                        padding: '0 12px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '13.5px',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    />
                  </div>
                </div>

                {/* Schedule Time & Frequency */}
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '5px' }}>
                      Daily Dispense Time
                    </label>
                    <input
                      type="text"
                      placeholder="08:00 AM"
                      value={formData.scheduleTime}
                      onChange={(e) => setFormData({ ...formData, scheduleTime: e.target.value })}
                      style={{
                        width: '100%',
                        height: '42px',
                        padding: '0 12px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '13.5px',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    />
                  </div>

                  <div>
                    <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: 'var(--text-muted)', marginBottom: '5px' }}>
                      Frequency
                    </label>
                    <select
                      value={formData.frequency}
                      onChange={(e) => setFormData({ ...formData, frequency: e.target.value })}
                      style={{
                        width: '100%',
                        height: '42px',
                        padding: '0 12px',
                        borderRadius: '10px',
                        border: '1px solid var(--border-input)',
                        backgroundColor: 'var(--bg-input)',
                        color: 'var(--text-main)',
                        fontSize: '13.5px',
                        outline: 'none',
                        boxSizing: 'border-box'
                      }}
                    >
                      <option value="Daily">Daily</option>
                      <option value="Twice Daily">Twice Daily</option>
                      <option value="Weekly">Weekly</option>
                      <option value="As Needed">As Needed</option>
                    </select>
                  </div>
                </div>

                {/* Submit Actions */}
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '10px' }}>
                  <button
                    type="button"
                    onClick={() => setIsModalOpen(false)}
                    style={{
                      height: '40px',
                      padding: '0 18px',
                      borderRadius: '10px',
                      border: '1px solid var(--border-input)',
                      backgroundColor: 'transparent',
                      color: 'var(--text-muted)',
                      fontSize: '13px',
                      fontWeight: '600',
                      cursor: 'pointer'
                    }}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    style={{
                      height: '40px',
                      padding: '0 22px',
                      borderRadius: '10px',
                      border: 'none',
                      backgroundColor: '#00A36C',
                      color: '#FFFFFF',
                      fontSize: '13.5px',
                      fontWeight: '700',
                      cursor: 'pointer',
                      boxShadow: '0 3px 10px rgba(0, 163, 108, 0.3)'
                    }}
                  >
                    Save Compartment
                  </button>
                </div>
              </form>
            </div>
          </div>,
          document.body
        )}

      {/* ── CLEAR COMPARTMENT CONFIRMATION ── */}
      {clearTarget && (
        <ConfirmModal
          isOpen={true}
          onClose={() => setClearTarget(null)}
          onConfirm={handleClearConfirm}
          title={`Clear Slot C${clearTarget.compartmentNumber}?`}
          message={`Are you sure you want to clear ${clearTarget.medicationName || `Slot C${clearTarget.compartmentNumber}`}? Stock count will be reset to 0.`}
          confirmText="Clear Slot"
          isDanger={true}
        />
      )}

    </div>
  );
}
