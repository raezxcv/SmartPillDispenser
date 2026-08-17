import React from 'react';
import { AppProvider, useApp } from './context/AppContext';
import { Sidebar } from './components/Sidebar';
import { Topbar } from './components/Topbar';
import { Toast } from './components/Toast';
import { LoginView } from './views/LoginView';

import { DashboardView } from './views/DashboardView';
import { UsersView } from './views/UsersView';
import { AlertsView } from './views/AlertsView';

import { MedicationView } from './views/MedicationView';
import { InventoryView } from './views/InventoryView';
import { CaregiversView } from './views/CaregiversView';

import { LiveFeedView } from './views/LiveFeedView';
import { ActivityLogsView } from './views/ActivityLogsView';
import { ReportsView } from './views/ReportsView';
import { SettingsView } from './views/SettingsView';

function MainLayout() {
  const { activeTab, isAuthenticated, mobileSidebarOpen, setMobileSidebarOpen } = useApp();

  if (!isAuthenticated) {
    return <LoginView />;
  }

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <DashboardView />;
      case 'users':
        return <UsersView />;
      case 'alerts':
        return <AlertsView />;
      case 'medication':
        return <MedicationView />;
      case 'inventory':
        return <InventoryView />;
      case 'caregivers':
        return <CaregiversView />;
      case 'live_feed':
        return <LiveFeedView />;
      case 'activity_logs':
        return <ActivityLogsView />;
      case 'reports':
        return <ReportsView />;
      case 'settings':
        return <SettingsView />;
      default:
        return <DashboardView />;
    }
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: 'var(--bg-app)', color: 'var(--text-main)', transition: 'background-color 0.25s ease' }}>
      {/* Mobile Backdrop Overlay */}
      <div
        className={`sidebar-backdrop ${mobileSidebarOpen ? 'active' : ''}`}
        onClick={() => setMobileSidebarOpen(false)}
        aria-hidden="true"
      />

      {/* Sidebar with official app logo */}
      <Sidebar />

      {/* Main Panel */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
        <Topbar />
        
        <main
          style={{
            flex: 1,
            padding: 'clamp(14px, 3vw, 36px) clamp(12px, 3.5vw, 36px) 60px',
            overflowY: 'auto',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            width: '100%',
            boxSizing: 'border-box'
          }}
        >
          <div style={{ width: '100%', maxWidth: '980px' }}>
            {renderContent()}
          </div>
        </main>
      </div>

      {/* Toast Notification Container */}
      <Toast />
    </div>
  );
}

export default function App() {
  return (
    <AppProvider>
      <MainLayout />
    </AppProvider>
  );
}
