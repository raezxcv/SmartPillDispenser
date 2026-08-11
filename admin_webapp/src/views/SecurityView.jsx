import React from 'react';
import { ShieldCheck, Lock, Key, Users } from 'lucide-react';

export function SecurityView() {
  return (
    <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      <div>
        <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#111827', letterSpacing: '-0.02em', marginBottom: '4px' }}>
          Security & Access Controls
        </h1>
        <p style={{ fontSize: '13.5px', color: '#6B7280' }}>
          Role-based access permissions, Firestore security rules status and administrator audit logs.
        </p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '16px' }}>
        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '16px', padding: '20px', boxShadow: 'var(--shadow-card)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
            <div style={{ width: '36px', height: '36px', borderRadius: '8px', backgroundColor: '#ECFDF5', color: '#059669', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <ShieldCheck size={20} />
            </div>
            <div>
              <div style={{ fontSize: '14px', fontWeight: '700', color: '#111827' }}>Firestore Security Rules</div>
              <div style={{ fontSize: '12px', color: '#059669', fontWeight: '600' }}>Enforced (v2 Active)</div>
            </div>
          </div>
          <p style={{ fontSize: '12.5px', color: '#6B7280', lineHeight: '1.4' }}>
            Restricted role validation prevents patient cross-access and verifies token authenticity.
          </p>
        </div>

        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #E6EFE9', borderRadius: '16px', padding: '20px', boxShadow: 'var(--shadow-card)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
            <div style={{ width: '36px', height: '36px', borderRadius: '8px', backgroundColor: '#ECFDF5', color: '#059669', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Lock size={20} />
            </div>
            <div>
              <div style={{ fontSize: '14px', fontWeight: '700', color: '#111827' }}>Admin MFA Protection</div>
              <div style={{ fontSize: '12px', color: '#059669', fontWeight: '600' }}>Active</div>
            </div>
          </div>
          <p style={{ fontSize: '12.5px', color: '#6B7280', lineHeight: '1.4' }}>
            Administrative actions (user suspension, fleet restart) are strictly logged to audit trail.
          </p>
        </div>
      </div>
    </div>
  );
}
