import React from 'react';
import { StatusBadge } from './StatusBadge';
import { X, User, Phone, Mail, Smartphone, Shield, Calendar, Key, AlertCircle } from 'lucide-react';

export function UserDetailModal({ user, onClose, onStatusChange, onResetPassword }) {
  if (!user) return null;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.45)',
        backdropFilter: 'blur(3px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 9000,
        padding: '20px'
      }}
      onClick={onClose}
    >
      <div
        style={{
          backgroundColor: '#FFFFFF',
          borderRadius: '18px',
          padding: '28px',
          maxWidth: '520px',
          width: '100%',
          boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.15)',
          border: '1px solid #E5E7EB',
          maxHeight: '90vh',
          overflowY: 'auto'
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
            <div
              style={{
                width: '46px',
                height: '46px',
                borderRadius: '12px',
                backgroundColor: '#ECFDF5',
                color: '#059669',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '18px',
                fontWeight: '700'
              }}
            >
              {(user.name || 'U').charAt(0).toUpperCase()}
            </div>
            <div>
              <h2 style={{ fontSize: '18px', fontWeight: '800', color: '#111827', margin: 0 }}>
                {user.name}
              </h2>
              <div style={{ fontSize: '12.5px', color: '#6B7280', marginTop: '2px' }}>
                {user.role === 'patient' ? 'Patient Profile' : user.role === 'caregiver' ? 'Caregiver Account' : 'Administrator'}
              </div>
            </div>
          </div>
          <button
            onClick={onClose}
            style={{
              background: 'none',
              border: 'none',
              color: '#9CA3AF',
              cursor: 'pointer',
              padding: '6px',
              borderRadius: '8px'
            }}
          >
            <X size={20} />
          </button>
        </div>

        {/* Info Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px', marginBottom: '24px' }}>
          <div style={{ padding: '12px', backgroundColor: '#F9FBFA', borderRadius: '10px', border: '1px solid #EEF3F0' }}>
            <div style={{ fontSize: '11px', fontWeight: '700', color: '#9CA3AF', textTransform: 'uppercase', marginBottom: '4px' }}>Status</div>
            <StatusBadge status={user.status || 'active'} />
          </div>

          <div style={{ padding: '12px', backgroundColor: '#F9FBFA', borderRadius: '10px', border: '1px solid #EEF3F0' }}>
            <div style={{ fontSize: '11px', fontWeight: '700', color: '#9CA3AF', textTransform: 'uppercase', marginBottom: '4px' }}>Dispenser ID</div>
            <div style={{ fontSize: '13.5px', fontWeight: '600', color: '#111827', fontFamily: 'monospace' }}>
              {user.deviceId || 'Unassigned'}
            </div>
          </div>

          <div style={{ padding: '12px', backgroundColor: '#F9FBFA', borderRadius: '10px', border: '1px solid #EEF3F0' }}>
            <div style={{ fontSize: '11px', fontWeight: '700', color: '#9CA3AF', textTransform: 'uppercase', marginBottom: '4px' }}>Email Address</div>
            <div style={{ fontSize: '13px', color: '#374151', wordBreak: 'break-all' }}>{user.email || '—'}</div>
          </div>

          <div style={{ padding: '12px', backgroundColor: '#F9FBFA', borderRadius: '10px', border: '1px solid #EEF3F0' }}>
            <div style={{ fontSize: '11px', fontWeight: '700', color: '#9CA3AF', textTransform: 'uppercase', marginBottom: '4px' }}>Phone Number</div>
            <div style={{ fontSize: '13px', color: '#374151' }}>{user.phone || '—'}</div>
          </div>

          <div style={{ padding: '12px', backgroundColor: '#F9FBFA', borderRadius: '10px', border: '1px solid #EEF3F0' }}>
            <div style={{ fontSize: '11px', fontWeight: '700', color: '#9CA3AF', textTransform: 'uppercase', marginBottom: '4px' }}>7-Day Adherence</div>
            <div style={{ fontSize: '16px', fontWeight: '800', color: (user.adherencePercent || 0) >= 80 ? '#059669' : '#D97706' }}>
              {user.adherencePercent != null ? `${user.adherencePercent}%` : 'N/A'}
            </div>
          </div>

          <div style={{ padding: '12px', backgroundColor: '#F9FBFA', borderRadius: '10px', border: '1px solid #EEF3F0' }}>
            <div style={{ fontSize: '11px', fontWeight: '700', color: '#9CA3AF', textTransform: 'uppercase', marginBottom: '4px' }}>Active Schedules</div>
            <div style={{ fontSize: '16px', fontWeight: '800', color: '#111827' }}>
              {user.schedulesCount != null ? `${user.schedulesCount} schedules` : '—'}
            </div>
          </div>
        </div>

        {/* Emergency contact info if present */}
        {user.emergencyContact && (
          <div style={{ padding: '12px', backgroundColor: '#FEF3C7', borderRadius: '10px', marginBottom: '24px', display: 'flex', alignItems: 'center', gap: '10px' }}>
            <AlertCircle size={18} style={{ color: '#B45309', flexShrink: 0 }} />
            <div style={{ fontSize: '12.5px', color: '#92400E' }}>
              <strong>Emergency contact:</strong> {user.emergencyContact}
            </div>
          </div>
        )}

        {/* Actions */}
        <div style={{ display: 'flex', gap: '10px', justifyContent: 'flex-end', borderTop: '1px solid #F3F4F6', paddingTop: '18px' }}>
          <button
            onClick={() => onResetPassword(user.email)}
            style={{
              padding: '9px 14px',
              borderRadius: '8px',
              border: '1px solid #E5E7EB',
              backgroundColor: '#FFFFFF',
              color: '#4B5563',
              fontSize: '13px',
              fontWeight: '600',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '6px'
            }}
          >
            <Key size={15} />
            Reset Password
          </button>

          {user.status === 'suspended' ? (
            <button
              onClick={() => { onStatusChange(user.id, 'active'); onClose(); }}
              style={{
                padding: '9px 16px',
                borderRadius: '8px',
                border: 'none',
                backgroundColor: '#10B981',
                color: '#FFFFFF',
                fontSize: '13px',
                fontWeight: '600',
                cursor: 'pointer'
              }}
            >
              Reinstate User
            </button>
          ) : (
            <button
              onClick={() => { onStatusChange(user.id, 'suspended'); onClose(); }}
              style={{
                padding: '9px 16px',
                borderRadius: '8px',
                border: 'none',
                backgroundColor: '#EF4444',
                color: '#FFFFFF',
                fontSize: '13px',
                fontWeight: '600',
                cursor: 'pointer'
              }}
            >
              Suspend User
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
