import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import {
  Camera,
  RefreshCw,
  CheckCircle,
  XCircle,
  Activity,
  Wifi,
  WifiOff,
  Image as ImageIcon,
  Clock
} from 'lucide-react';

export function LiveFeedView() {
  const { devices, activities, showToast } = useApp();

  const [selectedDeviceId, setSelectedDeviceId] = useState('SD-0119');
  const [streamKey, setStreamKey] = useState(0);

  const selectedDevice = devices.find(d => d.deviceId === selectedDeviceId) || devices[0] || {
    deviceId: 'SD-0119',
    patientName: 'Amara Reyes',
    status: 'online',
    battery: 98,
    ip: '192.168.1.119'
  };

  const isOnline = selectedDevice.status === 'online';

  const getLogBadge = (log) => {
    const type = log.type || '';
    const status = log.status || '';

    if (type === 'patient_detected' || status === 'detected' || type === 'face_verified') {
      return {
        bg: '#DBEAFE',
        text: '#1D4ED8',
        icon: Activity,
        label: 'Patient Detected'
      };
    }
    if (type === 'photo_captured' || status === 'captured') {
      return {
        bg: '#E0E7FF',
        text: '#4338CA',
        icon: Camera,
        label: 'Captured Image'
      };
    }
    if (status === 'missed' || type === 'dose_missed') {
      return {
        bg: '#FEE2E2',
        text: '#EF4444',
        icon: XCircle,
        label: 'Missed Dose'
      };
    }
    return {
      bg: '#D1FAE5',
      text: '#059669',
      icon: CheckCircle,
      label: 'Medicine Taken'
    };
  };

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      
      {/* ── Header ── */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', margin: 0 }}>
            Live Camera Feed
          </h1>
          <p style={{ fontSize: '13.5px', color: '#6B7280', margin: '3px 0 0' }}>
            Real-time Raspberry Pi camera stream and live dispensing activity.
          </p>
        </div>

        {/* Device Picker & Reconnect */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <select
            value={selectedDeviceId}
            onChange={(e) => setSelectedDeviceId(e.target.value)}
            style={{
              height: '40px',
              padding: '0 14px',
              backgroundColor: '#FFFFFF',
              border: '1px solid #E6EFE9',
              borderRadius: '12px',
              fontSize: '13.5px',
              fontWeight: '700',
              color: '#111827',
              outline: 'none',
              cursor: 'pointer',
              boxShadow: '0 1px 3px rgba(0,0,0,0.03)'
            }}
          >
            {devices.map((d) => (
              <option key={d.deviceId} value={d.deviceId}>
                {d.deviceId} — {d.patientName} ({d.status === 'online' ? 'Online' : 'Standby'})
              </option>
            ))}
          </select>

          <button
            onClick={() => {
              setStreamKey(prev => prev + 1);
              showToast('Reconnecting stream...');
            }}
            title="Reconnect stream"
            style={{
              width: '40px',
              height: '40px',
              borderRadius: '12px',
              border: '1px solid #E6EFE9',
              backgroundColor: '#FFFFFF',
              color: '#059669',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              boxShadow: '0 1px 3px rgba(0,0,0,0.03)'
            }}
          >
            <RefreshCw size={17} />
          </button>
        </div>
      </div>

      {/* ── Clean Live Video Stream Block ── */}
      <div
        style={{
          height: '320px',
          backgroundColor: '#0F172A',
          borderRadius: '24px',
          border: '1.5px solid #E2E8F0',
          position: 'relative',
          overflow: 'hidden',
          boxShadow: '0 12px 32px rgba(15, 23, 42, 0.18)',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'space-between'
        }}
      >
        {/* Top Overlay Bar */}
        <div style={{ padding: '16px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', zIndex: 10 }}>
          {/* Live pulsing badge */}
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '6px',
              backgroundColor: isOnline ? 'rgba(239, 68, 68, 0.25)' : 'rgba(100, 116, 139, 0.25)',
              color: isOnline ? '#EF4444' : '#94A3B8',
              fontSize: '11.5px',
              fontWeight: '800',
              padding: '4px 10px',
              borderRadius: '9999px',
              border: isOnline ? '1px solid rgba(239, 68, 68, 0.4)' : '1px solid rgba(148, 163, 184, 0.4)',
              backdropFilter: 'blur(4px)'
            }}
          >
            <span
              style={{
                width: '7px',
                height: '7px',
                borderRadius: '50%',
                backgroundColor: isOnline ? '#EF4444' : '#94A3B8',
                animation: isOnline ? 'pulse 1.5s infinite' : 'none'
              }}
            />
            {isOnline ? 'LIVE STREAM' : 'STANDBY'}
          </div>

          {/* Top-right Status Pill */}
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '6px',
              padding: '5px 12px',
              borderRadius: '20px',
              backgroundColor: 'rgba(255, 255, 255, 0.9)',
              color: '#0F172A',
              fontSize: '11.5px',
              fontWeight: '700',
              boxShadow: '0 2px 8px rgba(0,0,0,0.15)'
            }}
          >
            {isOnline ? <Wifi size={13} color="#00C882" strokeWidth={2.4} /> : <WifiOff size={13} color="#6B7280" />}
            {isOnline ? 'Raspberry Pi · Online' : 'Standby'}
          </div>
        </div>

        {/* Viewfinder Center Canvas */}
        <div
          style={{
            flex: 1,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#64748B',
            fontSize: '14px',
            fontWeight: '600'
          }}
        >
          {isOnline ? (
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px' }}>
              <Camera size={40} color="#10B981" strokeWidth={1.6} />
              <span style={{ color: '#E2E8F0', fontSize: '13px' }}>MJPEG Stream Active • {selectedDevice.deviceId}</span>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px' }}>
              <WifiOff size={36} color="#64748B" />
              <span style={{ color: '#94A3B8', fontSize: '13px' }}>Camera in Standby Mode</span>
            </div>
          )}
        </div>

        {/* Bottom Status Info */}
        <div
          style={{
            padding: '12px 20px',
            backgroundColor: 'rgba(15, 23, 42, 0.85)',
            borderTop: '1px solid rgba(255, 255, 255, 0.08)',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            fontSize: '12px',
            color: '#94A3B8'
          }}
        >
          <span>{selectedDevice.patientName} • {selectedDevice.deviceId}</span>
          <span style={{ color: '#10B981', fontWeight: '600' }}>Stream Synced</span>
        </div>
      </div>

      {/* ── Activity Logs Header ── */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '10px' }}>
        <div>
          <h2 style={{ fontSize: '18px', fontWeight: '800', color: '#111827', margin: 0, letterSpacing: '-0.01em' }}>
            Live Detection & Activity Logs
          </h2>
          <p style={{ fontSize: '13px', color: '#6B7280', margin: '2px 0 0' }}>
            Patient detection, medicine intake & camera events in real-time.
          </p>
        </div>
        <Activity size={22} color="#00A36C" />
      </div>

      {/* ── Activity Logs List (Clean Card UI) ── */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        {activities.map((act) => {
          const badge = getLogBadge(act);
          const Icon = badge.icon;

          return (
            <div
              key={act.id}
              style={{
                backgroundColor: '#FFFFFF',
                borderRadius: '20px',
                padding: '16px 20px',
                border: '1px solid #E6EFE9',
                boxShadow: 'var(--shadow-card)',
                display: 'flex',
                alignItems: 'flex-start',
                gap: '16px'
              }}
            >
              {/* Left Circle Icon */}
              <div
                style={{
                  width: '44px',
                  height: '44px',
                  borderRadius: '50%',
                  backgroundColor: badge.bg,
                  color: badge.text,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0
                }}
              >
                <Icon size={20} strokeWidth={2.3} />
              </div>

              {/* Main Log Info */}
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
                  <div style={{ fontSize: '15px', fontWeight: '800', color: '#111827' }}>
                    {act.title}
                  </div>
                  <div style={{ fontSize: '12px', color: '#6B7280', fontWeight: '500' }}>
                    {act.timeAgo || 'Just now'}
                  </div>
                </div>

                <div style={{ fontSize: '13px', color: '#6B7280', marginBottom: '8px' }}>
                  {act.patientName} • Device: <code>{act.deviceId || 'SD-0119'}</code>
                </div>

                {/* Badge tags */}
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
                  <span
                    style={{
                      padding: '3px 10px',
                      borderRadius: '12px',
                      backgroundColor: badge.bg,
                      color: badge.text,
                      fontSize: '11px',
                      fontWeight: '700'
                    }}
                  >
                    {badge.label}
                  </span>

                  {(act.type === 'photo_captured' || act.type === 'face_verified') && (
                    <span
                      style={{
                        padding: '3px 9px',
                        borderRadius: '12px',
                        backgroundColor: '#E0E7FF',
                        color: '#4338CA',
                        fontSize: '11px',
                        fontWeight: '700',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '4px'
                      }}
                    >
                      <ImageIcon size={12} /> Photo Attached
                    </span>
                  )}
                </div>
              </div>
            </div>
          );
        })}
      </div>

    </div>
  );
}
