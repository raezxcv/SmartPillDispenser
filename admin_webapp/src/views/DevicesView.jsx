import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import { Smartphone, BatteryCharging, Wifi, RotateCcw, Cpu, Camera, CheckCircle2 } from 'lucide-react';

export function DevicesView() {
  const { devices, showToast, addActivity } = useApp();
  const [rebootingId, setRebootingId] = useState(null);

  const handleRestart = (dev) => {
    setRebootingId(dev.id);
    showToast(`Sending reboot command to ${dev.deviceId}...`);
    setTimeout(() => {
      setRebootingId(null);
      showToast(`Dispenser ${dev.deviceId} restarted successfully`);
      addActivity(`Remote reboot initiated on dispenser`, dev.patientName, dev.deviceId);
    }, 2000);
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      <div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
          Device Fleet
        </h1>
        <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
          Smart Pill Dispenser units, controller connectivity, camera AI modules and battery telemetry.
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '16px' }}>
        {devices.map((dev) => (
          <div
            key={dev.id}
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #E6EFE9',
              borderRadius: '16px',
              padding: '20px',
              boxShadow: 'var(--shadow-card)',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              gap: '16px'
            }}
          >
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '10px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <div
                    style={{
                      width: '38px',
                      height: '38px',
                      borderRadius: '10px',
                      backgroundColor: '#ECFDF5',
                      color: '#059669',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}
                  >
                    <Smartphone size={20} strokeWidth={2.2} />
                  </div>
                  <div>
                    <div style={{ fontSize: '15px', fontWeight: '800', color: '#111827', fontFamily: 'monospace' }}>
                      {dev.deviceId}
                    </div>
                    <div style={{ fontSize: '12px', color: '#6B7280' }}>{dev.patientName}</div>
                  </div>
                </div>
                <StatusBadge status={dev.status} />
              </div>

              {/* Specs Grid */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px', marginTop: '14px' }}>
                <div style={{ padding: '8px 10px', backgroundColor: '#F9FBFA', borderRadius: '8px', fontSize: '12px' }}>
                  <span style={{ color: '#9CA3AF' }}>Battery: </span>
                  <strong style={{ color: '#111827' }}>{dev.battery}%</strong>
                </div>
                <div style={{ padding: '8px 10px', backgroundColor: '#F9FBFA', borderRadius: '8px', fontSize: '12px' }}>
                  <span style={{ color: '#9CA3AF' }}>IP: </span>
                  <strong style={{ color: '#111827', fontFamily: 'monospace' }}>{dev.ip}</strong>
                </div>
                <div style={{ padding: '8px 10px', backgroundColor: '#F9FBFA', borderRadius: '8px', fontSize: '12px' }}>
                  <span style={{ color: '#9CA3AF' }}>ESP32: </span>
                  <strong style={{ color: dev.esp32Status === 'online' ? '#059669' : '#DC2626' }}>{dev.esp32Status}</strong>
                </div>
                <div style={{ padding: '8px 10px', backgroundColor: '#F9FBFA', borderRadius: '8px', fontSize: '12px' }}>
                  <span style={{ color: '#9CA3AF' }}>RPi: </span>
                  <strong style={{ color: dev.rpiStatus === 'online' ? '#059669' : '#D97706' }}>{dev.rpiStatus}</strong>
                </div>
              </div>
            </div>

            {/* Actions Bar */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderTop: '1px solid #F0F5F2', paddingTop: '14px' }}>
              <div style={{ fontSize: '11.5px', color: '#9CA3AF' }}>
                Heartbeat: {dev.lastHeartbeat}
              </div>
              <button
                onClick={() => handleRestart(dev)}
                disabled={rebootingId === dev.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  padding: '6px 12px',
                  borderRadius: '8px',
                  border: '1px solid #E5E7EB',
                  backgroundColor: '#FFFFFF',
                  color: '#374151',
                  fontSize: '12px',
                  fontWeight: '600',
                  cursor: 'pointer'
                }}
              >
                <RotateCcw size={13} className={rebootingId === dev.id ? 'animate-spin' : ''} />
                {rebootingId === dev.id ? 'Restarting...' : 'Restart'}
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
