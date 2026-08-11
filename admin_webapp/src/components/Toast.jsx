import React from 'react';
import { useApp } from '../context/AppContext';
import { CheckCircle2, AlertCircle, Info, X } from 'lucide-react';

export function Toast() {
  const { toast } = useApp();
  if (!toast) return null;

  const isSuccess = toast.type === 'success';
  const isError = toast.type === 'error';

  return (
    <div
      style={{
        position: 'fixed',
        bottom: '24px',
        right: '24px',
        backgroundColor: '#FFFFFF',
        border: `1px solid ${isSuccess ? '#A7F3D0' : isError ? '#FECACA' : '#E5E7EB'}`,
        borderRadius: '12px',
        padding: '12px 18px',
        display: 'flex',
        alignItems: 'center',
        gap: '10px',
        boxShadow: '0 10px 30px rgba(0, 0, 0, 0.08), 0 2px 8px rgba(0,0,0,0.04)',
        zIndex: 9999,
        maxWidth: '380px',
        animation: 'fadeIn 0.2s ease-out'
      }}
    >
      {isSuccess && <CheckCircle2 size={18} style={{ color: '#10B981', flexShrink: 0 }} />}
      {isError && <AlertCircle size={18} style={{ color: '#EF4444', flexShrink: 0 }} />}
      {!isSuccess && !isError && <Info size={18} style={{ color: '#3B82F6', flexShrink: 0 }} />}
      
      <span style={{ fontSize: '13.5px', fontWeight: '500', color: '#1F2937', flex: 1 }}>
        {toast.message}
      </span>
    </div>
  );
}
