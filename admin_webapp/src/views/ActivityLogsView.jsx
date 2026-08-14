import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import {
  Activity,
  Search,
  Filter,
  Clock,
  Download,
  CheckCircle,
  XCircle,
  ScanFace,
  Camera,
  AlertTriangle,
  Image as ImageIcon
} from 'lucide-react';

export function ActivityLogsView() {
  const { activities, showToast, darkMode } = useApp();
  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState('all');

  const getLogDetails = (log) => {
    const type = (log.type || '').toLowerCase();
    const status = (log.status || '').toLowerCase();

    if (type === 'patient_detected' || status === 'detected' || type === 'face_verified') {
      return {
        bg: darkMode ? 'rgba(59, 130, 246, 0.2)' : '#DBEAFE',
        text: darkMode ? '#60A5FA' : '#1D4ED8',
        icon: ScanFace,
        label: 'Patient Detected'
      };
    }
    if (type === 'photo_captured' || status === 'captured') {
      return {
        bg: darkMode ? 'rgba(99, 102, 241, 0.2)' : '#E0E7FF',
        text: darkMode ? '#818CF8' : '#4338CA',
        icon: Camera,
        label: 'Snapshot Captured'
      };
    }
    if (status === 'missed' || type === 'dose_missed') {
      return {
        bg: darkMode ? 'rgba(239, 68, 68, 0.2)' : '#FEE2E2',
        text: darkMode ? '#F87171' : '#EF4444',
        icon: XCircle,
        label: 'Missed Dose'
      };
    }
    if (type === 'compartment_empty') {
      return {
        bg: darkMode ? 'rgba(245, 158, 11, 0.2)' : '#FEF3C7',
        text: darkMode ? '#FBBF24' : '#D97706',
        icon: AlertTriangle,
        label: 'Empty Alert'
      };
    }
    return {
      bg: darkMode ? 'rgba(16, 185, 129, 0.2)' : '#D1FAE5',
      text: darkMode ? '#34D399' : '#059669',
      icon: CheckCircle,
      label: 'Dispense Success'
    };
  };

  const filteredLogs = activities.filter((act) => {
    const matchSearch =
      !searchTerm ||
      act.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      act.patientName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (act.deviceId || '').toLowerCase().includes(searchTerm.toLowerCase());

    const type = (act.type || '').toLowerCase();
    const status = (act.status || '').toLowerCase();

    let matchType = true;
    if (filterType === 'dispense_success') {
      matchType = type === 'dispense_success' || status === 'taken';
    } else if (filterType === 'patient_detected') {
      matchType = type === 'patient_detected' || status === 'detected' || type === 'face_verified';
    } else if (filterType === 'dose_missed') {
      matchType = type === 'dose_missed' || status === 'missed';
    } else if (filterType === 'photo_captured') {
      matchType = type === 'photo_captured' || status === 'captured';
    } else if (filterType === 'compartment_empty') {
      matchType = type === 'compartment_empty';
    }

    return matchSearch && matchType;
  });

  const handleExportJSON = () => {
    const exportData = activities.map(a => ({
      id: a.id,
      title: a.title,
      patientName: a.patientName,
      deviceId: a.deviceId,
      type: a.type,
      status: a.status,
      time: a.timeAgo,
      rawTimestamp: a.timestamp
    }));
    const jsonStr = JSON.stringify(exportData, null, 2);
    const blob = new Blob([jsonStr], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `smartdose_live_activity_logs_${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    showToast('Real database activity logs exported as JSON');
  };

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      
      {/* ── Header ── */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--text-main)', letterSpacing: '-0.02em', marginBottom: '4px' }}>
            Activity & Audit Logs
          </h1>
          <p style={{ fontSize: '13.5px', color: 'var(--text-subtle)' }}>
            Real-time chronological database logs of all dispensing events, facial verifications, and dispenser snapshots.
          </p>
        </div>

        <button
          onClick={handleExportJSON}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            padding: '9px 16px',
            borderRadius: '10px',
            border: '1px solid var(--border-input)',
            backgroundColor: 'var(--bg-card)',
            color: 'var(--text-main)',
            fontSize: '13px',
            fontWeight: '600',
            cursor: 'pointer',
            boxShadow: '0 1px 2px rgba(0,0,0,0.03)',
            transition: 'all 0.15s'
          }}
          onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = 'var(--bg-hover)')}
          onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = 'var(--bg-card)')}
        >
          <Download size={15} /> Export JSON Logs
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
              backgroundColor: 'var(--bg-card)',
              border: '1px solid var(--border-light)',
              borderRadius: '12px',
              padding: '0 14px',
              height: '42px',
              flex: 1,
              maxWidth: '380px',
              boxShadow: '0 1px 2px rgba(0,0,0,0.02)'
            }}
          >
            <Search size={16} style={{ color: 'var(--text-faint)' }} />
            <input
              type="text"
              placeholder="Search by event, patient, or device ID..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{
                border: 'none',
                outline: 'none',
                fontSize: '13.5px',
                color: 'var(--text-main)',
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
              backgroundColor: 'var(--bg-card)',
              border: '1px solid var(--border-light)',
              borderRadius: '12px',
              fontSize: '13px',
              color: 'var(--text-main)',
              fontWeight: '600',
              outline: 'none',
              cursor: 'pointer',
              boxShadow: '0 1px 2px rgba(0,0,0,0.02)'
            }}
          >
            <option value="all">All Events</option>
            <option value="dispense_success">Dispense Success</option>
            <option value="patient_detected">Patient Detected</option>
            <option value="photo_captured">Camera Snapshot</option>
            <option value="dose_missed">Missed Dose</option>
            <option value="compartment_empty">Compartment Alerts</option>
          </select>
        </div>

        <div style={{ fontSize: '13px', color: 'var(--text-subtle)', fontWeight: '500' }}>
          Showing <strong>{filteredLogs.length}</strong> logged events
        </div>
      </div>

      {/* ── Main Logs Table / Card List ── */}
      <div style={{ backgroundColor: 'var(--bg-card)', border: '1px solid var(--border-light)', borderRadius: '18px', overflow: 'hidden', boxShadow: 'var(--shadow-card)' }}>
        {filteredLogs.length === 0 ? (
          <div style={{ padding: '48px 24px', textAlign: 'center', color: 'var(--text-subtle)' }}>
            <Activity size={32} style={{ color: 'var(--text-faint)', margin: '0 auto 10px' }} />
            <div style={{ fontSize: '14px', fontWeight: '600', color: 'var(--text-main)' }}>No matching activity logs found</div>
            <div style={{ fontSize: '12.5px', color: 'var(--text-faint)', marginTop: '2px' }}>Try adjusting your search query or filter</div>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {filteredLogs.map((log, idx) => {
              const details = getLogDetails(log);
              const Icon = details.icon;

              return (
                <div
                  key={log.id || idx}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '16px 20px',
                    borderBottom: idx === filteredLogs.length - 1 ? 'none' : '1px solid var(--border-light)',
                    gap: '16px',
                    flexWrap: 'wrap',
                    transition: 'background-color 0.15s ease'
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '14px', flex: 1, minWidth: '240px' }}>
                    <div
                      style={{
                        width: '40px',
                        height: '40px',
                        borderRadius: '12px',
                        backgroundColor: details.bg,
                        color: details.text,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        flexShrink: 0
                      }}
                    >
                      <Icon size={19} strokeWidth={2.3} />
                    </div>

                    <div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
                        <span style={{ fontSize: '14.5px', fontWeight: '700', color: 'var(--text-main)' }}>
                          {log.title}
                        </span>
                        <span
                          style={{
                            padding: '2px 8px',
                            borderRadius: '6px',
                            backgroundColor: details.bg,
                            color: details.text,
                            fontSize: '11px',
                            fontWeight: '700'
                          }}
                        >
                          {details.label}
                        </span>
                        {(log.capturedPhotoUrl || log.type === 'photo_captured') && (
                          <span
                            style={{
                              display: 'inline-flex',
                              alignItems: 'center',
                              gap: '3px',
                              padding: '2px 7px',
                              borderRadius: '6px',
                              backgroundColor: darkMode ? 'rgba(99, 102, 241, 0.25)' : '#E0E7FF',
                              color: darkMode ? '#818CF8' : '#4338CA',
                              fontSize: '11px',
                              fontWeight: '700'
                            }}
                          >
                            <ImageIcon size={11} /> Photo
                          </span>
                        )}
                      </div>

                      <div style={{ fontSize: '12.5px', color: 'var(--text-subtle)', marginTop: '3px' }}>
                        Patient: <strong>{log.patientName}</strong> • Device: <code>{log.deviceId}</code>
                      </div>
                    </div>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '12.5px', color: 'var(--text-faint)', fontWeight: '600' }}>
                    <Clock size={13} /> {log.timeAgo}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

    </div>
  );
}
