import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import { SkeletonGenericPage } from '../components/SkeletonLoader';
import {
  Bell,
  Check,
  CheckCheck,
  RotateCcw,
  AlertTriangle,
  Info,
  Filter,
  Eye,
  EyeOff
} from 'lucide-react';

export function AlertsView() {
  const { alerts, toggleAlertRead, markAllAlertsAsRead, darkMode, initialLoading } = useApp();
  const [readFilter, setReadFilter] = useState('all'); // 'all' | 'unread' | 'read'
  const [filterSev, setFilterSev] = useState('');

  if (initialLoading) {
    return <SkeletonGenericPage title="Alerts & Fleet Notifications" />;
  }

  const unreadCount = alerts.filter(a => !a.isRead).length;

  const filtered = alerts.filter(a => {
    const matchRead = readFilter === 'all' 
      ? true 
      : readFilter === 'unread' 
        ? !a.isRead 
        : a.isRead;
    const matchSev = !filterSev || a.severity === filterSev;
    return matchRead && matchSev;
  });

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      
      {/* ── Page Header ── */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '14px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <h1 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--text-main)', letterSpacing: '-0.02em', margin: 0 }}>
              Alerts & Notifications
            </h1>
            {unreadCount > 0 && (
              <span
                style={{
                  backgroundColor: '#EF4444',
                  color: '#FFFFFF',
                  fontSize: '12px',
                  fontWeight: '800',
                  padding: '2px 9px',
                  borderRadius: '9999px'
                }}
              >
                {unreadCount} Unread
              </span>
            )}
          </div>
          <p style={{ fontSize: '13.5px', color: 'var(--text-subtle)', margin: '4px 0 0' }}>
            Medication delays, low stock alerts, hardware offline triggers, and patient notifications.
          </p>
        </div>

        {/* Global Action: Mark all as read */}
        {unreadCount > 0 && (
          <button
            onClick={markAllAlertsAsRead}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              padding: '9px 16px',
              borderRadius: '10px',
              backgroundColor: darkMode ? '#064E3B' : '#ECFDF5',
              color: darkMode ? '#34D399' : '#059669',
              border: '1px solid var(--border-light)',
              fontSize: '13px',
              fontWeight: '700',
              cursor: 'pointer',
              boxShadow: '0 1px 3px rgba(5, 150, 105, 0.1)',
              transition: 'all 0.15s'
            }}
          >
            <CheckCheck size={16} /> Mark all as read
          </button>
        )}
      </div>

      {/* ── Filter Toolbar ── */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '12px',
          backgroundColor: 'var(--bg-card)',
          padding: '12px 16px',
          borderRadius: '14px',
          border: '1px solid var(--border-light)',
          boxShadow: 'var(--shadow-card)'
        }}
      >
        {/* Read / Unread Tabs */}
        <div style={{ display: 'flex', gap: '6px' }}>
          {[
            { id: 'all', label: `All (${alerts.length})` },
            { id: 'unread', label: `Unread (${unreadCount})` },
            { id: 'read', label: `Read (${alerts.length - unreadCount})` }
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setReadFilter(tab.id)}
              style={{
                padding: '7px 14px',
                borderRadius: '8px',
                border: 'none',
                backgroundColor: readFilter === tab.id ? '#10B981' : 'var(--bg-subtle)',
                color: readFilter === tab.id ? '#FFFFFF' : 'var(--text-muted)',
                fontWeight: readFilter === tab.id ? '700' : '600',
                fontSize: '12.5px',
                cursor: 'pointer',
                transition: 'all 0.15s'
              }}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {/* Severity Filter */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <span style={{ fontSize: '12.5px', color: 'var(--text-subtle)', fontWeight: '600' }}>Severity:</span>
          <select
            value={filterSev}
            onChange={(e) => setFilterSev(e.target.value)}
            style={{
              padding: '6px 12px',
              borderRadius: '8px',
              border: '1px solid var(--border-input)',
              backgroundColor: 'var(--bg-input)',
              color: 'var(--text-main)',
              fontSize: '12.5px',
              fontWeight: '600',
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
      </div>

      {/* ── Alerts Card List ── */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        {filtered.length === 0 ? (
          <div
            style={{
              backgroundColor: 'var(--bg-card)',
              border: '1px solid var(--border-light)',
              borderRadius: '16px',
              padding: '48px 24px',
              textAlign: 'center',
              color: 'var(--text-subtle)'
            }}
          >
            <Bell size={32} style={{ color: 'var(--text-faint)', margin: '0 auto 10px' }} />
            <div style={{ fontSize: '15px', fontWeight: '700', color: 'var(--text-main)' }}>No alerts found</div>
            <div style={{ fontSize: '13px', marginTop: '4px' }}>There are no alerts matching your current filter settings.</div>
          </div>
        ) : (
          filtered.map((alert) => {
            const isUnread = !alert.isRead;
            const isCrit = alert.severity === 'critical';
            const isWarn = alert.severity === 'warning';

            return (
              <div
                key={alert.id}
                style={{
                  backgroundColor: 'var(--bg-card)',
                  border: isUnread ? (darkMode ? '1px solid #059669' : '1px solid #A7F3D0') : '1px solid var(--border-light)',
                  borderLeft: isUnread 
                    ? '4px solid #10B981' 
                    : '4px solid var(--border-input)',
                  borderRadius: '16px',
                  padding: 'clamp(14px, 2.5vw, 20px)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  gap: '14px',
                  flexWrap: 'wrap',
                  boxShadow: isUnread ? '0 4px 14px rgba(16, 185, 129, 0.08)' : 'var(--shadow-card)',
                  transition: 'all 0.15s ease'
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px', flex: 1, minWidth: '260px' }}>
                  {/* Severity Icon Box */}
                  <div
                    style={{
                      width: '42px',
                      height: '42px',
                      borderRadius: '12px',
                      backgroundColor: isCrit 
                        ? (darkMode ? 'rgba(239, 68, 68, 0.2)' : '#FEE2E2') 
                        : isWarn 
                          ? (darkMode ? 'rgba(245, 158, 11, 0.2)' : '#FEF3C7') 
                          : (darkMode ? 'rgba(59, 130, 246, 0.2)' : '#DBEAFE'),
                      color: isCrit ? '#EF4444' : isWarn ? (darkMode ? '#FBBF24' : '#D97706') : (darkMode ? '#60A5FA' : '#2563EB'),
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      flexShrink: 0
                    }}
                  >
                    {isCrit ? <AlertTriangle size={20} strokeWidth={2.3} /> : <Bell size={20} strokeWidth={2.3} />}
                  </div>

                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
                      <span style={{ fontSize: '15px', fontWeight: isUnread ? '800' : '700', color: 'var(--text-main)' }}>
                        {alert.title}
                      </span>
                      
                      <span
                        style={{
                          padding: '2px 8px',
                          borderRadius: '6px',
                          backgroundColor: isUnread ? '#ECFDF5' : 'var(--bg-subtle)',
                          color: isUnread ? '#00A36C' : 'var(--text-subtle)',
                          fontSize: '11px',
                          fontWeight: '800',
                          letterSpacing: '0.02em'
                        }}
                      >
                        {isUnread ? '● UNREAD' : 'READ'}
                      </span>

                      <StatusBadge status={alert.severity} />
                    </div>

                    <div style={{ fontSize: '13px', color: 'var(--text-muted)', marginTop: '4px', lineHeight: '1.4' }}>
                      {alert.message}
                    </div>

                    <div style={{ fontSize: '11.5px', color: 'var(--text-subtle)', marginTop: '4px' }}>
                      Patient: <strong>{alert.patientName}</strong> • Device: <code>{alert.deviceId}</code> • {alert.timeAgo || 'Recent'}
                    </div>
                  </div>
                </div>

                {/* Read / Unread Toggle Button */}
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <button
                    onClick={() => toggleAlertRead(alert.id, !isUnread)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '6px',
                      padding: '8px 14px',
                      borderRadius: '10px',
                      border: '1px solid var(--border-light)',
                      backgroundColor: isUnread ? (darkMode ? '#064E3B' : '#ECFDF5') : 'var(--bg-subtle)',
                      color: isUnread ? (darkMode ? '#34D399' : '#059669') : 'var(--text-muted)',
                      fontSize: '12.5px',
                      fontWeight: '700',
                      cursor: 'pointer',
                      transition: 'all 0.15s'
                    }}
                  >
                    {isUnread ? (
                      <>
                        <Check size={14} strokeWidth={2.5} /> Mark as Read
                      </>
                    ) : (
                      <>
                        <RotateCcw size={13} /> Mark as Unread
                      </>
                    )}
                  </button>
                </div>
              </div>
            );
          })
        )}
      </div>

    </div>
  );
}
