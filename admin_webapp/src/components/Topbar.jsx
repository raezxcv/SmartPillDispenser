import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { Activity, Bell, LogOut } from 'lucide-react';

export function Topbar() {
  const { currentUser, logout, alerts, setActiveTab } = useApp();
  const [showBellMenu, setShowBellMenu] = useState(false);

  return (
    <header
      style={{
        height: '64px',
        backgroundColor: '#FFFFFF',
        borderBottom: '1px solid #E6EFE9',
        display: 'flex',
        justifyContent: 'center',
        position: 'sticky',
        top: 0,
        zIndex: 40,
        padding: '0 36px',
        boxSizing: 'border-box'
      }}
    >
      {/* Centered Topbar Inner matching content max-width */}
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
          <div style={{ fontSize: '13.5px', color: '#374151', display: 'flex', alignItems: 'center', gap: '5px' }}>
            <span style={{ color: '#4B5563' }}>SmartDose system status:</span>
            <span style={{ fontWeight: '600', color: '#111827' }}>Operational</span>
          </div>
        </div>

        {/* Right: Notification Bell, User Initial, User Name, Logout */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '18px', position: 'relative' }}>
          {/* Bell Button */}
          <div style={{ position: 'relative' }}>
            <button
              onClick={() => setShowBellMenu(prev => !prev)}
              aria-label="Notifications"
              style={{
                position: 'relative',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                background: 'none',
                border: 'none',
                color: '#6B7280',
                cursor: 'pointer',
                padding: '6px',
                borderRadius: '8px',
                transition: 'background 0.15s'
              }}
              onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = '#F3F4F6')}
              onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = 'transparent')}
            >
              <Bell size={19} strokeWidth={2} />
              {alerts.length > 0 && (
                <span
                  style={{
                    position: 'absolute',
                    top: '4px',
                    right: '4px',
                    width: '7px',
                    height: '7px',
                    backgroundColor: '#EF4444',
                    borderRadius: '50%'
                  }}
                />
              )}
            </button>

            {/* Quick Alert Dropdown */}
            {showBellMenu && (
              <div
                style={{
                  position: 'absolute',
                  top: '40px',
                  right: 0,
                  width: '320px',
                  backgroundColor: '#FFFFFF',
                  borderRadius: '12px',
                  boxShadow: '0 10px 25px rgba(0,0,0,0.1), 0 4px 10px rgba(0,0,0,0.05)',
                  border: '1px solid #E5E7EB',
                  padding: '12px',
                  zIndex: 100
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px', paddingBottom: '6px', borderBottom: '1px solid #F3F4F6' }}>
                  <span style={{ fontSize: '13px', fontWeight: '700', color: '#111827' }}>Pending Alerts ({alerts.length})</span>
                  <button
                    onClick={() => { setShowBellMenu(false); setActiveTab('alerts'); }}
                    style={{ background: 'none', border: 'none', color: '#10B981', fontSize: '12px', fontWeight: '600', cursor: 'pointer' }}
                  >
                    View All
                  </button>
                </div>
                {alerts.length === 0 ? (
                  <div style={{ fontSize: '12px', color: '#9CA3AF', textAlign: 'center', padding: '16px 0' }}>All clear! No pending alerts.</div>
                ) : (
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', maxHeight: '240px', overflowY: 'auto' }}>
                    {alerts.slice(0, 4).map((a) => (
                      <div
                        key={a.id}
                        onClick={() => { setShowBellMenu(false); setActiveTab('alerts'); }}
                        style={{ padding: '8px', borderRadius: '8px', backgroundColor: '#F9FAFB', cursor: 'pointer' }}
                      >
                        <div style={{ fontSize: '12.5px', fontWeight: '600', color: '#111827' }}>{a.title}</div>
                        <div style={{ fontSize: '11.5px', color: '#6B7280' }}>{a.patientName} • {a.timeAgo}</div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>

          {/* User Avatar Circle (Crimson badge with initial) */}
          <div
            onClick={() => setActiveTab('settings')}
            title="Open Settings & Profile"
            style={{
              width: '34px',
              height: '34px',
              borderRadius: '50%',
              backgroundColor: '#BE123C',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '14px',
              fontWeight: '700',
              cursor: 'pointer',
              boxShadow: '0 2px 6px rgba(190, 18, 60, 0.25)',
              userSelect: 'none'
            }}
          >
            {currentUser.initial || 'T'}
          </div>

          {/* User Name */}
          <div
            onClick={() => setActiveTab('settings')}
            title="Open Settings & Profile"
            style={{
              fontSize: '13.5px',
              fontWeight: '600',
              color: '#111827',
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
              color: '#6B7280',
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
              e.currentTarget.style.color = '#6B7280';
            }}
          >
            <LogOut size={18} strokeWidth={2} />
          </button>
        </div>
      </div>
    </header>
  );
}
