import React from 'react';
import { StatusBadge } from '../components/StatusBadge';
import { Cpu, Activity, HardDrive, Wifi, Server, CheckCircle2 } from 'lucide-react';

export function DiagnosticsView() {
  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      <div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
          Hardware & Cloud Diagnostics
        </h1>
        <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
          Microcontroller metrics, Raspberry Pi load, database query latency and network stability.
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '16px' }}>
        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '16px', padding: '20px', boxShadow: 'var(--shadow-card)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
            <span style={{ fontSize: '14px', fontWeight: '700', color: '#111827' }}>Firestore Read Latency</span>
            <StatusBadge status="good" />
          </div>
          <div style={{ fontSize: '26px', fontWeight: '800', color: '#059669' }}>42 ms</div>
          <div style={{ fontSize: '12px', color: '#9CA3AF', marginTop: '4px' }}>Region: asia-southeast1 (Singapore)</div>
        </div>

        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '16px', padding: '20px', boxShadow: 'var(--shadow-card)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
            <span style={{ fontSize: '14px', fontWeight: '700', color: '#111827' }}>ESP32 Heartbeat Success</span>
            <StatusBadge status="good" />
          </div>
          <div style={{ fontSize: '26px', fontWeight: '800', color: '#111827' }}>99.8%</div>
          <div style={{ fontSize: '12px', color: '#9CA3AF', marginTop: '4px' }}>5 of 6 active nodes transmitting</div>
        </div>

        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '16px', padding: '20px', boxShadow: 'var(--shadow-card)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
            <span style={{ fontSize: '14px', fontWeight: '700', color: '#111827' }}>Raspberry Pi Avg Load</span>
            <StatusBadge status="warning" />
          </div>
          <div style={{ fontSize: '26px', fontWeight: '800', color: '#D97706' }}>58%</div>
          <div style={{ fontSize: '12px', color: '#9CA3AF', marginTop: '4px' }}>SD-0120 under OpenCV video inference load</div>
        </div>
      </div>
    </div>
  );
}
