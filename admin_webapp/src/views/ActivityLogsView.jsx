import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import { Activity, Search, Filter, Clock, Download } from 'lucide-react';

export function ActivityLogsView() {
  const { activities, showToast } = useApp();
  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState('all');

  const filteredLogs = activities.filter((act) => {
    const matchSearch =
      !searchTerm ||
      act.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      act.patientName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (act.deviceId || '').toLowerCase().includes(searchTerm.toLowerCase());
    const matchType = filterType === 'all' || act.type === filterType;
    return matchSearch && matchType;
  });

  const handleExport = () => {
    const jsonStr = JSON.stringify(activities, null, 2);
    const blob = new Blob([jsonStr], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `smartdose_activity_logs_${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    showToast('Activity logs exported successfully');
  };

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      
      {/* ── Header ── */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
            Activity & Audit Logs
          </h1>
          <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
            Chronological audit trail of all dispense events, face verifications, and system actions.
          </p>
        </div>

        <button
          onClick={handleExport}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            padding: '9px 16px',
            borderRadius: '10px',
            border: '1px solid #D1D5DB',
            backgroundColor: '#FFFFFF',
            color: '#374151',
            fontSize: '13px',
            fontWeight: '600',
            cursor: 'pointer',
            boxShadow: '0 1px 2px rgba(0,0,0,0.03)'
          }}
        >
          <Download size={15} /> Export JSON
        </button>
      </div>

      {/* ── Search & Filter Toolbar ── */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px', flexWrap: 'wrap' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flex: 1, minWidth: '260px' }}>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              backgroundColor: '#FFFFFF',
              border: '1px solid #E6EFE9',
              borderRadius: '12px',
              padding: '0 14px',
              height: '42px',
              flex: 1,
              maxWidth: '380px'
            }}
          >
            <Search size={16} style={{ color: '#9CA3AF' }} />
            <input
              type="text"
              placeholder="Search by event, patient, or device ID..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{
                border: 'none',
                outline: 'none',
                fontSize: '13.5px',
                color: '#111827',
                width: '100%',
                backgroundColor: 'transparent'
              }}
            />
          </div>

          <select
            value={filterType}
            onChange={(e) => setFilterType(e.target.value)}
            style={{
              height: '42px',
              padding: '0 14px',
              backgroundColor: '#FFFFFF',
              border: '1px solid #E6EFE9',
              borderRadius: '12px',
              fontSize: '13px',
              color: '#374151',
              fontWeight: '500',
              outline: 'none',
              cursor: 'pointer'
            }}
          >
            <option value="all">All Events</option>
            <option value="dispense_success">Dispense Success</option>
            <option value="face_verified">Face Verified</option>
            <option value="dose_missed">Dose Missed</option>
            <option value="compartment_empty">Compartment Alerts</option>
          </select>
        </div>

        <div style={{ fontSize: '13px', color: '#6B7280', fontWeight: '500' }}>
          Showing <strong>{filteredLogs.length}</strong> logged events
        </div>
      </div>

      {/* ── Main Logs Table ── */}
      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', overflow: 'hidden', boxShadow: 'var(--shadow-card)' }}>
        <div style={{ display: 'flex', flexDirection: 'column' }}>
          {filteredLogs.map((log, idx) => (
            <div
              key={log.id}
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '16px 20px',
                borderBottom: idx === filteredLogs.length - 1 ? 'none' : '1px solid #F0F5F2'
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                <div
                  style={{
                    width: '36px',
                    height: '36px',
                    borderRadius: '10px',
                    backgroundColor: log.type === 'dose_missed' ? '#FEE2E2' : '#ECFDF5',
                    color: log.type === 'dose_missed' ? '#DC2626' : '#059669',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    flexShrink: 0
                  }}
                >
                  <Activity size={18} strokeWidth={2.3} />
                </div>
                <div>
                  <div style={{ fontSize: '14px', fontWeight: '700', color: '#111827' }}>
                    {log.title}
                  </div>
                  <div style={{ fontSize: '12px', color: '#6B7280', marginTop: '2px' }}>
                    {log.patientName} • Device: <code>{log.deviceId}</code>
                  </div>
                </div>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '12px', color: '#9CA3AF', fontWeight: '600' }}>
                <Clock size={13} /> {log.timeAgo}
              </div>
            </div>
          ))}
        </div>
      </div>

    </div>
  );
}
