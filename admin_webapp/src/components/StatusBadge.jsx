import React from 'react';

export function StatusBadge({ status, type = 'status' }) {
  const norm = (status || '').toLowerCase();

  let bg = '#F3F4F6';
  let text = '#4B5563';
  let dot = '#9CA3AF';
  let label = status || 'Unknown';

  if (norm === 'active' || norm === 'online' || norm === 'connected' || norm === 'operational' || norm === 'enrolled' || norm === 'good') {
    bg = '#D1FAE5';
    text = '#047857';
    dot = '#10B981';
    if (norm === 'active') label = 'Active';
    else if (norm === 'online') label = 'Online';
    else if (norm === 'connected') label = 'Connected';
    else if (norm === 'operational') label = 'Operational';
    else if (norm === 'enrolled') label = 'Enrolled';
    else if (norm === 'good') label = 'Good';
  } else if (norm === 'inactive' || norm === 'warning' || norm === 'degraded' || norm === 'partial' || norm === 'low' || norm === 'pending') {
    bg = '#FEF3C7';
    text = '#B45309';
    dot = '#F59E0B';
    if (norm === 'inactive') label = 'Inactive';
    else if (norm === 'warning') label = 'warning';
    else if (norm === 'degraded') label = 'Degraded';
    else if (norm === 'partial') label = 'Partial';
    else if (norm === 'low') label = 'Low Stock';
    else if (norm === 'pending') label = 'Pending';
  } else if (norm === 'suspended' || norm === 'critical' || norm === 'offline' || norm === 'empty' || norm === 'high_load') {
    bg = '#FEE2E2';
    text = '#B91C1C';
    dot = '#EF4444';
    if (norm === 'suspended') label = 'Suspended';
    else if (norm === 'critical') label = 'critical';
    else if (norm === 'offline') label = 'Offline';
    else if (norm === 'empty') label = 'Empty';
    else if (norm === 'high_load') label = 'Degraded';
  }

  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: '6px',
        padding: '3px 10px',
        borderRadius: '9999px',
        backgroundColor: bg,
        color: text,
        fontSize: '12px',
        fontWeight: '600',
        lineHeight: '1.3',
        letterSpacing: '0.01em',
        whiteSpace: 'nowrap'
      }}
    >
      <span
        style={{
          width: '6px',
          height: '6px',
          borderRadius: '50%',
          backgroundColor: dot
        }}
      />
      {label}
    </span>
  );
}
