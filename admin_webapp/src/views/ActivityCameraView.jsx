import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import { Camera, ScanFace, Download, History, Search, Activity, Play, CheckCircle2 } from 'lucide-react';

export function ActivityCameraView() {
  const { activities, users, showToast } = useApp();
  const [selectedFeed, setSelectedFeed] = useState('SD-0119');
  const [search, setSearch] = useState('');
  const [activeSubTab, setActiveSubTab] = useState('all'); // 'all', 'camera', 'logs'

  const patientsWithFace = users.filter(u => u.role === 'patient');

  const filteredActivities = activities.filter(a =>
    !search ||
    a.title.toLowerCase().includes(search.toLowerCase()) ||
    a.patientName.toLowerCase().includes(search.toLowerCase()) ||
    a.deviceId.toLowerCase().includes(search.toLowerCase())
  );

  const handleExport = () => {
    showToast('Exporting activity logs...');
    const csv = ["Timestamp,Action,Patient,Device", ...activities.map(a => `"${a.timeAgo}","${a.title}","${a.patientName}","${a.deviceId}"`)].join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `smartdose_activity_logs_${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
            Activity & Camera AI
          </h1>
          <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
            Fleet-wide event audit logs combined with live dispenser camera feeds and AI biometric verification.
          </p>
        </div>

        <button
          onClick={handleExport}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            padding: '9px 16px',
            borderRadius: '8px',
            border: '1px solid #A7F3D0',
            backgroundColor: '#ECFDF5',
            color: '#059669',
            fontSize: '13px',
            fontWeight: '600',
            cursor: 'pointer'
          }}
        >
          <Download size={15} /> Export Audit Log
        </button>
      </div>

      {/* Camera & AI Section Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '18px' }}>
        {/* Live Camera Stream Card */}
        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', padding: '20px', boxShadow: 'var(--shadow-card)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div className="pulse-live-dot" />
              <span style={{ fontSize: '14px', fontWeight: '700', color: '#111827' }}>Live Feed: {selectedFeed}</span>
            </div>
            <select
              value={selectedFeed}
              onChange={(e) => setSelectedFeed(e.target.value)}
              style={{ padding: '4px 10px', borderRadius: '6px', border: '1px solid #D1D5DB', fontSize: '12px', outline: 'none' }}
            >
              <option value="SD-0119">SD-0119 (Amara Reyes)</option>
              <option value="SD-0120">SD-0120 (Joseph Tan)</option>
              <option value="SD-0121">SD-0121 (Miriam Cortez)</option>
            </select>
          </div>

          <div
            style={{
              height: '210px',
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
            <Camera size={34} strokeWidth={1.5} style={{ marginBottom: '8px', opacity: 0.7 }} />
            <span style={{ fontSize: '13px', fontWeight: '600', color: '#F1F5F9' }}>SmartDose MJPEG Stream ({selectedFeed})</span>
            <span style={{ fontSize: '11px', color: '#94A3B8', marginTop: '2px' }}>Face Verification Model: Active (98.4% conf)</span>

            <div style={{ position: 'absolute', bottom: '10px', right: '12px', fontSize: '11px', color: '#10B981', fontFamily: 'monospace' }}>
              ● REC 1080p @ 30fps
            </div>
          </div>
        </div>

        {/* Biometric Status Summary */}
        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', padding: '20px', boxShadow: 'var(--shadow-card)' }}>
          <h3 style={{ fontSize: '15px', fontWeight: '700', color: '#111827', marginBottom: '12px' }}>
            Biometric Enrollment Status
          </h3>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', maxHeight: '210px', overflowY: 'auto' }}>
            {patientsWithFace.map((p) => (
              <div
                key={p.id}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '9px 12px',
                  borderRadius: '10px',
                  backgroundColor: '#F9FBFA',
                  border: '1px solid #EEF3F0'
                }}
              >
                <div>
                  <div style={{ fontSize: '13px', fontWeight: '600', color: '#111827' }}>{p.name}</div>
                  <div style={{ fontSize: '11.5px', color: '#9CA3AF' }}>Dispenser: {p.deviceId || '—'}</div>
                </div>
                <StatusBadge status={p.faceEnrollmentStatus || 'not_started'} />
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Activity Logs Section */}
      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', padding: '24px', boxShadow: 'var(--shadow-card)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px', flexWrap: 'wrap', gap: '10px' }}>
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: '800', color: '#111827', letterSpacing: '-0.01em' }}>
              Fleet Event Audit Trail
            </h3>
            <p style={{ fontSize: '12px', color: '#6B7280' }}>
              Real-time stream of dispensing, face validations, alerts and overrides.
            </p>
          </div>

          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              backgroundColor: '#F9FBFA',
              border: '1px solid #E6EFE9',
              borderRadius: '8px',
              padding: '0 10px',
              height: '34px'
            }}
          >
            <Search size={14} style={{ color: '#9CA3AF' }} />
            <input
              type="text"
              placeholder="Filter events..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={{ border: 'none', outline: 'none', fontSize: '12px', color: '#111827', backgroundColor: 'transparent' }}
            />
          </div>
        </div>

        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '13px' }}>
          <thead>
            <tr style={{ borderBottom: '1px solid #E6EFE9', backgroundColor: '#F9FBFA' }}>
              <th style={{ padding: '12px 16px', fontWeight: '700', color: '#6B7280', fontSize: '11px', textTransform: 'uppercase' }}>Time</th>
              <th style={{ padding: '12px 16px', fontWeight: '700', color: '#6B7280', fontSize: '11px', textTransform: 'uppercase' }}>Event / Action</th>
              <th style={{ padding: '12px 16px', fontWeight: '700', color: '#6B7280', fontSize: '11px', textTransform: 'uppercase' }}>Patient Name</th>
              <th style={{ padding: '12px 16px', fontWeight: '700', color: '#6B7280', fontSize: '11px', textTransform: 'uppercase' }}>Dispenser</th>
            </tr>
          </thead>
          <tbody>
            {filteredActivities.map((act, idx) => (
              <tr key={act.id} style={{ borderBottom: idx === filteredActivities.length - 1 ? 'none' : '1px solid #F0F5F2' }}>
                <td style={{ padding: '12px 16px', color: '#9CA3AF', whiteSpace: 'nowrap' }}>
                  {act.timeAgo}
                </td>
                <td style={{ padding: '12px 16px', fontWeight: '600', color: '#111827' }}>
                  {act.title}
                </td>
                <td style={{ padding: '12px 16px', color: '#4B5563' }}>
                  {act.patientName}
                </td>
                <td style={{ padding: '12px 16px', color: '#059669', fontFamily: 'monospace', fontWeight: '600' }}>
                  {act.deviceId}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
