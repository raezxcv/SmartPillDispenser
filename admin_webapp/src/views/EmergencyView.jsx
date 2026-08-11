import React from 'react';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import { AlertTriangle, PhoneCall, Check, MessageSquare } from 'lucide-react';

export function EmergencyView() {
  const { emergencies, resolveEmergency } = useApp();

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      <div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
          Emergency Queue
        </h1>
        <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
          Manual SOS button triggers, critical medication escalation events and emergency dispatch status.
        </p>
      </div>

      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', overflow: 'hidden', boxShadow: 'var(--shadow-card)' }}>
        {emergencies.length === 0 ? (
          <div style={{ padding: '48px 24px', textAlign: 'center', color: '#059669', fontSize: '14px', fontWeight: '600' }}>
            ✓ No emergency events reported. All patients stable.
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {emergencies.map((emg, idx) => (
              <div
                key={emg.id}
                style={{
                  padding: '20px 24px',
                  borderBottom: idx === emergencies.length - 1 ? 'none' : '1px solid #F0F5F2',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  gap: '16px',
                  backgroundColor: emg.status === 'resolved' ? '#FFFFFF' : '#FFFDFD'
                }}
              >
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '6px' }}>
                    <span style={{ fontSize: '15.5px', fontWeight: '800', color: '#111827' }}>
                      {emg.patientName}
                    </span>
                    <span style={{ fontSize: '12px', fontFamily: 'monospace', color: '#6B7280' }}>
                      ({emg.deviceId})
                    </span>
                    <StatusBadge status={emg.status === 'resolved' ? 'active' : 'critical'} />
                  </div>
                  <p style={{ fontSize: '13.5px', color: '#374151', marginBottom: '4px' }}>
                    {emg.reason}
                  </p>
                  <div style={{ fontSize: '12px', color: '#9CA3AF', display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <span>{emg.timestamp}</span>
                    <span>•</span>
                    <span style={{ color: '#059669', display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <PhoneCall size={12} /> Caregiver alerted
                    </span>
                    <span>•</span>
                    <span style={{ color: '#059669', display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <MessageSquare size={12} /> SMS gateway dispatched
                    </span>
                  </div>
                </div>

                {emg.status !== 'resolved' && (
                  <button
                    onClick={() => resolveEmergency(emg.id)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '6px',
                      padding: '8px 16px',
                      borderRadius: '8px',
                      border: 'none',
                      backgroundColor: '#10B981',
                      color: '#FFFFFF',
                      fontSize: '13px',
                      fontWeight: '700',
                      cursor: 'pointer',
                      boxShadow: '0 2px 8px rgba(16, 185, 129, 0.3)'
                    }}
                  >
                    <Check size={16} /> Mark Handled
                  </button>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
