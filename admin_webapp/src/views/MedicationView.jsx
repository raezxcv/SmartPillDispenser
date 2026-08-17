import React, { useState, useEffect, useRef } from 'react';
import { useApp } from '../context/AppContext';
import { SkeletonGenericPage } from '../components/SkeletonLoader';
import { Pill, Clock, MoreVertical, Send, Play, CheckCircle2 } from 'lucide-react';

export function MedicationView() {
  const { medications, remindPatient, triggerDispense, darkMode, initialLoading } = useApp();
  const [activeMenuId, setActiveMenuId] = useState(null);
  const menuRef = useRef(null);

  if (initialLoading) {
    return <SkeletonGenericPage title="Medication Schedules" />;
  }

  // Close 3-dot menu on outside click
  useEffect(() => {
    const handleOutside = (e) => {
      if (menuRef.current && !menuRef.current.contains(e.target)) {
        setActiveMenuId(null);
      }
    };
    if (activeMenuId) {
      document.addEventListener('mousedown', handleOutside);
    }
    return () => document.removeEventListener('mousedown', handleOutside);
  }, [activeMenuId]);

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      
      {/* ── Page Header ── */}
      <div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--text-main)', letterSpacing: '-0.02em', marginBottom: '4px' }}>
          Medication Schedules
        </h1>
        <p style={{ fontSize: '13.5px', color: 'var(--text-subtle)' }}>
          Active prescription schedules, dispenser compartment mapping, compliance metrics and remote dispense controls.
        </p>
      </div>

      {/* ── Table Card (Responsive Touch-Scroll Container) ── */}
      <div
        className="responsive-table-container"
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
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase', borderTopLeftRadius: '18px' }}>Patient / Dispenser</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase' }}>Medication</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase' }}>Compartment</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase' }}>Dispense Time</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase' }}>Pills Left</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase' }}>Adherence</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: 'var(--text-subtle)', fontSize: '11.5px', textTransform: 'uppercase', textAlign: 'right', borderTopRightRadius: '18px' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {medications.map((m, idx) => {
              const isMenuOpen = activeMenuId === m.id;
              const isNearBottom = idx >= medications.length - 2;

              return (
                <tr
                  key={m.id || idx}
                  style={{
                    borderBottom: idx === medications.length - 1 ? 'none' : '1px solid var(--border-light)',
                    position: isMenuOpen ? 'relative' : 'static',
                    zIndex: isMenuOpen ? 50 : 1
                  }}
                >
                  {/* Patient / Dispenser */}
                  <td style={{ padding: '16px 20px' }}>
                    <div style={{ fontWeight: '700', color: 'var(--text-main)' }}>{m.patientName}</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-faint)', fontFamily: 'monospace' }}>{m.deviceId}</div>
                  </td>

                  {/* Medication */}
                  <td style={{ padding: '16px 20px' }}>
                    <div style={{ fontWeight: '700', color: 'var(--text-main)' }}>{m.name}</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-subtle)' }}>{m.dosage}</div>
                  </td>

                  {/* Compartment */}
                  <td style={{ padding: '16px 20px' }}>
                    <span style={{ padding: '3px 8px', borderRadius: '6px', backgroundColor: darkMode ? 'rgba(16, 185, 129, 0.2)' : '#ECFDF5', color: darkMode ? '#34D399' : '#047857', fontWeight: '800', fontSize: '12px', fontFamily: 'monospace' }}>
                      {m.compartment}
                    </span>
                  </td>

                  {/* Dispense Time */}
                  <td style={{ padding: '16px 20px', color: 'var(--text-muted)', fontWeight: '500' }}>
                    {m.time} ({m.frequency})
                  </td>

                  {/* Pills Left */}
                  <td style={{ padding: '16px 20px' }}>
                    <span style={{ fontWeight: '700', color: m.pillsLeft === 0 ? '#DC2626' : m.pillsLeft < 15 ? '#D97706' : '#059669' }}>
                      {m.pillsLeft} pills
                    </span>
                  </td>

                  {/* Adherence */}
                  <td style={{ padding: '16px 20px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <div style={{ width: '60px', height: '6px', backgroundColor: 'var(--border-input)', borderRadius: '3px', overflow: 'hidden' }}>
                        <div style={{ width: `${m.adherence}%`, height: '100%', backgroundColor: m.adherence >= 80 ? '#10B981' : '#F59E0B' }} />
                      </div>
                      <span style={{ fontWeight: '700', color: 'var(--text-main)', fontSize: '12.5px' }}>{m.adherence}%</span>
                    </div>
                  </td>

                  {/* 3-Dot Actions Menu */}
                  <td style={{ padding: '16px 20px', textAlign: 'right', position: 'relative', zIndex: isMenuOpen ? 100 : 'auto' }}>
                    <div style={{ display: 'inline-block', position: 'relative' }}>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          setActiveMenuId(isMenuOpen ? null : m.id);
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
                            width: '180px',
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
                          {/* Remind Patient Option */}
                          <button
                            onClick={() => {
                              setActiveMenuId(null);
                              remindPatient(m);
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
                            <Send size={14} color="#059669" />
                            <span>Remind Patient</span>
                          </button>

                          {/* Dispense Now Option */}
                          <button
                            onClick={() => {
                              setActiveMenuId(null);
                              triggerDispense(m);
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
                            <Play size={14} color="#00A36C" />
                            <span>Dispense Now</span>
                          </button>
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

    </div>
  );
}
