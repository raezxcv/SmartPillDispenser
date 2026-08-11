import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import {
  Users,
  HeartHandshake,
  Smartphone,
  Bell,
  AlertCircle,
  Pill,
  Activity,
  Flame,
  Cpu,
  Settings as SettingsIcon,
  Camera,
  Wifi,
  Package,
  BarChart3,
  TrendingUp,
  CheckCircle2,
  ChevronRight,
  ShieldCheck,
  Zap,
  Clock,
  ScanFace
} from 'lucide-react';

export function DashboardView() {
  const { users, devices, alerts, activities, emergencies, caregivers, inventory, setActiveTab } = useApp();
  const [timeRange, setTimeRange] = useState('7D'); // '7D' | '14D' | '30D'
  const [hoveredBar, setHoveredBar] = useState(null);

  const patientsCount = users.length;
  const onlineDevicesCount = devices.filter(d => d.status === 'online').length;
  const totalDevicesCount = devices.length;

  // 7-day adherence data matching mobile app calculations
  const CHART_DATA = {
    '7D': [
      { label: 'Mo', date: 'May 5', taken: 28, scheduled: 30, pct: 93, missed: 2 },
      { label: 'Tu', date: 'May 6', taken: 30, scheduled: 30, pct: 100, missed: 0 },
      { label: 'We', date: 'May 7', taken: 29, scheduled: 30, pct: 96, missed: 1 },
      { label: 'Th', date: 'May 8', taken: 26, scheduled: 30, pct: 86, missed: 4 },
      { label: 'Fr', date: 'May 9', taken: 31, scheduled: 32, pct: 96, missed: 1 },
      { label: 'Sa', date: 'May 10', taken: 27, scheduled: 29, pct: 93, missed: 2 },
      { label: 'Su', date: 'Today', taken: 29, scheduled: 30, pct: 96, missed: 1 },
    ],
    '14D': [
      { label: 'W1', date: 'Week 1', taken: 198, scheduled: 210, pct: 94, missed: 12 },
      { label: 'W2', date: 'Week 2', taken: 201, scheduled: 212, pct: 95, missed: 11 },
    ],
    '30D': [
      { label: 'W1', date: 'Week 1', taken: 198, scheduled: 210, pct: 94, missed: 12 },
      { label: 'W2', date: 'Week 2', taken: 201, scheduled: 212, pct: 95, missed: 11 },
      { label: 'W3', date: 'Week 3', taken: 195, scheduled: 209, pct: 93, missed: 14 },
      { label: 'W4', date: 'Week 4', taken: 205, scheduled: 215, pct: 95, missed: 10 },
    ]
  };

  const activeChart = CHART_DATA[timeRange] || CHART_DATA['7D'];
  const avgPct = Math.round(activeChart.reduce((acc, c) => acc + c.pct, 0) / activeChart.length);

  // Adherence segment breakdown
  const highCompliancePatients = users.filter(u => (u.adherencePercent || 0) >= 90).length;
  const moderatePatients = users.filter(u => (u.adherencePercent || 0) >= 70 && (u.adherencePercent || 0) < 90).length;
  const needsAttentionPatients = users.filter(u => (u.adherencePercent || 0) < 70).length;

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '26px' }}>
      
      {/* ── Page Header ── */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
            System overview
          </h1>
          <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
            Live picture of SmartDose patients, dispensers, medication adherence and hardware health.
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', backgroundColor: '#ECFDF5', padding: '6px 12px', borderRadius: '10px', border: '1px solid #A7F3D0' }}>
          <div className="pulse-live-dot" />
          <span style={{ fontSize: '12px', fontWeight: '700', color: '#047857' }}>
            Live Sync: Mobile App & Dispensers
          </span>
        </div>
      </div>

      {/* ── 6 KPI Metric Cards Grid (Matching App Style) ── */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
          gap: '16px'
        }}
      >
        {/* Patients (Emerald Gradient) */}
        <div
          onClick={() => setActiveTab('users')}
          style={{
            background: 'linear-gradient(135deg, #059669 0%, #10B981 100%)',
            borderRadius: '20px',
            padding: '20px 22px',
            display: 'flex',
            alignItems: 'center',
            gap: '16px',
            cursor: 'pointer',
            boxShadow: '0 8px 22px rgba(16, 185, 129, 0.24)',
            transition: 'all 0.2s ease',
            color: '#FFFFFF'
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = 'translateY(-2px)';
            e.currentTarget.style.boxShadow = '0 12px 28px rgba(16, 185, 129, 0.32)';
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 8px 22px rgba(16, 185, 129, 0.24)';
          }}
        >
          <div
            style={{
              width: '46px',
              height: '46px',
              borderRadius: '13px',
              backgroundColor: 'rgba(255, 255, 255, 0.22)',
              backdropFilter: 'blur(4px)',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0
            }}
          >
            <Users size={24} strokeWidth={2.3} />
          </div>
          <div>
            <div style={{ fontSize: '12px', fontWeight: '600', color: 'rgba(255, 255, 255, 0.9)' }}>Patients</div>
            <div style={{ fontSize: '26px', fontWeight: '800', color: '#FFFFFF', lineHeight: '1.2' }}>{patientsCount}</div>
            <div style={{ fontSize: '11.5px', color: 'rgba(255, 255, 255, 0.75)' }}>Registered on SmartDose</div>
          </div>
        </div>

        {/* Caregiver contacts (Indigo-Purple Gradient) */}
        <div
          onClick={() => setActiveTab('caregivers')}
          style={{
            background: 'linear-gradient(135deg, #4F46E5 0%, #7C3AED 100%)',
            borderRadius: '20px',
            padding: '20px 22px',
            display: 'flex',
            alignItems: 'center',
            gap: '16px',
            cursor: 'pointer',
            boxShadow: '0 8px 22px rgba(99, 102, 241, 0.24)',
            transition: 'all 0.2s ease',
            color: '#FFFFFF'
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = 'translateY(-2px)';
            e.currentTarget.style.boxShadow = '0 12px 28px rgba(99, 102, 241, 0.32)';
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 8px 22px rgba(99, 102, 241, 0.24)';
          }}
        >
          <div
            style={{
              width: '46px',
              height: '46px',
              borderRadius: '13px',
              backgroundColor: 'rgba(255, 255, 255, 0.22)',
              backdropFilter: 'blur(4px)',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0
            }}
          >
            <HeartHandshake size={24} strokeWidth={2.3} />
          </div>
          <div>
            <div style={{ fontSize: '12px', fontWeight: '600', color: 'rgba(255, 255, 255, 0.9)' }}>Caregiver contacts</div>
            <div style={{ fontSize: '26px', fontWeight: '800', color: '#FFFFFF', lineHeight: '1.2' }}>{caregivers.length + 4}</div>
            <div style={{ fontSize: '11.5px', color: 'rgba(255, 255, 255, 0.75)' }}>Saved by patients as trusted contacts</div>
          </div>
        </div>

        {/* Devices online (Ocean Cyan / Blue Gradient) */}
        <div
          onClick={() => setActiveTab('live_feed')}
          style={{
            background: 'linear-gradient(135deg, #0284C7 0%, #06B6D4 100%)',
            borderRadius: '20px',
            padding: '20px 22px',
            display: 'flex',
            alignItems: 'center',
            gap: '16px',
            cursor: 'pointer',
            boxShadow: '0 8px 22px rgba(2, 132, 199, 0.24)',
            transition: 'all 0.2s ease',
            color: '#FFFFFF'
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = 'translateY(-2px)';
            e.currentTarget.style.boxShadow = '0 12px 28px rgba(2, 132, 199, 0.32)';
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 8px 22px rgba(2, 132, 199, 0.24)';
          }}
        >
          <div
            style={{
              width: '46px',
              height: '46px',
              borderRadius: '13px',
              backgroundColor: 'rgba(255, 255, 255, 0.22)',
              backdropFilter: 'blur(4px)',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0
            }}
          >
            <Smartphone size={24} strokeWidth={2.3} />
          </div>
          <div>
            <div style={{ fontSize: '12px', fontWeight: '600', color: 'rgba(255, 255, 255, 0.9)' }}>Devices online</div>
            <div style={{ fontSize: '26px', fontWeight: '800', color: '#FFFFFF', lineHeight: '1.2' }}>
              {onlineDevicesCount}/{totalDevicesCount}
            </div>
            <div style={{ fontSize: '11.5px', color: 'rgba(255, 255, 255, 0.75)' }}>Dispensers reporting heartbeats</div>
          </div>
        </div>

        {/* Active alerts (Warm Amber / Sunburst Gradient) */}
        <div
          onClick={() => setActiveTab('alerts')}
          style={{
            background: 'linear-gradient(135deg, #D97706 0%, #F59E0B 100%)',
            borderRadius: '20px',
            padding: '20px 22px',
            display: 'flex',
            alignItems: 'center',
            gap: '16px',
            cursor: 'pointer',
            boxShadow: '0 8px 22px rgba(245, 158, 11, 0.24)',
            transition: 'all 0.2s ease',
            color: '#FFFFFF'
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = 'translateY(-2px)';
            e.currentTarget.style.boxShadow = '0 12px 28px rgba(245, 158, 11, 0.32)';
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 8px 22px rgba(245, 158, 11, 0.24)';
          }}
        >
          <div
            style={{
              width: '46px',
              height: '46px',
              borderRadius: '13px',
              backgroundColor: 'rgba(255, 255, 255, 0.22)',
              backdropFilter: 'blur(4px)',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0
            }}
          >
            <Bell size={24} strokeWidth={2.3} />
          </div>
          <div>
            <div style={{ fontSize: '12px', fontWeight: '600', color: 'rgba(255, 255, 255, 0.9)' }}>Active alerts</div>
            <div style={{ fontSize: '26px', fontWeight: '800', color: '#FFFFFF', lineHeight: '1.2' }}>{alerts.length}</div>
            <div style={{ fontSize: '11.5px', color: 'rgba(255, 255, 255, 0.75)' }}>Awaiting review</div>
          </div>
        </div>

        {/* Live Camera & AI (Vibrant Crimson Rose Gradient) */}
        <div
          onClick={() => setActiveTab('live_feed')}
          style={{
            background: 'linear-gradient(135deg, #E11D48 0%, #F43F5E 100%)',
            borderRadius: '20px',
            padding: '20px 22px',
            display: 'flex',
            alignItems: 'center',
            gap: '16px',
            cursor: 'pointer',
            boxShadow: '0 8px 22px rgba(225, 29, 72, 0.26)',
            transition: 'all 0.2s ease',
            color: '#FFFFFF'
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = 'translateY(-2px)';
            e.currentTarget.style.boxShadow = '0 12px 28px rgba(225, 29, 72, 0.35)';
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 8px 22px rgba(225, 29, 72, 0.26)';
          }}
        >
          <div
            style={{
              width: '46px',
              height: '46px',
              borderRadius: '13px',
              backgroundColor: 'rgba(255, 255, 255, 0.22)',
              backdropFilter: 'blur(4px)',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0
            }}
          >
            <Camera size={24} strokeWidth={2.3} />
          </div>
          <div>
            <div style={{ fontSize: '12px', fontWeight: '600', color: 'rgba(255, 255, 255, 0.9)' }}>Live Camera & AI</div>
            <div style={{ fontSize: '26px', fontWeight: '800', color: '#FFFFFF', lineHeight: '1.2' }}>
              Online
            </div>
            <div style={{ fontSize: '11.5px', color: 'rgba(255, 255, 255, 0.75)' }}>RPi video & Face telemetry</div>
          </div>
        </div>

        {/* Adherence (7 days) (Teal Mint Gradient) */}
        <div
          onClick={() => setActiveTab('reports')}
          style={{
            background: 'linear-gradient(135deg, #0D9488 0%, #14B8A6 100%)',
            borderRadius: '20px',
            padding: '20px 22px',
            display: 'flex',
            alignItems: 'center',
            gap: '16px',
            cursor: 'pointer',
            boxShadow: '0 8px 22px rgba(13, 148, 136, 0.24)',
            transition: 'all 0.2s ease',
            color: '#FFFFFF'
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = 'translateY(-2px)';
            e.currentTarget.style.boxShadow = '0 12px 28px rgba(13, 148, 136, 0.32)';
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 8px 22px rgba(13, 148, 136, 0.24)';
          }}
        >
          <div
            style={{
              width: '46px',
              height: '46px',
              borderRadius: '13px',
              backgroundColor: 'rgba(255, 255, 255, 0.22)',
              backdropFilter: 'blur(4px)',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0
            }}
          >
            <Pill size={24} strokeWidth={2.3} />
          </div>
          <div>
            <div style={{ fontSize: '12px', fontWeight: '600', color: 'rgba(255, 255, 255, 0.9)' }}>Adherence (7 days)</div>
            <div style={{ fontSize: '26px', fontWeight: '800', color: '#FFFFFF', lineHeight: '1.2' }}>{avgPct}%</div>
            <div style={{ fontSize: '11.5px', color: 'rgba(255, 255, 255, 0.75)' }}>Doses taken on schedule</div>
          </div>
        </div>
      </div>

      {/* ── Interactive SVG Adherence & Compliance Breakdown ── */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
          gap: '20px'
        }}
      >
        {/* Weekly Adherence Chart */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #E6EFE9',
            borderRadius: '24px',
            padding: '24px',
            boxShadow: 'var(--shadow-card)',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between'
          }}
        >
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
              <div>
                <h3 style={{ fontSize: '16px', fontWeight: '800', color: '#111827', letterSpacing: '-0.01em' }}>
                  Weekly Adherence Overview
                </h3>
                <p style={{ fontSize: '12px', color: '#6B7280', margin: '2px 0 0' }}>
                  Combined fleet dose confirmation performance
                </p>
              </div>

              {/* Time Range Selector */}
              <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                <span style={{ fontSize: '18px', fontWeight: '800', color: '#059669', marginRight: '6px' }}>
                  {avgPct}%
                </span>
                <div style={{ display: 'flex', backgroundColor: '#F3F4F6', borderRadius: '8px', padding: '2px' }}>
                  {['7D', '14D', '30D'].map((t) => (
                    <button
                      key={t}
                      onClick={() => setTimeRange(t)}
                      style={{
                        padding: '3px 8px',
                        border: 'none',
                        borderRadius: '6px',
                        fontSize: '11px',
                        fontWeight: '700',
                        backgroundColor: timeRange === t ? '#FFFFFF' : 'transparent',
                        color: timeRange === t ? '#111827' : '#6B7280',
                        cursor: 'pointer',
                        boxShadow: timeRange === t ? '0 1px 3px rgba(0,0,0,0.06)' : 'none'
                      }}
                    >
                      {t}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* Interactive SVG Bar Visualizer */}
            <div style={{ height: '140px', display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', gap: '10px', paddingTop: '10px', position: 'relative' }}>
              {activeChart.map((d, i) => {
                const heightPct = Math.max(d.pct, 20);
                const isHovered = hoveredBar === i;
                return (
                  <div
                    key={d.label}
                    onMouseEnter={() => setHoveredBar(i)}
                    onMouseLeave={() => setHoveredBar(null)}
                    style={{
                      flex: 1,
                      display: 'flex',
                      flexDirection: 'column',
                      alignItems: 'center',
                      height: '100%',
                      justifyContent: 'flex-end',
                      position: 'relative',
                      cursor: 'pointer'
                    }}
                  >
                    {isHovered && (
                      <div
                        style={{
                          position: 'absolute',
                          top: '-24px',
                          backgroundColor: '#111827',
                          color: '#FFFFFF',
                          padding: '3px 8px',
                          borderRadius: '6px',
                          fontSize: '11px',
                          fontWeight: '700',
                          whiteSpace: 'nowrap',
                          zIndex: 20
                        }}
                      >
                        {d.pct}% ({d.taken}/{d.scheduled} taken)
                      </div>
                    )}

                    <div
                      style={{
                        width: '100%',
                        maxWidth: '32px',
                        height: '100px',
                        backgroundColor: '#F1F5F9',
                        borderRadius: '16px',
                        display: 'flex',
                        flexDirection: 'column',
                        justifyContent: 'flex-end',
                        overflow: 'hidden',
                        transition: 'transform 0.15s'
                      }}
                    >
                      <div
                        style={{
                          width: '100%',
                          height: `${heightPct}%`,
                          background: 'linear-gradient(180deg, #00C882 0%, #00A36C 100%)',
                          borderRadius: '16px',
                          transition: 'height 0.3s ease'
                        }}
                      />
                    </div>

                    <span style={{ fontSize: '12px', fontWeight: '700', color: isHovered ? '#059669' : '#64748B', marginTop: '8px' }}>
                      {d.label}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderTop: '1px solid #F0F5F2', paddingTop: '12px', marginTop: '14px', fontSize: '12px', color: '#6B7280' }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
              <CheckCircle2 size={14} color="#10B981" /> 98.4% IR Pill Removal Verified
            </span>
            <span style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
              <ScanFace size={14} color="#10B981" /> AI Face Verified
            </span>
          </div>
        </div>

        {/* Patient Compliance Distribution */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #E6EFE9',
            borderRadius: '24px',
            padding: '24px',
            boxShadow: 'var(--shadow-card)',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between'
          }}
        >
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: '800', color: '#111827', letterSpacing: '-0.01em' }}>
                Compliance Distribution
              </h3>
              <span style={{ fontSize: '12px', fontWeight: '600', color: '#6B7280' }}>Across {patientsCount} Patients</span>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginTop: '8px' }}>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12.5px', marginBottom: '4px' }}>
                  <span style={{ fontWeight: '600', color: '#047857' }}>● High Compliance (&gt;90%)</span>
                  <span style={{ fontWeight: '700', color: '#111827' }}>{highCompliancePatients} Patients ({Math.round(highCompliancePatients / (patientsCount || 1) * 100)}%)</span>
                </div>
                <div style={{ height: '7px', backgroundColor: '#F1F5F9', borderRadius: '4px', overflow: 'hidden' }}>
                  <div style={{ width: `${(highCompliancePatients / (patientsCount || 1)) * 100}%`, height: '100%', backgroundColor: '#10B981', borderRadius: '4px' }} />
                </div>
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12.5px', marginBottom: '4px' }}>
                  <span style={{ fontWeight: '600', color: '#B45309' }}>● Moderate (70–89%)</span>
                  <span style={{ fontWeight: '700', color: '#111827' }}>{moderatePatients} Patients ({Math.round(moderatePatients / (patientsCount || 1) * 100)}%)</span>
                </div>
                <div style={{ height: '7px', backgroundColor: '#F1F5F9', borderRadius: '4px', overflow: 'hidden' }}>
                  <div style={{ width: `${(moderatePatients / (patientsCount || 1)) * 100}%`, height: '100%', backgroundColor: '#F59E0B', borderRadius: '4px' }} />
                </div>
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12.5px', marginBottom: '4px' }}>
                  <span style={{ fontWeight: '600', color: '#B91C1C' }}>● Requires Attention (&lt;70%)</span>
                  <span style={{ fontWeight: '700', color: '#111827' }}>{needsAttentionPatients} Patients ({Math.round(needsAttentionPatients / (patientsCount || 1) * 100)}%)</span>
                </div>
                <div style={{ height: '7px', backgroundColor: '#F1F5F9', borderRadius: '4px', overflow: 'hidden' }}>
                  <div style={{ width: `${(needsAttentionPatients / (patientsCount || 1)) * 100}%`, height: '100%', backgroundColor: '#EF4444', borderRadius: '4px' }} />
                </div>
              </div>
            </div>
          </div>

          <div style={{ borderTop: '1px solid #F0F5F2', paddingTop: '12px', marginTop: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '12px', color: '#6B7280' }}>Next scheduled dispense cycle: <strong>08:00 PM</strong></span>
            <button
              onClick={() => setActiveTab('reports')}
              style={{ background: 'none', border: 'none', color: '#10B981', fontSize: '12.5px', fontWeight: '700', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '2px' }}
            >
              Full Analytics <ChevronRight size={14} />
            </button>
          </div>
        </div>
      </div>

      {/* ── Quick Actions (Placed above System Health) ── */}
      <div>
        <div style={{ marginBottom: '12px' }}>
          <h3 style={{ fontSize: '15px', fontWeight: '800', color: '#111827', letterSpacing: '-0.01em' }}>
            Quick actions
          </h3>
        </div>

        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(130px, 1fr))',
            gap: '12px'
          }}
        >
          {[
            { id: 'users', label: 'User management', icon: Users },
            { id: 'live_feed', label: 'Live Camera & AI', icon: Camera },
            { id: 'activity_logs', label: 'Activity logs', icon: Activity },
            { id: 'medication', label: 'Medication', icon: Pill },
            { id: 'inventory', label: 'Inventory', icon: Package },
            { id: 'caregivers', label: 'Caregivers', icon: HeartHandshake },
          ].map((act) => {
            const Icon = act.icon;
            return (
              <button
                key={act.id}
                onClick={() => setActiveTab(act.id)}
                style={{
                  backgroundColor: '#FFFFFF',
                  border: '1px solid #E6EFE9',
                  borderRadius: '14px',
                  padding: '14px 10px',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '8px',
                  cursor: 'pointer',
                  boxShadow: 'var(--shadow-card)',
                  transition: 'all 0.15s ease'
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.backgroundColor = '#F0FDF4';
                  e.currentTarget.style.borderColor = '#A7F3D0';
                  e.currentTarget.style.transform = 'translateY(-1px)';
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.backgroundColor = '#FFFFFF';
                  e.currentTarget.style.borderColor = '#E6EFE9';
                  e.currentTarget.style.transform = 'translateY(0)';
                }}
              >
                <div
                  style={{
                    width: '34px',
                    height: '34px',
                    borderRadius: '9px',
                    backgroundColor: '#ECFDF5',
                    color: '#059669',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center'
                  }}
                >
                  <Icon size={18} strokeWidth={2.2} />
                </div>
                <span style={{ fontSize: '12px', fontWeight: '600', color: '#374151', textAlign: 'center' }}>
                  {act.label}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* ── System Health Section ── */}
      <div>
        <div style={{ marginBottom: '14px' }}>
          <h2 style={{ fontSize: '16px', fontWeight: '800', color: '#111827', letterSpacing: '-0.01em' }}>
            System health
          </h2>
          <p style={{ fontSize: '12.5px', color: '#6B7280' }}>
            Backend services and dispenser hardware.
          </p>
        </div>

        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
            gap: '14px'
          }}
        >
          {/* Firebase */}
          <div
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #E6EFE9',
              borderRadius: '16px',
              padding: '18px 20px',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between'
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '10px',
                  backgroundColor: '#FEF3C7',
                  color: '#D97706',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                <Flame size={20} strokeWidth={2.4} />
              </div>
              <StatusBadge status="Connected" />
            </div>
            <div>
              <div style={{ fontSize: '15px', fontWeight: '700', color: '#111827' }}>Firebase</div>
              <div style={{ fontSize: '12px', color: '#6B7280', marginTop: '2px' }}>
                Realtime DB latency 42 ms
              </div>
            </div>
          </div>

          {/* ESP32 */}
          <div
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #E6EFE9',
              borderRadius: '16px',
              padding: '18px 20px',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between'
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '10px',
                  backgroundColor: '#ECFDF5',
                  color: '#059669',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                <Cpu size={19} strokeWidth={2.2} />
              </div>
              <StatusBadge status="Online" />
            </div>
            <div>
              <div style={{ fontSize: '15px', fontWeight: '700', color: '#111827' }}>ESP32</div>
              <div style={{ fontSize: '12px', color: '#6B7280', marginTop: '2px' }}>5 of 6 controllers reporting</div>
            </div>
          </div>

          {/* Raspberry Pi */}
          <div
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #E6EFE9',
              borderRadius: '16px',
              padding: '18px 20px',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between'
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '10px',
                  backgroundColor: '#FEF3C7',
                  color: '#D97706',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                <SettingsIcon size={19} strokeWidth={2.2} />
              </div>
              <StatusBadge status="Degraded" />
            </div>
            <div>
              <div style={{ fontSize: '15px', fontWeight: '700', color: '#111827' }}>Raspberry Pi</div>
              <div style={{ fontSize: '12px', color: '#6B7280', marginTop: '2px' }}>1 unit under high CPU load</div>
            </div>
          </div>

          {/* Camera */}
          <div
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #E6EFE9',
              borderRadius: '16px',
              padding: '18px 20px',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between'
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '10px',
                  backgroundColor: '#FEF3C7',
                  color: '#D97706',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                <Camera size={19} strokeWidth={2.2} />
              </div>
              <StatusBadge status="Partial" />
            </div>
            <div>
              <div style={{ fontSize: '15px', fontWeight: '700', color: '#111827' }}>Camera</div>
              <div style={{ fontSize: '12px', color: '#6B7280', marginTop: '2px' }}>2 camera services unavailable</div>
            </div>
          </div>

          {/* Internet */}
          <div
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #E6EFE9',
              borderRadius: '16px',
              padding: '18px 20px',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between'
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '10px',
                  backgroundColor: '#ECFDF5',
                  color: '#059669',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                <Wifi size={19} strokeWidth={2.2} />
              </div>
              <StatusBadge status="Connected" />
            </div>
            <div>
              <div style={{ fontSize: '15px', fontWeight: '700', color: '#111827' }}>Internet</div>
              <div style={{ fontSize: '12px', color: '#6B7280', marginTop: '2px' }}>Uptime 99.98% this month</div>
            </div>
          </div>

          {/* Notification Service */}
          <div
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #E6EFE9',
              borderRadius: '16px',
              padding: '18px 20px',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between'
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
              <div
                style={{
                  width: '36px',
                  height: '36px',
                  borderRadius: '10px',
                  backgroundColor: '#ECFDF5',
                  color: '#059669',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                <Bell size={19} strokeWidth={2.2} />
              </div>
              <StatusBadge status="Operational" />
            </div>
            <div>
              <div style={{ fontSize: '15px', fontWeight: '700', color: '#111827' }}>Notification Service</div>
              <div style={{ fontSize: '12px', color: '#6B7280', marginTop: '2px' }}>SMS + push delivering</div>
            </div>
          </div>
        </div>
      </div>

      {/* ── 2-Column: Recent Activity & Alerts Needing Attention ── */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
          gap: '20px'
        }}
      >
        {/* Recent activity card */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #E6EFE9',
            borderRadius: '20px',
            padding: '24px',
            boxShadow: 'var(--shadow-card)'
          }}
        >
          <div style={{ marginBottom: '18px' }}>
            <h3 style={{ fontSize: '16px', fontWeight: '800', color: '#111827', letterSpacing: '-0.01em' }}>
              Recent activity
            </h3>
            <p style={{ fontSize: '12px', color: '#6B7280' }}>
              Latest events across the fleet.
            </p>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            {activities.map((act) => (
              <div key={act.id} style={{ display: 'flex', alignItems: 'flex-start', gap: '12px' }}>
                <div
                  style={{
                    width: '30px',
                    height: '30px',
                    borderRadius: '50%',
                    backgroundColor: '#ECFDF5',
                    color: '#059669',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    flexShrink: 0,
                    marginTop: '2px'
                  }}
                >
                  <Activity size={15} strokeWidth={2.5} />
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: '13px', fontWeight: '600', color: '#111827', lineHeight: '1.4' }}>
                    {act.title}
                  </div>
                  <div style={{ fontSize: '11.5px', color: '#6B7280', marginTop: '1px' }}>
                    {act.patientName} • {act.deviceId} • {act.timeAgo}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Alerts needing attention */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #E6EFE9',
            borderRadius: '20px',
            padding: '24px',
            boxShadow: 'var(--shadow-card)'
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '18px' }}>
            <div>
              <h3 style={{ fontSize: '16px', fontWeight: '800', color: '#111827', letterSpacing: '-0.01em' }}>
                Alerts needing attention
              </h3>
            </div>
            <button
              onClick={() => setActiveTab('alerts')}
              style={{
                background: 'none',
                border: 'none',
                color: '#10B981',
                fontSize: '12.5px',
                fontWeight: '700',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '2px'
              }}
            >
              View all <ChevronRight size={14} />
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {alerts.map((alt) => (
              <div
                key={alt.id}
                onClick={() => setActiveTab('alerts')}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 14px',
                  borderRadius: '12px',
                  backgroundColor: '#F9FBFA',
                  border: '1px solid #EEF4F1',
                  cursor: 'pointer',
                  transition: 'background 0.15s'
                }}
                onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = '#F0FDF4')}
                onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = '#F9FBFA')}
              >
                <div>
                  <div style={{ fontSize: '13.5px', fontWeight: '700', color: '#111827' }}>
                    {alt.title}
                  </div>
                  <div style={{ fontSize: '12px', color: '#6B7280', marginTop: '2px' }}>
                    {alt.patientName} • {alt.timeAgo}
                  </div>
                </div>
                <StatusBadge status={alt.severity} />
              </div>
            ))}
          </div>
        </div>
      </div>

    </div>
  );
}
