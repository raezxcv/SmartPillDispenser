import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import { Camera, ScanFace, CheckCircle2, AlertCircle, Play, Eye } from 'lucide-react';

export function CameraAIView() {
  const { users, showToast } = useApp();
  const [selectedFeed, setSelectedFeed] = useState('SD-0119');

  const patientsWithFace = users.filter(u => u.role === 'patient');

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      <div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
          Camera & AI Face Recognition
        </h1>
        <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
          Patient face recognition biometric status, camera video stream health and verification logs.
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '20px' }}>
        {/* Live Camera Stream Simulator */}
        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', padding: '20px', boxShadow: 'var(--shadow-card)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div className="pulse-live-dot" />
              <span style={{ fontSize: '14px', fontWeight: '700', color: '#111827' }}>Live Feed: {selectedFeed}</span>
            </div>
            <select
              value={selectedFeed}
              onChange={(e) => setSelectedFeed(e.target.value)}
              style={{ padding: '4px 10px', borderRadius: '6px', border: '1px solid #D1D5DB', fontSize: '12px' }}
            >
              <option value="SD-0119">SD-0119 (Amara Reyes)</option>
              <option value="SD-0120">SD-0120 (Joseph Tan)</option>
              <option value="SD-0121">SD-0121 (Miriam Cortez)</option>
            </select>
          </div>

          <div
            style={{
              height: '240px',
              backgroundColor: '#0F172A',
              borderRadius: '12px',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#94A3B8',
              position: 'relative',
              overflow: 'hidden'
            }}
          >
            <Camera size={38} strokeWidth={1.5} style={{ marginBottom: '10px', opacity: 0.6 }} />
            <span style={{ fontSize: '13px', fontWeight: '600' }}>SmartDose MJPEG Stream ({selectedFeed})</span>
            <span style={{ fontSize: '11px', color: '#64748B', marginTop: '2px' }}>AI Face Verification Model: Active (98.4% conf)</span>

            <div style={{ position: 'absolute', bottom: '12px', right: '14px', fontSize: '11px', color: '#10B981', fontFamily: 'monospace' }}>
              ● REC 1080p @ 30fps
            </div>
          </div>
        </div>

        {/* Enrollment Roster */}
        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', padding: '20px', boxShadow: 'var(--shadow-card)' }}>
          <h3 style={{ fontSize: '15px', fontWeight: '700', color: '#111827', marginBottom: '14px' }}>
            Biometric Enrollment Status
          </h3>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {patientsWithFace.map((p) => (
              <div
                key={p.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '10px 14px',
                  borderRadius: '10px',
                  backgroundColor: '#F9FBFA',
                  border: '1px solid #EEF3F0'
                }}
              >
                <div>
                  <div style={{ fontSize: '13.5px', fontWeight: '600', color: '#111827' }}>{p.name}</div>
                  <div style={{ fontSize: '11.5px', color: '#9CA3AF' }}>Dispenser: {p.deviceId || '—'}</div>
                </div>
                <StatusBadge status={p.faceEnrollmentStatus || 'not_started'} />
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
