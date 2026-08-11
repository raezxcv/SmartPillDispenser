import React from 'react';
import { useApp } from '../context/AppContext';
import { Pill, Clock, Calendar, CheckCircle2 } from 'lucide-react';

export function MedicationView() {
  const { medications } = useApp();

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      <div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
          Medication Schedules
        </h1>
        <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
          Active prescription schedules, dispenser compartment mapping and compliance metrics.
        </p>
      </div>

      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', overflow: 'hidden', boxShadow: 'var(--shadow-card)' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '13.5px' }}>
          <thead>
            <tr style={{ borderBottom: '1px solid #E6EFE9', backgroundColor: '#F9FBFA' }}>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Patient / Dispenser</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Medication</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Compartment</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Dispense Time</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Pills Left</th>
              <th style={{ padding: '14px 20px', fontWeight: '700', color: '#6B7280', fontSize: '11.5px', textTransform: 'uppercase' }}>Adherence</th>
            </tr>
          </thead>
          <tbody>
            {medications.map((m, idx) => (
              <tr key={m.id} style={{ borderBottom: idx === medications.length - 1 ? 'none' : '1px solid #F0F5F2' }}>
                <td style={{ padding: '16px 20px' }}>
                  <div style={{ fontWeight: '700', color: '#111827' }}>{m.patientName}</div>
                  <div style={{ fontSize: '12px', color: '#9CA3AF', fontFamily: 'monospace' }}>{m.deviceId}</div>
                </td>
                <td style={{ padding: '16px 20px' }}>
                  <div style={{ fontWeight: '600', color: '#111827' }}>{m.name}</div>
                  <div style={{ fontSize: '12px', color: '#6B7280' }}>{m.dosage}</div>
                </td>
                <td style={{ padding: '16px 20px' }}>
                  <span style={{ padding: '3px 8px', borderRadius: '6px', backgroundColor: '#ECFDF5', color: '#059669', fontWeight: '700', fontSize: '12px', fontFamily: 'monospace' }}>
                    {m.compartment}
                  </span>
                </td>
                <td style={{ padding: '16px 20px', color: '#374151', fontWeight: '500' }}>
                  {m.time} ({m.frequency})
                </td>
                <td style={{ padding: '16px 20px' }}>
                  <span style={{ fontWeight: '700', color: m.pillsLeft === 0 ? '#DC2626' : m.pillsLeft < 15 ? '#D97706' : '#059669' }}>
                    {m.pillsLeft} pills
                  </span>
                </td>
                <td style={{ padding: '16px 20px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <div style={{ width: '60px', height: '6px', backgroundColor: '#E5E7EB', borderRadius: '3px', overflow: 'hidden' }}>
                      <div style={{ width: `${m.adherence}%`, height: '100%', backgroundColor: m.adherence >= 80 ? '#10B981' : '#F59E0B' }} />
                    </div>
                    <span style={{ fontWeight: '600', color: '#111827', fontSize: '12.5px' }}>{m.adherence}%</span>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
