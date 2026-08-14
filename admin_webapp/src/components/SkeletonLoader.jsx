import React from 'react';

export const Skeleton = ({ width = '100%', height = '20px', borderRadius = '8px', style = {} }) => {
  return (
    <div
      className="skeleton-box"
      style={{
        width,
        height,
        borderRadius,
        ...style
      }}
    />
  );
};

export const SkeletonHeader = () => (
  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '12px' }}>
    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
      <Skeleton width="220px" height="28px" borderRadius="10px" />
      <Skeleton width="340px" height="16px" borderRadius="6px" />
    </div>
    <Skeleton width="180px" height="32px" borderRadius="10px" />
  </div>
);

export const SkeletonMetricCards = ({ count = 6 }) => (
  <div
    style={{
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
      gap: '16px'
    }}
  >
    {Array.from({ length: count }).map((_, idx) => (
      <div
        key={idx}
        style={{
          backgroundColor: 'var(--bg-card)',
          border: '1px solid var(--border-light)',
          borderRadius: '20px',
          padding: '20px 22px',
          display: 'flex',
          alignItems: 'center',
          gap: '16px',
          boxShadow: 'var(--shadow-card)'
        }}
      >
        <Skeleton width="48px" height="48px" borderRadius="14px" />
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <Skeleton width="60%" height="13px" borderRadius="4px" />
          <Skeleton width="40%" height="24px" borderRadius="6px" />
        </div>
      </div>
    ))}
  </div>
);

export const SkeletonTable = ({ rows = 5, cols = 5 }) => (
  <div
    style={{
      backgroundColor: 'var(--bg-card)',
      border: '1px solid var(--border-light)',
      borderRadius: '20px',
      padding: '24px',
      boxShadow: 'var(--shadow-card)',
      display: 'flex',
      flexDirection: 'column',
      gap: '16px'
    }}
  >
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
      <Skeleton width="180px" height="20px" borderRadius="6px" />
      <Skeleton width="120px" height="36px" borderRadius="10px" />
    </div>
    <div style={{ display: 'flex', gap: '12px', padding: '12px 0', borderBottom: '1px solid var(--border-light)' }}>
      {Array.from({ length: cols }).map((_, c) => (
        <Skeleton key={c} width={`${100 / cols}%`} height="16px" borderRadius="4px" />
      ))}
    </div>
    {Array.from({ length: rows }).map((_, r) => (
      <div key={r} style={{ display: 'flex', gap: '12px', alignItems: 'center', padding: '14px 0', borderBottom: '1px solid var(--border-subtle)' }}>
        {Array.from({ length: cols }).map((_, c) => (
          <Skeleton key={c} width={`${100 / cols}%`} height="18px" borderRadius="6px" />
        ))}
      </div>
    ))}
  </div>
);

export const SkeletonDashboard = () => (
  <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '26px' }}>
    <SkeletonHeader />
    <SkeletonMetricCards count={6} />
    
    {/* Full-width Adherence Chart */}
    <div
      style={{
        backgroundColor: 'var(--bg-card)',
        border: '1px solid var(--border-light)',
        borderRadius: '20px',
        padding: '24px',
        boxShadow: 'var(--shadow-card)',
        display: 'flex',
        flexDirection: 'column',
        gap: '16px'
      }}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Skeleton width="180px" height="22px" borderRadius="6px" />
        <Skeleton width="120px" height="28px" borderRadius="8px" />
      </div>
      <Skeleton width="100%" height="160px" borderRadius="12px" />
    </div>

    {/* 2x2 System Health */}
    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
      <Skeleton width="150px" height="20px" borderRadius="6px" />
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '14px' }}>
        {Array.from({ length: 4 }).map((_, i) => (
          <div
            key={i}
            style={{
              backgroundColor: 'var(--bg-card)',
              border: '1px solid var(--border-light)',
              borderRadius: '16px',
              padding: '18px 20px',
              display: 'flex',
              flexDirection: 'column',
              gap: '12px',
              boxShadow: 'var(--shadow-card)'
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <Skeleton width="36px" height="36px" borderRadius="10px" />
              <Skeleton width="60px" height="20px" borderRadius="10px" />
            </div>
            <Skeleton width="120px" height="16px" borderRadius="4px" />
            <Skeleton width="80px" height="12px" borderRadius="4px" />
          </div>
        ))}
      </div>
    </div>
  </div>
);

export const SkeletonGenericPage = ({ title = 'Loading...' }) => (
  <div className="animate-fade-in content-container" style={{ display: 'flex', flexDirection: 'column', gap: '26px' }}>
    <SkeletonHeader />
    <SkeletonTable rows={6} cols={5} />
  </div>
);
