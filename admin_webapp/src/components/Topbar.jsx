import React, { useState, useEffect, useRef } from 'react';
import { useApp } from '../context/AppContext';
import {
  Activity,
  Bell,
  LogOut,
  Sun,
  Moon,
  Check,
  CheckCheck,
  RotateCcw,
  ExternalLink,
  X
} from 'lucide-react';

export function Topbar() {
  const { currentUser, logout, alerts = [], toggleAlertRead, markAllAlertsAsRead, darkMode, toggleDarkMode, setActiveTab } = useApp();
  const [showBellMenu, setShowBellMenu] = useState(false);
  const [bellTab, setBellTab] = useState('unread'); // 'unread' | 'all'
  const dropdownRef = useRef(null);

  const unreadAlerts = alerts.filter(a => !a.isRead);
  const unreadCount = unreadAlerts.length;

  // Close dropdown on click outside
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        setShowBellMenu(false);
      }
    };
    if (showBellMenu) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [showBellMenu]);

  const displayedAlerts = bellTab === 'unread' ? unreadAlerts : alerts;

  return (
    <header
      style={{
        height: '64px',
        backgroundColor: 'var(--bg-topbar)',
        borderBottom: '1px solid var(--border-light)',
        display: 'flex',
        justifyContent: 'center',
        position: 'sticky',
        top: 0,
        zIndex: 40,
        padding: '0 36px',
        boxSizing: 'border-box',
        transition: 'background-color 0.25s ease, border-color 0.25s ease'
      }}
    >
      <div
        style={{
          width: '100%',
          maxWidth: '980px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between'
        }}
      >
        {/* Left: System Status */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#10B981'
            }}
          >
            <Activity size={19} strokeWidth={2.4} />
          </div>
          <div style={{ fontSize: '13.5px', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '5px' }}>
            <span>SmartDose status:</span>
            <span style={{ fontWeight: '700', color: 'var(--text-main)' }}>Operational</span>
          </div>
        </div>

        {/* Right Controls: Dark Mode Toggle, Notification Bell, User Avatar, Name, Logout */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '14px', position: 'relative' }}>
          
          {/* ── Dark / Light Mode Toggle Button (Icon Only) ── */}
          <button
            onClick={toggleDarkMode}
            title={darkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
            aria-label="Toggle theme appearance"
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              width: '36px',
              height: '36px',
              borderRadius: '10px',
              border: '1px solid var(--border-light)',
              backgroundColor: 'var(--bg-subtle)',
              color: darkMode ? '#FBBF24' : '#6B7280',
              cursor: 'pointer',
              transition: 'all 0.15s ease'
            }}
            onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = 'var(--bg-hover)')}
            onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = 'var(--bg-subtle)')}
          >
            {darkMode ? <Sun size={18} strokeWidth={2.2} /> : <Moon size={18} strokeWidth={2.2} />}
          </button>

          {/* ── Notification Bell with Read / Unread dropdown ── */}
          <div style={{ position: 'relative' }} ref={dropdownRef}>
            <button
              onClick={() => setShowBellMenu(prev => !prev)}
              aria-label="Notifications"
              style={{
                position: 'relative',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                background: 'none',
                border: '1px solid var(--border-light)',
                backgroundColor: showBellMenu ? 'var(--bg-hover)' : 'transparent',
                color: unreadCount > 0 ? '#059669' : 'var(--text-subtle)',
                cursor: 'pointer',
                padding: '8px',
                borderRadius: '10px',
                transition: 'all 0.15s'
              }}
              onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = 'var(--bg-hover)')}
              onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = showBellMenu ? 'var(--bg-hover)' : 'transparent')}
            >
              <Bell size={18} strokeWidth={2.2} />
              {unreadCount > 0 && (
                <span
                  style={{
                    position: 'absolute',
                    top: '-4px',
                    right: '-4px',
                    minWidth: '17px',
                    height: '17px',
                    padding: '0 4px',
                    backgroundColor: '#EF4444',
                    color: '#FFFFFF',
                    borderRadius: '9999px',
                    fontSize: '10px',
                    fontWeight: '800',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    boxShadow: '0 2px 5px rgba(239, 68, 68, 0.4)'
                  }}
                >
                  {unreadCount}
                </span>
              )}
            </button>

            {/* Notification Popover Dropdown */}
            {showBellMenu && (
              <div
                style={{
                  position: 'absolute',
                  top: '46px',
                  right: 0,
                  width: '360px',
                  backgroundColor: 'var(--bg-card)',
                  borderRadius: '16px',
                  boxShadow: 'var(--shadow-dropdown)',
                  border: '1px solid var(--border-light)',
                  padding: '14px',
                  zIndex: 100,
                  color: 'var(--text-main)',
                  animation: 'scaleUpModal 0.18s ease-out forwards'
                }}
              >
                {/* Header */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px', paddingBottom: '8px', borderBottom: '1px solid var(--border-light)' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span style={{ fontSize: '14px', fontWeight: '800', color: 'var(--text-main)' }}>Notifications</span>
                    {unreadCount > 0 && (
                      <span style={{ backgroundColor: '#FEE2E2', color: '#DC2626', fontSize: '11px', fontWeight: '800', padding: '1px 6px', borderRadius: '6px' }}>
                        {unreadCount} unread
                      </span>
                    )}
                  </div>

                  {unreadCount > 0 && (
                    <button
                      onClick={() => markAllAlertsAsRead()}
                      style={{ background: 'none', border: 'none', color: '#00A36C', fontSize: '12px', fontWeight: '700', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '3px' }}
                    >
                      <CheckCheck size={13} /> Mark all read
                    </button>
                  )}
                </div>

                {/* Read / Unread Tabs */}
                <div style={{ display: 'flex', gap: '4px', backgroundColor: 'var(--bg-subtle)', borderRadius: '8px', padding: '2px', marginBottom: '10px' }}>
                  <button
                    onClick={() => setBellTab('unread')}
                    style={{
                      flex: 1,
                      padding: '5px 0',
                      border: 'none',
                      borderRadius: '6px',
                      fontSize: '11.5px',
                      fontWeight: '700',
                      backgroundColor: bellTab === 'unread' ? 'var(--bg-card)' : 'transparent',
                      color: bellTab === 'unread' ? 'var(--text-main)' : 'var(--text-subtle)',
                      boxShadow: bellTab === 'unread' ? '0 1px 2px rgba(0,0,0,0.06)' : 'none',
                      cursor: 'pointer'
                    }}
                  >
                    Unread ({unreadCount})
                  </button>
                  <button
                    onClick={() => setBellTab('all')}
                    style={{
                      flex: 1,
                      padding: '5px 0',
                      border: 'none',
                      borderRadius: '6px',
                      fontSize: '11.5px',
                      fontWeight: '700',
                      backgroundColor: bellTab === 'all' ? 'var(--bg-card)' : 'transparent',
                      color: bellTab === 'all' ? 'var(--text-main)' : 'var(--text-subtle)',
                      boxShadow: bellTab === 'all' ? '0 1px 2px rgba(0,0,0,0.06)' : 'none',
                      cursor: 'pointer'
                    }}
                  >
                    All ({alerts.length})
                  </button>
                </div>

                {/* Notification Items List */}
                {displayedAlerts.length === 0 ? (
                  <div style={{ fontSize: '12.5px', color: 'var(--text-subtle)', textAlign: 'center', padding: '24px 0' }}>
                    {bellTab === 'unread' ? '✓ No unread notifications!' : 'No notifications.'}
                  </div>
                ) : (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', maxHeight: '260px', overflowY: 'auto' }}>
                    {displayedAlerts.slice(0, 5).map((a) => {
                      const isUnread = !a.isRead;
                      return (
                        <div
                          key={a.id}
                          style={{
                            padding: '10px 12px',
                            borderRadius: '10px',
                            backgroundColor: isUnread ? (darkMode ? '#1E293B' : '#F0FDF4') : 'var(--bg-subtle)',
                            borderLeft: isUnread ? '3px solid #10B981' : '3px solid transparent',
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'flex-start',
                            gap: '8px'
                          }}
                        >
                          <div
                            onClick={() => { setShowBellMenu(false); setActiveTab('alerts'); }}
                            style={{ flex: 1, cursor: 'pointer' }}
                          >
                            <div style={{ fontSize: '13px', fontWeight: isUnread ? '700' : '600', color: 'var(--text-main)', display: 'flex', alignItems: 'center', gap: '6px' }}>
                              {a.title}
                            </div>
                            <div style={{ fontSize: '12px', color: 'var(--text-subtle)', marginTop: '2px', lineHeight: '1.3' }}>
                              {a.message || `${a.patientName} • ${a.deviceId}`}
                            </div>
                            <div style={{ fontSize: '11px', color: 'var(--text-faint)', marginTop: '4px' }}>
                              {a.timeAgo || 'Recent'}
                            </div>
                          </div>

                          {/* Quick Toggle Read/Unread Icon */}
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              toggleAlertRead(a.id, !isUnread);
                            }}
                            title={isUnread ? 'Mark as read' : 'Mark as unread'}
                            style={{
                              padding: '5px',
                              borderRadius: '6px',
                              border: 'none',
                              backgroundColor: 'transparent',
                              color: isUnread ? '#00A36C' : 'var(--text-faint)',
                              cursor: 'pointer'
                            }}
                          >
                            {isUnread ? <Check size={14} strokeWidth={2.5} /> : <RotateCcw size={13} />}
                          </button>
                        </div>
                      );
                    })}
                  </div>
                )}

                {/* Footer Link */}
                <div style={{ borderTop: '1px solid var(--border-light)', paddingTop: '10px', marginTop: '10px', textAlign: 'center' }}>
                  <button
                    onClick={() => { setShowBellMenu(false); setActiveTab('alerts'); }}
                    style={{ background: 'none', border: 'none', color: '#00A36C', fontSize: '12.5px', fontWeight: '700', cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: '4px' }}
                  >
                    View All Notifications <ExternalLink size={12} />
                  </button>
                </div>
              </div>
            )}
          </div>

          {/* User Avatar Initial Circle */}
          <div
            onClick={() => setActiveTab('settings')}
            title="Open Settings & Profile"
            style={{
              width: '34px',
              height: '34px',
              borderRadius: '50%',
              backgroundColor: '#00A36C',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '14px',
              fontWeight: '700',
              cursor: 'pointer',
              boxShadow: '0 2px 6px rgba(0, 163, 108, 0.25)',
              userSelect: 'none'
            }}
          >
            {currentUser.initial || 'A'}
          </div>

          {/* User Name */}
          <div
            onClick={() => setActiveTab('settings')}
            title="Open Settings & Profile"
            style={{
              fontSize: '13.5px',
              fontWeight: '700',
              color: 'var(--text-main)',
              cursor: 'pointer',
              whiteSpace: 'nowrap'
            }}
          >
            {currentUser.name}
          </div>

          {/* Sign Out Button */}
          <button
            onClick={logout}
            title="Sign out of console"
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: 'none',
              border: 'none',
              color: 'var(--text-subtle)',
              cursor: 'pointer',
              padding: '6px',
              borderRadius: '8px',
              transition: 'color 0.15s, background 0.15s'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.backgroundColor = '#FEE2E2';
              e.currentTarget.style.color = '#DC2626';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.backgroundColor = 'transparent';
              e.currentTarget.style.color = 'var(--text-subtle)';
            }}
          >
            <LogOut size={18} strokeWidth={2} />
          </button>
        </div>
      </div>
    </header>
  );
}
