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
  Settings
} from 'lucide-react';

export function Sidebar() {
  const { activeTab, setActiveTab, alerts } = useApp();

  const NAV_SECTIONS = [
    {
      title: 'OVERVIEW',
      items: [
        { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
        { id: 'users', label: 'Users', icon: Users },
        { id: 'alerts', label: 'Alerts', icon: Bell, badge: alerts.length > 0 ? alerts.length : null, badgeColor: '#EF4444' },
      ]
    },
    {
      title: 'MONITORING',
      items: [
        { id: 'medication', label: 'Medication', icon: Pill },
        { id: 'inventory', label: 'Inventory', icon: Package },
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

  return (
    <aside
      style={{
        width: '270px',
        minWidth: '270px',
        backgroundColor: '#FFFFFF',
        borderRight: '1px solid #E6EFE9',
        display: 'flex',
        flexDirection: 'column',
        height: '100vh',
        position: 'sticky',
        top: 0,
        overflowY: 'auto',
        userSelect: 'none'
      }}
    >
      {/* Brand Header */}
      <div
        style={{
          padding: '22px 22px 18px',
          display: 'flex',
          alignItems: 'center',
          gap: '14px',
          borderBottom: '1px solid #F0F5F2'
        }}
      >
        <img
          src="/logo.png"
          alt="SmartDose"
          style={{
            width: '46px',
            height: '46px',
            borderRadius: '13px',
            objectFit: 'cover',
            boxShadow: '0 3px 10px rgba(16, 185, 129, 0.28)',
            flexShrink: 0
          }}
          onError={(e) => {
            e.currentTarget.style.display = 'none';
          }}
        />
        <div>
          <div style={{ fontSize: '16.5px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', lineHeight: '1.2' }}>
            SmartDose
          </div>
          <div style={{ fontSize: '12px', fontWeight: '500', color: '#6B7280', marginTop: '2px' }}>
            Admin console
          </div>
        </div>
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
                color: '#9CA3AF',
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
                return (
                  <button
                    key={item.id}
                    onClick={() => setActiveTab(item.id)}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '12px',
                      padding: '10px 14px',
                      borderRadius: '11px',
                      border: 'none',
                      backgroundColor: isActive ? '#D1FAE5' : 'transparent',
                      color: isActive ? '#065F46' : '#4B5563',
                      fontWeight: isActive ? '700' : '500',
                      fontSize: '14px',
                      textAlign: 'left',
                      cursor: 'pointer',
                      transition: 'all 0.15s ease',
                      width: '100%'
                    }}
                    onMouseEnter={(e) => {
                      if (!isActive) {
                        e.currentTarget.style.backgroundColor = '#F0FDF4';
                        e.currentTarget.style.color = '#111827';
                      }
                    }}
                    onMouseLeave={(e) => {
                      if (!isActive) {
                        e.currentTarget.style.backgroundColor = 'transparent';
                        e.currentTarget.style.color = '#4B5563';
                      }
                    }}
                  >
                    <Icon
                      size={20}
                      strokeWidth={isActive ? 2.3 : 1.9}
                      style={{ color: isActive ? '#059669' : '#6B7280', flexShrink: 0 }}
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
                          fontWeight: '700',
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
