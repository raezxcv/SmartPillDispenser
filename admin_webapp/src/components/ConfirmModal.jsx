import React from 'react';
import { createPortal } from 'react-dom';
import { AlertTriangle, CheckCircle2 } from 'lucide-react';
import { useApp } from '../context/AppContext';

export function ConfirmModal({ isOpen, onClose, onConfirm, title, message, confirmText = 'Confirm', isDanger = true }) {
  const { darkMode } = useApp() || {};
  if (!isOpen) return null;

  return createPortal(
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-dialog"
        style={{ maxWidth: '440px' }}
        onClick={(e) => e.stopPropagation()}
      >
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: '14px', marginBottom: '16px' }}>
          <div
            style={{
              width: '42px',
              height: '42px',
              borderRadius: '12px',
              backgroundColor: isDanger 
                ? (darkMode ? 'rgba(239, 68, 68, 0.2)' : '#FEE2E2') 
                : (darkMode ? 'rgba(16, 185, 129, 0.2)' : '#D1FAE5'),
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: isDanger ? '#EF4444' : (darkMode ? '#34D399' : '#059669'),
              flexShrink: 0
            }}
          >
            {isDanger ? <AlertTriangle size={22} strokeWidth={2.4} /> : <CheckCircle2 size={22} strokeWidth={2.4} />}
          </div>
          <div>
            <h3 style={{ fontSize: '17px', fontWeight: '800', color: 'var(--text-main)', marginBottom: '4px', letterSpacing: '-0.01em' }}>
              {title}
            </h3>
            <p style={{ fontSize: '13.5px', color: 'var(--text-subtle)', lineHeight: '1.5', margin: 0 }}>
              {message}
            </p>
          </div>
        </div>

        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '24px' }}>
          <button
            onClick={onClose}
            style={{
              height: '40px',
              padding: '0 18px',
              borderRadius: '10px',
              border: '1px solid var(--border-input)',
              backgroundColor: 'transparent',
              color: 'var(--text-muted)',
              fontSize: '13.5px',
              fontWeight: '600',
              cursor: 'pointer'
            }}
          >
            Cancel
          </button>
          <button
            onClick={() => { onConfirm(); onClose(); }}
            style={{
              height: '40px',
              padding: '0 20px',
              borderRadius: '10px',
              border: 'none',
              backgroundColor: isDanger ? '#EF4444' : '#10B981',
              color: '#FFFFFF',
              fontSize: '13.5px',
              fontWeight: '700',
              cursor: 'pointer',
              boxShadow: isDanger ? '0 4px 12px rgba(239, 68, 68, 0.3)' : '0 4px 12px rgba(16, 185, 129, 0.3)'
            }}
          >
            {confirmText}
          </button>
        </div>
      </div>
    </div>,
    document.body
  );
}
