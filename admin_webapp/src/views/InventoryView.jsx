import React from 'react';
import { useApp } from '../context/AppContext';
import { StatusBadge } from '../components/StatusBadge';
import { Package, RefreshCw, AlertTriangle } from 'lucide-react';

export function InventoryView() {
  const { inventory, refillCompartment } = useApp();

  return (
    <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      <div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
          Compartment Inventory
        </h1>
        <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
          Pill capacity levels, low-stock warnings and refill management across all active dispensers.
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '16px' }}>
        {inventory.map((item) => {
          const fillPct = Math.round((item.count / item.capacity) * 100);
          return (
            <div
              key={item.id}
              style={{
                backgroundColor: '#FFFFFF',
                border: '1px solid #E6EFE9',
                borderRadius: '16px',
                padding: '20px',
                boxShadow: 'var(--shadow-card)',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'space-between',
                gap: '14px'
              }}
            >
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                  <span style={{ fontSize: '12px', fontWeight: '800', padding: '3px 8px', borderRadius: '6px', backgroundColor: '#ECFDF5', color: '#059669', fontFamily: 'monospace' }}>
                    {item.comp} • {item.deviceId}
                  </span>
                  <StatusBadge status={item.status} />
                </div>
                <div style={{ fontSize: '15px', fontWeight: '700', color: '#111827' }}>{item.med}</div>
                <div style={{ fontSize: '12px', color: '#6B7280' }}>Patient: {item.patientName}</div>

                {/* Fill bar */}
                <div style={{ marginTop: '16px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', marginBottom: '4px' }}>
                    <span style={{ color: '#6B7280' }}>Stock level</span>
                    <span style={{ fontWeight: '700', color: item.count === 0 ? '#DC2626' : '#111827' }}>
                      {item.count} / {item.capacity} pills ({fillPct}%)
                    </span>
                  </div>
                  <div style={{ height: '8px', width: '100%', backgroundColor: '#E5E7EB', borderRadius: '4px', overflow: 'hidden' }}>
                    <div
                      style={{
                        width: `${fillPct}%`,
                        height: '100%',
                        backgroundColor: fillPct === 0 ? '#EF4444' : fillPct < 40 ? '#F59E0B' : '#10B981',
                        borderRadius: '4px'
                      }}
                    />
                  </div>
                </div>
              </div>

              <div style={{ borderTop: '1px solid #F0F5F2', paddingTop: '12px', display: 'flex', justifyContent: 'flex-end' }}>
                <button
                  onClick={() => refillCompartment(item.id, item.capacity)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '5px',
                    padding: '7px 12px',
                    borderRadius: '8px',
                    border: '1px solid #A7F3D0',
                    backgroundColor: '#ECFDF5',
                    color: '#059669',
                    fontSize: '12.5px',
                    fontWeight: '600',
                    cursor: 'pointer'
                  }}
                >
                  <RefreshCw size={13} /> Mark Refilled (30)
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
