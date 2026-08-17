import React from 'react';
import { useApp } from '../context/AppContext';
import {
  LayoutDashboard,
  Users,
  Bell,
  Pill,
  Package,
  HeartHandshake,
  BarChart3,
  Camera,
  History,
  Settings,
  X
} from 'lucide-react';

export function Sidebar() {
  const { activeTab, setActiveTab, alerts = [], darkMode, mobileSidebarOpen, setMobileSidebarOpen } = useApp();
  const unreadAlertsCount = alerts.filter(a => !a.isRead).length;

  const NAV_SECTIONS = [
    {
      title: 'OVERVIEW',
      items: [
        { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
        { id: 'users', label: 'Users', icon: Users },
        { id: 'alerts', label: 'Alerts', icon: Bell, badge: unreadAlertsCount > 0 ? unreadAlertsCount : null, badgeColor: '#EF4444' },
      ]
    },
    {
      title: 'MONITORING',
      items: [
        { id: 'medication', label: 'Medication', icon: Pill },
        { id: 'inventory', label: 'Compartment inventory', icon: Package },
        { id: 'caregivers', label: 'Caregiver contacts', icon: HeartHandshake },
      ]
    },
    {
      title: 'LIVE FEED & LOGS',
      items: [
        { id: 'live_feed', label: 'Live Camera & AI', icon: Camera },
        { id: 'activity_logs', label: 'Activity logs', icon: History },
      ]
    },
    {
      title: 'SYSTEM',
      items: [
        { id: 'reports', label: 'Reports', icon: BarChart3 },
        { id: 'settings', label: 'Settings', icon: Settings },
      ]
    }
  ];

  const handleSelectTab = (id) => {
    setActiveTab(id);
    if (setMobileSidebarOpen) {
      setMobileSidebarOpen(false);
    }
  };

  return (
    <aside
      className={`sidebar-drawer ${mobileSidebarOpen ? 'open' : ''}`}
      style={{
        width: '270px',
        minWidth: '270px',
        backgroundColor: 'var(--bg-sidebar)',
        borderRight: '1px solid var(--border-light)',
        display: 'flex',
        flexDirection: 'column',
        height: '100vh',
        position: 'sticky',
        top: 0,
        overflowY: 'auto',
        userSelect: 'none',
        transition: 'background-color 0.25s ease, border-color 0.25s ease',
        zIndex: 999
      }}
    >
      {/* Brand Header */}
      <div
        style={{
          padding: '20px 20px 18px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          borderBottom: '1px solid var(--border-light)'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
          <img
            src="/logo.png"
            alt="SmartDose"
            style={{
              width: '42px',
              height: '42px',
              borderRadius: '12px',
              objectFit: 'cover',
              boxShadow: '0 3px 10px rgba(16, 185, 129, 0.28)',
              flexShrink: 0
            }}
            onError={(e) => {
              e.currentTarget.style.display = 'none';
            }}
          />
          <div>
            <div style={{ fontSize: '16.5px', fontWeight: '800', color: 'var(--text-main)', letterSpacing: '-0.02em', lineHeight: '1.2' }}>
              SmartDose
            </div>
            <div style={{ fontSize: '12px', fontWeight: '500', color: 'var(--text-subtle)', marginTop: '2px' }}>
              Admin console
            </div>
          </div>
        </div>

        {/* Mobile Close Button */}
        <button
          className="show-on-tablet"
          onClick={() => setMobileSidebarOpen(false)}
          aria-label="Close navigation drawer"
          style={{
            display: 'none',
            alignItems: 'center',
            justifyContent: 'center',
            width: '34px',
            height: '34px',
            borderRadius: '9px',
            border: '1px solid var(--border-light)',
            backgroundColor: 'var(--bg-subtle)',
            color: 'var(--text-subtle)',
            cursor: 'pointer'
          }}
        >
          <X size={18} strokeWidth={2.2} />
        </button>
      </div>

      {/* Navigation Sections */}
      <div style={{ padding: '16px 12px 28px', display: 'flex', flexDirection: 'column', gap: '18px' }}>
        {NAV_SECTIONS.map((sec) => (
          <div key={sec.title}>
            <div
              style={{
                fontSize: '10.5px',
                fontWeight: '700',
                letterSpacing: '0.08em',
                color: 'var(--text-faint)',
                padding: '4px 14px 6px',
                textTransform: 'uppercase'
              }}
            >
              {sec.title}
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '3px' }}>
              {sec.items.map((item) => {
                const Icon = item.icon;
                const isActive = activeTab === item.id;
                const activeBg = darkMode ? '#064E3B' : '#D1FAE5';
                const activeColor = darkMode ? '#34D399' : '#065F46';

                return (
                  <button
                    key={item.id}
                    onClick={() => handleSelectTab(item.id)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '12px',
                      padding: '10px 14px',
                      borderRadius: '11px',
                      border: 'none',
                      backgroundColor: isActive ? activeBg : 'transparent',
                      color: isActive ? activeColor : 'var(--text-muted)',
                      fontWeight: isActive ? '700' : '500',
                      fontSize: '13.5px',
                      textAlign: 'left',
                      cursor: 'pointer',
                      transition: 'all 0.15s ease',
                      width: '100%'
                    }}
                    onMouseEnter={(e) => {
                      if (!isActive) {
                        e.currentTarget.style.backgroundColor = 'var(--bg-hover)';
                        e.currentTarget.style.color = 'var(--text-main)';
                      }
                    }}
                    onMouseLeave={(e) => {
                      if (!isActive) {
                        e.currentTarget.style.backgroundColor = 'transparent';
                        e.currentTarget.style.color = 'var(--text-muted)';
                      }
                    }}
                  >
                    <Icon
                      size={19}
                      strokeWidth={isActive ? 2.3 : 1.9}
                      style={{ color: isActive ? (darkMode ? '#34D399' : '#059669') : 'var(--text-subtle)', flexShrink: 0 }}
                    />
                    <span style={{ flex: 1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {item.label}
                    </span>
                    {item.badge != null && (
                      <span
                        style={{
                          backgroundColor: item.badgeColor || '#EF4444',
                          color: '#FFFFFF',
                          fontSize: '11px',
                          fontWeight: '800',
                          padding: '1px 7px',
                          borderRadius: '9999px',
                          minWidth: '20px',
                          textAlign: 'center'
                        }}
                      >
                        {item.badge}
                      </span>
                    )}
                  </button>
                );
              })}
            </div>
          </div>
        ))}
      </div>
    </aside>
  );
}

