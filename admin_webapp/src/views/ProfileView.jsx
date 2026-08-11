import React, { useState } from 'react';
import { useApp } from '../context/AppContext';
import { User, Mail, Shield, Key, Save, Check } from 'lucide-react';

export function ProfileView() {
  const { currentUser, updateAdminName, showToast } = useApp();
  const [name, setName] = useState(currentUser.name);

  const handleSave = (e) => {
    e.preventDefault();
    updateAdminName(name);
  };

  const handlePasswordReset = () => {
    showToast(`Password change instructions dispatched to ${currentUser.email}`, 'success');
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '22px', maxWidth: '640px' }}>
      <div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
          Administrator Profile
        </h1>
        <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
          Manage your administrative credentials, display identity and security settings.
        </p>
      </div>

      <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '18px', padding: '28px', boxShadow: 'var(--shadow-card)' }}>
        {/* Avatar badge */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '24px' }}>
          <div
            style={{
              width: '60px',
              height: '60px',
              borderRadius: '50%',
              backgroundColor: '#BE123C',
              color: '#FFFFFF',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '24px',
              fontWeight: '800',
              boxShadow: '0 4px 12px rgba(190, 18, 60, 0.25)'
            }}
          >
            {currentUser.initial || 'T'}
          </div>
          <div>
            <h3 style={{ fontSize: '18px', fontWeight: '800', color: '#111827' }}>{currentUser.name}</h3>
            <div style={{ fontSize: '13px', color: '#6B7280', marginTop: '2px' }}>Super Administrator • Full System Access</div>
          </div>
        </div>

        <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#4B5563', textTransform: 'uppercase', marginBottom: '6px' }}>
              Display Name
            </label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              style={{
                width: '100%',
                height: '42px',
                padding: '0 14px',
                borderRadius: '8px',
                border: '1px solid #D1D5DB',
                fontSize: '14px',
                outline: 'none',
                boxSizing: 'border-box'
              }}
            />
          </div>

          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', color: '#4B5563', textTransform: 'uppercase', marginBottom: '6px' }}>
              Email Address (Read-only)
            </label>
            <input
              type="text"
              value={currentUser.email}
              disabled
              style={{
                width: '100%',
                height: '42px',
                padding: '0 14px',
                borderRadius: '8px',
                border: '1px solid #E5E7EB',
                backgroundColor: '#F9FAFB',
                color: '#6B7280',
                fontSize: '14px',
                boxSizing: 'border-box'
              }}
            />
          </div>

          <div style={{ display: 'flex', gap: '12px', marginTop: '12px' }}>
            <button
              type="submit"
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                padding: '10px 20px',
                borderRadius: '8px',
                backgroundColor: '#10B981',
                color: '#FFFFFF',
                fontSize: '13.5px',
                fontWeight: '600',
                border: 'none',
                cursor: 'pointer',
                boxShadow: '0 2px 8px rgba(16, 185, 129, 0.3)'
              }}
            >
              <Save size={16} /> Save Changes
            </button>

            <button
              type="button"
              onClick={handlePasswordReset}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                padding: '10px 18px',
                borderRadius: '8px',
                backgroundColor: '#FFFFFF',
                color: '#374151',
                fontSize: '13.5px',
                fontWeight: '600',
                border: '1px solid #D1D5DB',
                cursor: 'pointer'
              }}
            >
              <Key size={16} /> Change Password
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
