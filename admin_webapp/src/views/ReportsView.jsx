import React from 'react';
import { useApp } from '../context/AppContext';
import { Download, BarChart3, TrendingUp, CheckCircle, AlertCircle } from 'lucide-react';

export function ReportsView() {
  const { showToast } = useApp();

  const handleExport = () => {
    showToast('Exporting 30-day compliance report (CSV)...');
    const csv = "Date,Doses Taken,Doses Missed,Adherence Rate\n2026-05-11,28,2,93.3%\n2026-05-10,30,0,100%\n2026-05-09,29,1,96.6%\n2026-05-08,27,3,90.0%";
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `smartdose_adherence_report_${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const DAYS = [
    { day: 'Mon', taken: 28, missed: 2, rate: 93 },
    { day: 'Tue', taken: 30, missed: 0, rate: 100 },
    { day: 'Wed', taken: 29, missed: 1, rate: 96 },
    { day: 'Thu', taken: 27, missed: 3, rate: 90 },
    { day: 'Fri', dayLabel: 'Fri', taken: 31, missed: 1, rate: 96 },
    { day: 'Sat', taken: 26, missed: 2, rate: 92 },
    { day: 'Sun', taken: 29, missed: 1, rate: 96 }
  ];

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
            Compliance & Adherence Reports
          </h1>
          <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
            Dispensing statistics, fleet adherence averages and historical compliance trends.
          </p>
        </div>

        <button
          onClick={handleExport}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            padding: '9px 16px',
            borderRadius: '8px',
            border: '1px solid #A7F3D0',
            backgroundColor: '#ECFDF5',
            color: '#059669',
            fontSize: '13px',
            fontWeight: '600',
            cursor: 'pointer'
          }}
        >
          <Download size={15} /> Export CSV Report
        </button>
      </div>

      {/* 7-Day Visual Trend Card */}
      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', padding: '24px', boxShadow: 'var(--shadow-card)' }}>
        <h3 style={{ fontSize: '16px', fontWeight: '700', color: '#111827', marginBottom: '20px' }}>
          7-Day Fleet Dispensing Overview
        </h3>

        <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', gap: '12px', height: '180px', paddingTop: '20px' }}>
          {DAYS.map((d) => {
            const heightPx = Math.round((d.taken / 32) * 140);
            return (
              <div key={d.day} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px' }}>
                <span style={{ fontSize: '11.5px', fontWeight: '700', color: '#059669' }}>{d.rate}%</span>
                <div style={{ width: '100%', maxWidth: '44px', height: `${heightPx}px`, backgroundColor: '#10B981', borderRadius: '8px 8px 0 0', position: 'relative' }}>
                  {d.missed > 0 && (
                    <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: `${d.missed * 12}px`, backgroundColor: '#F87171', borderRadius: '8px 8px 0 0' }} />
                  )}
                </div>
                <span style={{ fontSize: '12px', color: '#6B7280', fontWeight: '600' }}>{d.day}</span>
              </div>
            );
          })}
        </div>

        <div style={{ display: 'flex', gap: '20px', justifyContent: 'center', marginTop: '20px', borderTop: '1px solid #F3F4F6', paddingTop: '14px', fontSize: '12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span style={{ width: '10px', height: '10px', backgroundColor: '#10B981', borderRadius: '2px' }} />
            <span style={{ color: '#4B5563' }}>Doses Taken on Time</span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span style={{ width: '10px', height: '10px', backgroundColor: '#F87171', borderRadius: '2px' }} />
            <span style={{ color: '#4B5563' }}>Missed / Delayed Doses</span>
          </div>
        </div>
      </div>
    </div>
  );
}
