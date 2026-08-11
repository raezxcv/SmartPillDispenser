import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import { Bell, Check, Trash2, Filter } from 'lucide-react';

export function AlertsView() {
  const { alerts, resolveAlert, dismissAlert } = useApp();
  const [filterSev, setFilterSev] = useState('');

  const filtered = alerts.filter(a => !filterSev || a.severity === filterSev);

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
            Alerts & Notifications
          </h1>
          <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
            Active medication delays, hardware faults, compartment stock alerts and SOS triggers.
          </p>
        </div>

        <select
          value={filterSev}
          onChange={(e) => setFilterSev(e.target.value)}
          style={{
            height: '38px',
            padding: '0 12px',
            backgroundColor: '#FFFFFF',
            border: '1px solid #E6EFE9',
            borderRadius: '8px',
            fontSize: '13px',
            color: '#4B5563',
            outline: 'none',
            cursor: 'pointer'
          }}
        >
          <option value="">All Severities</option>
          <option value="critical">Critical</option>
          <option value="warning">Warning</option>
          <option value="info">Info</option>
        </select>
      </div>

      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', overflow: 'hidden', boxShadow: 'var(--shadow-card)' }}>
        {filtered.length === 0 ? (
          <div style={{ padding: '48px 24px', textAlign: 'center', color: '#059669', fontSize: '14px', fontWeight: '600' }}>
            ✓ All clear! No unresolved alerts at this time.
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {filtered.map((alt, idx) => (
              <div
                key={alt.id}
                style={{
                  padding: '18px 24px',
                  borderBottom: idx === filtered.length - 1 ? 'none' : '1px solid #F0F5F2',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  gap: '16px',
                  flexWrap: 'wrap'
                }}
              >
                <div style={{ flex: 1, minWidth: '240px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
                    <span style={{ fontSize: '15px', fontWeight: '700', color: '#111827' }}>
                      {alt.title}
                    </span>
                    <StatusBadge status={alt.severity} />
                  </div>
                  <p style={{ fontSize: '13px', color: '#4B5563', lineHeight: '1.4', marginBottom: '4px' }}>
                    {alt.message}
                  </p>
                  <div style={{ fontSize: '11.5px', color: '#9CA3AF' }}>
                    Patient: <strong>{alt.patientName}</strong> • Device: <code>{alt.deviceId}</code> • {alt.timeAgo}
                  </div>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <button
                    onClick={() => resolveAlert(alt.id)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '5px',
                      padding: '7px 14px',
                      backgroundColor: '#ECFDF5',
                      color: '#059669',
                      border: '1px solid #A7F3D0',
                      borderRadius: '8px',
                      fontSize: '12.5px',
                      fontWeight: '600',
                      cursor: 'pointer'
                    }}
                  >
                    <Check size={14} /> Resolve
                  </button>
                  <button
                    onClick={() => dismissAlert(alt.id)}
                    style={{
                      padding: '7px 12px',
                      backgroundColor: '#FFFFFF',
                      color: '#6B7280',
                      border: '1px solid #E5E7EB',
                      borderRadius: '8px',
                      fontSize: '12.5px',
                      fontWeight: '500',
                      cursor: 'pointer'
                    }}
                  >
                    Dismiss
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
