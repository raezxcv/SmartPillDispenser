import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { SkeletonGenericPage } from '../components/SkeletonLoader';
import {
  Camera,
  CameraOff,
  VideoOff,
  Wifi,
  RefreshCw,
  Clock,
  ScanFace,
  CheckCircle,
  XCircle,
  AlertCircle,
  Activity,
  Bell,
  Pill,
  Image as ImageIcon
} from 'lucide-react';

export function LiveFeedView() {
  const { devices, activities, requestCameraCapture, showToast, darkMode, initialLoading } = useApp();
  const [selectedDeviceId, setSelectedDeviceId] = useState(devices[0]?.deviceId || 'SD-0119');
  const [isCapturing, setIsCapturing] = useState(false);

  if (initialLoading) {
    return <SkeletonGenericPage title="Live Camera Feed & AI Face Verification" />;
  }

  const selectedDevice = devices.find(d => d.deviceId === selectedDeviceId) || devices[0] || {};
  const isOnline = selectedDevice.status === 'online' || selectedDevice.isOnline === true;

  const handleCapture = async () => {
    setIsCapturing(true);
    await requestCameraCapture(selectedDeviceId);
    setTimeout(() => setIsCapturing(false), 1200);
  };

  const getLogDetails = (log) => {
    const type = (log.type || '').toLowerCase();
    const status = (log.status || '').toLowerCase();

    if (type === 'emergency' || status === 'emergency' || type === 'emergency_request') {
      return {
        bg: darkMode ? 'rgba(239, 68, 68, 0.2)' : '#FEE2E2',
        badgeBg: darkMode ? 'rgba(239, 68, 68, 0.25)' : '#FEE2E2',
        badgeText: '#EF4444',
        icon: Bell,
        title: 'Emergency Request',
        label: 'Emergency'
      };
    }
    if (type === 'patient_detected' || status === 'detected' || type === 'face_verified') {
      return {
        bg: darkMode ? 'rgba(59, 130, 246, 0.2)' : '#DBEAFE',
        badgeBg: darkMode ? 'rgba(59, 130, 246, 0.25)' : '#DBEAFE',
        badgeText: '#2563EB',
        icon: ScanFace,
        title: log.title || 'Patient Detected',
        label: 'Detected'
      };
    }
    if (type === 'photo_captured' || status === 'captured') {
      return {
        bg: darkMode ? 'rgba(99, 102, 241, 0.2)' : '#E0E7FF',
        badgeBg: darkMode ? 'rgba(99, 102, 241, 0.25)' : '#E0E7FF',
        badgeText: '#4338CA',
        icon: Camera,
        title: log.title || 'Snapshot Captured',
        label: 'Snapshot'
      };
    }
    if (status === 'missed' || type === 'dose_missed') {
      return {
        bg: darkMode ? 'rgba(239, 68, 68, 0.2)' : '#FEE2E2',
        badgeBg: darkMode ? 'rgba(239, 68, 68, 0.25)' : '#FEE2E2',
        badgeText: '#EF4444',
        icon: XCircle,
        title: log.title || 'Missed Medication',
        label: 'Missed'
      };
    }
    return {
      bg: darkMode ? 'rgba(16, 185, 129, 0.2)' : '#D1FAE5',
      badgeBg: darkMode ? 'rgba(16, 185, 129, 0.25)' : '#D1FAE5',
      badgeText: '#059669',
      icon: CheckCircle,
      title: log.title || 'Medicine Taken',
      label: 'Taken'
    };
  };

  // Format timestamp nicely (e.g. 07:56 AM)
  const formatTime = (log) => {
    if (log.dateObj) {
      return log.dateObj.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    }
    if (log.timeAgo && (log.timeAgo.includes('AM') || log.timeAgo.includes('PM'))) {
      return log.timeAgo;
    }
    return log.timeAgo || '08:00 AM';
  };

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '26px' }}>
      
      {/* ── Header ── */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--text-main)', letterSpacing: '-0.02em', marginBottom: '4px' }}>
            Live Camera Stream
          </h1>
          <p style={{ fontSize: '13.5px', color: 'var(--text-subtle)' }}>
            Real-time Raspberry Pi camera connection and dispensing event verification.
          </p>
        </div>

        {/* Device Switcher */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <span style={{ fontSize: '12.5px', fontWeight: '700', color: 'var(--text-subtle)' }}>Dispenser:</span>
          <select
            value={selectedDeviceId}
            onChange={(e) => setSelectedDeviceId(e.target.value)}
            style={{
              height: '40px',
              padding: '0 12px',
              borderRadius: '10px',
              border: '1px solid var(--border-light)',
              backgroundColor: 'var(--bg-card)',
              color: 'var(--text-main)',
              fontSize: '13px',
              fontWeight: '700',
              outline: 'none',
              cursor: 'pointer',
              boxShadow: 'var(--shadow-card)'
            }}
          >
            {devices.map((d) => (
              <option key={d.deviceId} value={d.deviceId}>
                {d.deviceId} — {d.patientName || 'Fleet'} ({d.status || 'offline'})
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* ── CAMERA VIEWPORT (Soft Light BG in Light Mode / Dark in Dark Mode, Matching Screenshot) ── */}
      <div
        style={{
          position: 'relative',
          width: '100%',
          minHeight: '340px',
          height: 'clamp(340px, 45vw, 420px)',
          borderRadius: '24px',
          backgroundColor: darkMode ? '#181F2E' : '#DFE6EE',
          background: darkMode
            ? 'linear-gradient(180deg, #1E293B 0%, #0F172A 100%)'
            : 'linear-gradient(180deg, #E2E8F0 0%, #DCE4ED 100%)',
          border: '1px solid var(--border-light)',
          overflow: 'hidden',
          boxShadow: darkMode ? '0 12px 32px rgba(0, 0, 0, 0.4)' : '0 8px 24px rgba(0, 0, 0, 0.04)',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'space-between',
          padding: 'clamp(14px, 3vw, 24px)',
          boxSizing: 'border-box',
          transition: 'background 0.25s ease'
        }}
      >
        {/* Top Badges */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '8px', zIndex: 10 }}>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              backgroundColor: darkMode ? 'rgba(15, 23, 42, 0.75)' : 'rgba(255, 255, 255, 0.75)',
              backdropFilter: 'blur(8px)',
              border: '1px solid var(--border-light)',
              padding: '5px 12px',
              borderRadius: '9999px'
            }}
          >
            <div className="pulse-live-dot" />
            <span style={{ fontSize: '11px', fontWeight: '800', color: '#10B981', letterSpacing: '0.04em' }}>
              {isOnline ? 'CAMERA ACTIVE' : 'CAMERA STANDBY'}
            </span>
          </div>

          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              backgroundColor: darkMode ? 'rgba(15, 23, 42, 0.75)' : 'rgba(255, 255, 255, 0.75)',
              backdropFilter: 'blur(8px)',
              border: '1px solid var(--border-light)',
              padding: '5px 12px',
              borderRadius: '9999px',
              fontSize: '11px',
              color: 'var(--text-main)',
              fontWeight: '600'
            }}
          >
            <Wifi size={13} style={{ color: '#10B981' }} />
            <span>Raspberry Pi · Online</span>
          </div>
        </div>

        {/* Center Standby Icon & Message (Matching Screenshot exactly) */}
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            textAlign: 'center',
            gap: '10px',
            zIndex: 5,
            padding: '10px 0'
          }}
        >
          {/* Circular Camera-Off Badge */}
          <div
            style={{
              width: '72px',
              height: '72px',
              borderRadius: '50%',
              backgroundColor: darkMode ? 'rgba(255, 255, 255, 0.08)' : 'rgba(148, 163, 184, 0.35)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: darkMode ? '#94A3B8' : '#475569',
              boxShadow: '0 4px 12px rgba(0, 0, 0, 0.03)'
            }}
          >
            <VideoOff size={32} strokeWidth={2} />
          </div>

          <div>
            <h3 style={{ fontSize: '17px', fontWeight: '800', color: 'var(--text-main)', margin: '0 0 4px', letterSpacing: '-0.01em' }}>
              Camera Standby
            </h3>
            <p style={{ fontSize: '13px', color: 'var(--text-subtle)', margin: 0, maxWidth: '320px', lineHeight: '1.4' }}>
              Waiting for camera connection or dispensing event...
            </p>
          </div>
        </div>

        {/* Bottom Actions: Take Photo / Capture CTA */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '10px', zIndex: 10 }}>
          <button
            onClick={handleCapture}
            disabled={isCapturing}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              padding: '10px 20px',
              borderRadius: '12px',
              border: 'none',
              backgroundColor: '#10B981',
              color: '#FFFFFF',
              fontSize: '13px',
              fontWeight: '700',
              cursor: 'pointer',
              boxShadow: '0 4px 16px rgba(16, 185, 129, 0.35)',
              transition: 'all 0.15s ease'
            }}
            onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = '#059669')}
            onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = '#10B981')}
          >
            <Camera size={17} strokeWidth={2.4} className={isCapturing ? 'animate-pulse' : ''} />
            <span>{isCapturing ? 'Capturing...' : 'Take Photo (Capture)'}</span>
          </button>

          <div
            style={{
              fontSize: '11.5px',
              color: 'var(--text-subtle)',
              backgroundColor: darkMode ? 'rgba(15, 23, 42, 0.75)' : 'rgba(255, 255, 255, 0.75)',
              padding: '6px 12px',
              borderRadius: '8px',
              backdropFilter: 'blur(6px)',
              border: '1px solid var(--border-light)'
            }}
          >
            Unit: <strong>{selectedDeviceId}</strong> ({selectedDevice.patientName || 'Fleet'})
          </div>
        </div>
      </div>

      {/* ── Live Detection & Activity Logs (Matching Screenshot) ── */}
      <div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
          <div>
            <h2 style={{ fontSize: '18px', fontWeight: '800', color: 'var(--text-main)', margin: '0 0 2px', letterSpacing: '-0.01em' }}>
              Live Detection & Activity Logs
            </h2>
            <p style={{ fontSize: '12.5px', color: 'var(--text-subtle)', margin: 0 }}>
              Patient detection, medicine intake & captures
            </p>
          </div>

          <div style={{ color: '#10B981', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Activity size={22} strokeWidth={2.4} />
          </div>
        </div>

        {/* Activity Cards List */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {activities.slice(0, 5).map((log, idx) => {
            const details = getLogDetails(log);
            const Icon = details.icon;
            const timeFormatted = formatTime(log);

            return (
              <div
                key={log.id || idx}
                style={{
                  backgroundColor: 'var(--bg-card)',
                  border: '1px solid var(--border-light)',
                  borderRadius: '20px',
                  padding: '16px 20px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  gap: '16px',
                  boxShadow: 'var(--shadow-card)',
                  transition: 'background-color 0.15s ease'
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                  {/* Soft Pastel Circular Icon Badge */}
                  <div
                    style={{
                      width: '46px',
                      height: '46px',
                      borderRadius: '50%',
                      backgroundColor: details.bg,
                      color: details.badgeText,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      flexShrink: 0
                    }}
                  >
                    <Icon size={20} strokeWidth={2.3} />
                  </div>

                  <div>
                    <div style={{ fontSize: '15px', fontWeight: '800', color: 'var(--text-main)', lineHeight: '1.2' }}>
                      {details.title}
                    </div>

                    <div style={{ marginTop: '5px' }}>
                      <span
                        style={{
                          display: 'inline-block',
                          padding: '2px 10px',
                          borderRadius: '8px',
                          backgroundColor: details.badgeBg,
                          color: details.badgeText,
                          fontSize: '11.5px',
                          fontWeight: '800',
                          letterSpacing: '0.02em'
                        }}
                      >
                        {details.label}
                      </span>
                    </div>
                  </div>
                </div>

                <div style={{ fontSize: '13px', color: 'var(--text-subtle)', fontWeight: '600' }}>
                  {timeFormatted}
                </div>
              </div>
            );
          })}
        </div>
      </div>

    </div>
  );
}
