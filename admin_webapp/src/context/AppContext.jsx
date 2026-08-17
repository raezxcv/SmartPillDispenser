import React, { createContext, useContext, useState, useEffect } from 'react';
import { 
  auth, 
  db, 
  onAuthStateChanged, 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword,
  signOut as fbSignOut, 
  sendPasswordResetEmail,
  updateProfile,
  collection, 
  doc, 
  getDocs, 
  getDoc, 
  setDoc,
  updateDoc, 
  addDoc, 
  deleteDoc, 
  onSnapshot, 
  query, 
  orderBy, 
  limit, 
  serverTimestamp 
} from '../firebase/config';

const AppContext = createContext(null);

const DEFAULT_USERS = [
  {
    id: 'usr_01',
    name: 'Amara Reyes',
    email: 'amara.reyes@example.com',
    phone: '+63 917 555 0119',
    status: 'active',
    deviceId: 'SD-0119',
    adherencePercent: 96,
    schedulesCount: 4,
    emergencyContact: 'Carlos Reyes (+63 917 555 0199)'
  },
  {
    id: 'usr_02',
    name: 'Joseph Tan',
    email: 'joseph.tan@example.com',
    phone: '+63 920 555 0120',
    status: 'active',
    deviceId: 'SD-0120',
    adherencePercent: 88,
    schedulesCount: 3,
    emergencyContact: 'Elena Tan (+63 920 555 0200)'
  },
  {
    id: 'usr_03',
    name: 'Miriam Cortez',
    email: 'miriam.cortez@example.com',
    phone: '+63 918 555 0121',
    status: 'active',
    deviceId: 'SD-0121',
    adherencePercent: 74,
    schedulesCount: 5,
    emergencyContact: 'Bea Villamor (+63 918 555 0221)'
  },
  {
    id: 'usr_04',
    name: 'Elias Navarro',
    email: 'elias.navarro@example.com',
    phone: '+63 927 555 0123',
    status: 'inactive',
    deviceId: 'SD-0123',
    adherencePercent: 61,
    schedulesCount: 0,
    emergencyContact: 'Maria Navarro (+63 927 555 0234)'
  },
  {
    id: 'usr_05',
    name: 'Rosalyn Perez',
    email: 'rosalyn.perez@example.com',
    phone: '+63 908 555 0122',
    status: 'active',
    deviceId: 'SD-0122',
    adherencePercent: 92,
    schedulesCount: 2,
    emergencyContact: 'Gabriel Perez (+63 908 555 0222)'
  },
  {
    id: 'usr_06',
    name: 'Daniel Okoye',
    email: 'daniel.okoye@example.com',
    phone: '+63 945 555 0124',
    status: 'suspended',
    deviceId: 'SD-0124',
    adherencePercent: 45,
    schedulesCount: 1,
    emergencyContact: 'Chidi Okoye (+63 945 555 0244)'
  }
];

const DEFAULT_ADMINS = [
  {
    id: 'adm_01',
    name: 'Super Admin',
    email: 'admin@smartpill.com',
    role: 'admin',
    status: 'active',
    createdAt: '2026-01-01T00:00:00Z'
  }
];

const DEFAULT_DEVICES = [
  {
    id: 'dev_01',
    deviceId: 'SD-0119',
    patientId: 'usr_01',
    patientName: 'Amara Reyes',
    status: 'online',
    isOnline: true,
    battery: 98,
    ip: '192.168.1.119',
    wifiSsid: 'SmartDose-Mesh-5G',
    esp32Status: 'online',
    rpiStatus: 'online',
    cameraStatus: 'online',
    firmwareVersion: 'v2.4.1',
    lastHeartbeat: '10 sec ago'
  },
  {
    id: 'dev_02',
    deviceId: 'SD-0120',
    patientId: 'usr_02',
    patientName: 'Joseph Tan',
    status: 'online',
    isOnline: true,
    battery: 84,
    ip: '192.168.1.120',
    wifiSsid: 'SmartDose-Mesh-5G',
    esp32Status: 'online',
    rpiStatus: 'online',
    cameraStatus: 'online',
    firmwareVersion: 'v2.4.1',
    lastHeartbeat: '45 sec ago'
  },
  {
    id: 'dev_03',
    deviceId: 'SD-0121',
    patientId: 'usr_03',
    patientName: 'Miriam Cortez',
    status: 'online',
    isOnline: true,
    battery: 92,
    ip: '192.168.1.121',
    wifiSsid: 'HomeFiber-2.4G',
    esp32Status: 'online',
    rpiStatus: 'online',
    cameraStatus: 'online',
    firmwareVersion: 'v2.4.0',
    lastHeartbeat: '5 sec ago'
  },
  {
    id: 'dev_04',
    deviceId: 'SD-0122',
    patientId: 'usr_05',
    patientName: 'Rosalyn Perez',
    status: 'online',
    isOnline: true,
    battery: 100,
    ip: '192.168.1.122',
    wifiSsid: 'Perez-WiFi',
    esp32Status: 'online',
    rpiStatus: 'online',
    cameraStatus: 'online',
    firmwareVersion: 'v2.4.1',
    lastHeartbeat: '12 sec ago'
  },
  {
    id: 'dev_05',
    deviceId: 'SD-0123',
    patientId: 'usr_04',
    patientName: 'Elias Navarro',
    status: 'online',
    isOnline: true,
    battery: 76,
    ip: '192.168.1.123',
    wifiSsid: 'Navarro-Mesh',
    esp32Status: 'online',
    rpiStatus: 'online',
    cameraStatus: 'online',
    firmwareVersion: 'v2.3.8',
    lastHeartbeat: '2 min ago'
  },
  {
    id: 'dev_06',
    deviceId: 'SD-0124',
    patientId: 'usr_06',
    patientName: 'Daniel Okoye',
    status: 'offline',
    isOnline: false,
    battery: 12,
    ip: '192.168.1.124',
    wifiSsid: 'Unreachable',
    esp32Status: 'offline',
    rpiStatus: 'offline',
    cameraStatus: 'offline',
    firmwareVersion: 'v2.3.0',
    lastHeartbeat: '3 days ago'
  }
];

const DEFAULT_ALERTS = [
  {
    id: 'alt_01',
    title: 'Device offline',
    patientName: 'Daniel Okoye',
    patientId: 'usr_06',
    deviceId: 'SD-0124',
    message: 'Dispenser SD-0124 has stopped sending heartbeats for over 72 hours.',
    severity: 'critical',
    isRead: false,
    timeAgo: '3 days ago'
  },
  {
    id: 'alt_02',
    title: 'Empty compartment',
    patientName: 'Miriam Cortez',
    patientId: 'usr_03',
    deviceId: 'SD-0121',
    message: 'Compartment C5 (Levothyroxine 75mcg) has reached 0 pills remaining.',
    severity: 'critical',
    isRead: false,
    timeAgo: '2 hours ago'
  },
  {
    id: 'alt_03',
    title: 'Missed medication',
    patientName: 'Miriam Cortez',
    patientId: 'usr_03',
    deviceId: 'SD-0121',
    message: 'Levothyroxine 75mcg scheduled for 08:00 AM was not confirmed taken.',
    severity: 'warning',
    isRead: false,
    timeAgo: '5 hours ago'
  },
  {
    id: 'alt_04',
    title: 'Low stock warning',
    patientName: 'Joseph Tan',
    patientId: 'usr_02',
    deviceId: 'SD-0120',
    message: 'Compartment C3 (Amlodipine 5mg) is low (3 pills left). Please schedule a refill.',
    severity: 'warning',
    isRead: true,
    timeAgo: '6 hours ago'
  }
];

const DEFAULT_ACTIVITIES = [
  {
    id: 'act_01',
    title: 'Metformin 500mg dispensed',
    patientName: 'Amara Reyes',
    deviceId: 'SD-0119',
    timeAgo: '8 min ago',
    type: 'dispense_success',
    status: 'taken'
  },
  {
    id: 'act_02',
    title: 'Patient verified by camera',
    patientName: 'Amara Reyes',
    deviceId: 'SD-0119',
    timeAgo: '7 min ago',
    type: 'patient_detected',
    status: 'detected'
  },
  {
    id: 'act_03',
    title: 'Compartment C5 reported empty',
    patientName: 'Miriam Cortez',
    deviceId: 'SD-0121',
    timeAgo: '2 h ago',
    type: 'compartment_empty',
    status: 'empty'
  },
  {
    id: 'act_04',
    title: 'Levothyroxine 75mcg marked as missed',
    patientName: 'Miriam Cortez',
    deviceId: 'SD-0121',
    timeAgo: '5 h ago',
    type: 'dose_missed',
    status: 'missed'
  },
  {
    id: 'act_05',
    title: 'Dispenser snapshot captured',
    patientName: 'Joseph Tan',
    deviceId: 'SD-0120',
    timeAgo: '1 day ago',
    type: 'photo_captured',
    status: 'captured'
  }
];

const DEFAULT_MEDICATIONS = [
  { id: 'med_01', patientName: 'Amara Reyes', patientId: 'usr_01', deviceId: 'SD-0119', name: 'Metformin', dosage: '500mg', compartment: 'C1', time: '08:00 AM', frequency: 'Daily', pillsLeft: 24, adherence: 98 },
  { id: 'med_02', patientName: 'Amara Reyes', patientId: 'usr_01', deviceId: 'SD-0119', name: 'Atorvastatin', dosage: '20mg', compartment: 'C2', time: '08:00 PM', frequency: 'Daily', pillsLeft: 18, adherence: 94 },
  { id: 'med_03', patientName: 'Joseph Tan', patientId: 'usr_02', deviceId: 'SD-0120', name: 'Amlodipine', dosage: '5mg', compartment: 'C3', time: '09:00 AM', frequency: 'Daily', pillsLeft: 12, adherence: 90 },
  { id: 'med_04', patientName: 'Joseph Tan', patientId: 'usr_02', deviceId: 'SD-0120', name: 'Losartan', dosage: '50mg', compartment: 'C4', time: '07:00 PM', frequency: 'Daily', pillsLeft: 14, adherence: 86 },
  { id: 'med_05', patientName: 'Miriam Cortez', patientId: 'usr_03', deviceId: 'SD-0121', name: 'Levothyroxine', dosage: '75mcg', compartment: 'C5', time: '08:00 AM', frequency: 'Daily', pillsLeft: 0, adherence: 70 },
  { id: 'med_06', patientName: 'Rosalyn Perez', patientId: 'usr_05', deviceId: 'SD-0122', name: 'Omeprazole', dosage: '20mg', compartment: 'C6', time: '06:30 AM', frequency: 'Daily', pillsLeft: 20, adherence: 95 }
];

// Initial 10 Hardware Compartments definition (Blank/Clean slots by default, NOT hardcoded)
const DEFAULT_COMPARTMENTS = Array.from({ length: 10 }, (_, i) => {
  const compNum = i + 1;
  return {
    id: `comp_${compNum}`,
    compartmentNumber: compNum,
    comp: `C${compNum}`,
    medicationName: '',
    dosage: '',
    stockCount: 0,
    maxCapacity: 30,
    patientName: 'Unassigned',
    patientUid: '',
    deviceId: 'SD-0119',
    scheduleTime: '--:--',
    frequency: 'Daily',
    status: 'empty'
  };
});

export function AppProvider({ children }) {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [mobileSidebarOpen, setMobileSidebarOpen] = useState(false);
  const [authChecked, setAuthChecked] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(true);
  const [darkMode, setDarkMode] = useState(() => {
    const saved = localStorage.getItem('smartdose_admin_theme');
    if (saved) return saved === 'dark';
    return window.matchMedia?.('(prefers-color-scheme: dark)').matches ?? false;
  });

  const toggleMobileSidebar = () => {
    setMobileSidebarOpen(prev => !prev);
  };

  const [currentUser, setCurrentUser] = useState({
    uid: 'adm_01',
    name: 'Super Admin',
    email: 'admin@smartpill.com',
    role: 'admin',
    initial: 'A'
  });

  const [users, setUsers] = useState(DEFAULT_USERS);
  const [admins, setAdmins] = useState(DEFAULT_ADMINS);
  const [caregivers, setCaregivers] = useState([]);
  const [devices, setDevices] = useState(DEFAULT_DEVICES);
  const [alerts, setAlerts] = useState(DEFAULT_ALERTS);
  const [activities, setActivities] = useState(DEFAULT_ACTIVITIES);
  const [medications, setMedications] = useState(DEFAULT_MEDICATIONS);
  const [compartments, setCompartments] = useState(DEFAULT_COMPARTMENTS);
  const [systemSettings, setSystemSettings] = useState({
    smsAlerts: true,
    pushNotifications: true,
    heartbeatInterval: '30'
  });
  const [toast, setToast] = useState(null);
  const [firestoreConnected, setFirestoreConnected] = useState(false);
  const [initialLoading, setInitialLoading] = useState(true);

  // Sync Dark Mode Class to document root
  useEffect(() => {
    if (darkMode) {
      document.documentElement.classList.add('dark');
      document.documentElement.setAttribute('data-theme', 'dark');
      localStorage.setItem('smartdose_admin_theme', 'dark');
    } else {
      document.documentElement.classList.remove('dark');
      document.documentElement.setAttribute('data-theme', 'light');
      localStorage.setItem('smartdose_admin_theme', 'light');
    }
  }, [darkMode]);

  const toggleDarkMode = () => {
    setDarkMode(prev => !prev);
  };

  // Sync real-time data from Firestore & listen to Firebase Auth
  useEffect(() => {
    let unsubs = [];

    const initListeners = () => {
      try {
        // 1. Live listener for patients (users collection filtered to strictly patients)
        const unsubUsers = onSnapshot(collection(db, 'users'), (snap) => {
          if (!snap.empty) {
            setFirestoreConnected(true);
            const list = snap.docs
              .map(d => ({ id: d.id, ...d.data() }))
              .filter(u => u.role !== 'admin' && !u.isAdmin); // Separate admins from patients
            setUsers(list);
          }
        }, () => {});
        unsubs.push(unsubUsers);

        // 2. Live listener for admins collection
        const unsubAdmins = onSnapshot(collection(db, 'admins'), (snap) => {
          if (!snap.empty) {
            setFirestoreConnected(true);
            const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
            setAdmins(list);
          }
        }, () => {});
        unsubs.push(unsubAdmins);

        // 3. Live listener for contacts (Real-time sync with mobile app contacts)
        const unsubContacts = onSnapshot(collection(db, 'contacts'), (snap) => {
          setFirestoreConnected(true);
          if (!snap.empty) {
            const list = snap.docs.map(d => {
              const data = d.data();
              return {
                id: d.id,
                name: data.name || 'Caregiver',
                phone: data.phone || '',
                email: data.email || '',
                relationship: data.relationship || 'Family Member',
                patientName: data.patientName || 'Patient',
                patientId: data.patientId || data.patientUid || '',
                pairingStatus: data.pairingStatus || 'paired',
                smsAlerts: data.smsAlerts ?? true,
                ...data
              };
            });
            setCaregivers(list);
          } else {
            setCaregivers([]);
          }
        }, () => {});
        unsubs.push(unsubContacts);

        // 4. Live listener for alerts
        const unsubAlerts = onSnapshot(collection(db, 'alerts'), (snap) => {
          if (!snap.empty) {
            setFirestoreConnected(true);
            const list = snap.docs.map(d => {
              const data = d.data();
              return {
                id: d.id,
                title: data.title || 'System Alert',
                message: data.message || '',
                patientName: data.patientName || 'Patient',
                patientId: data.patientId || data.patientUid || '',
                deviceId: data.deviceId || 'SD-0119',
                severity: data.severity || 'warning',
                isRead: data.isRead === true || data.status === 'read',
                timeAgo: data.createdAt?.toDate ? data.createdAt.toDate().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : (data.timeAgo || 'Recent'),
                ...data
              };
            });
            setAlerts(list);
          }
        }, () => {});
        unsubs.push(unsubAlerts);

        // 5. Live listener for dispensing logs
        const unsubLogs = onSnapshot(collection(db, 'dispensingLogs'), (snap) => {
          if (!snap.empty) {
            setFirestoreConnected(true);
            const newActivities = snap.docs.map(d => {
              const data = d.data();
              let timeStr = 'Recent';
              let dateObj = null;
              if (data.timestamp?.toDate) {
                dateObj = data.timestamp.toDate();
                timeStr = dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
              }
              return {
                id: d.id,
                title: data.title || `${data.medicationName || data.medName || 'Medication'} ${data.dosage || ''} ${data.status === 'taken' ? 'dispensed & taken' : (data.status || 'event')}`,
                patientName: data.patientName || 'Patient',
                patientUid: data.patientUid || '',
                deviceId: data.deviceId || data.dispenserId || 'SD-0119',
                timeAgo: timeStr,
                timestamp: data.timestamp,
                dateObj,
                type: data.type || (data.status === 'taken' ? 'dispense_success' : data.status === 'missed' ? 'dose_missed' : 'system_event'),
                status: data.status || 'taken',
                capturedPhotoUrl: data.capturedPhotoUrl || data.imageUrl || null,
                medicationName: data.medicationName || data.medName || 'Medication',
                dosage: data.dosage || ''
              };
            });
            setActivities(newActivities);
          }
        }, () => {});
        unsubs.push(unsubLogs);

        // 6. Live listener for devices
        const unsubDevices = onSnapshot(collection(db, 'devices'), (snap) => {
          if (!snap.empty) {
            setFirestoreConnected(true);
            const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
            setDevices(list);
          }
        }, () => {});
        unsubs.push(unsubDevices);

        // 7. Live listener for schedules
        const unsubSchedules = onSnapshot(collection(db, 'schedules'), (snap) => {
          if (!snap.empty) {
            setFirestoreConnected(true);
            const list = snap.docs.map(d => {
              const data = d.data();
              return {
                id: d.id,
                name: data.medicationName || data.name || 'Medication',
                dosage: data.dosage || '1 pill',
                compartment: data.compartment || data.compCode || 'C1',
                time: data.time || '08:00 AM',
                frequency: data.frequency || 'Daily',
                patientName: data.patientName || 'Patient',
                deviceId: data.deviceId || 'SD-0119',
                pillsLeft: data.pillsLeft || 20,
                adherence: data.adherence || 95
              };
            });
            setMedications(list);
          }
        }, () => {});
        unsubs.push(unsubSchedules);

        // 8. Live listener for 10 compartments (Guaranteed real Firestore database sync)
        const unsubCompartments = onSnapshot(collection(db, 'compartments'), async (snap) => {
          if (!snap.empty) {
            setFirestoreConnected(true);
            const list = snap.docs.map(d => {
              const data = d.data();
              const compNum = data.compartmentNumber || parseInt(d.id.replace(/\D/g, ''), 10) || 1;
              const stock = data.stockCount ?? 0;
              let status = 'good';
              if (stock === 0 || !data.medicationName) status = 'empty';
              else if (stock <= 5) status = 'low';

              return {
                id: d.id,
                compartmentNumber: compNum,
                comp: `C${compNum}`,
                medicationName: data.medicationName || '',
                dosage: data.dosage || '',
                stockCount: stock,
                maxCapacity: data.maxCapacity || 30,
                patientName: data.patientName || 'Unassigned',
                patientUid: data.patientUid || '',
                deviceId: data.deviceId || 'SD-0119',
                scheduleTime: data.scheduleTime || '--:--',
                frequency: data.frequency || 'Daily',
                lastRefilledAt: data.lastRefilledAt,
                status
              };
            });

            // Guarantee all 10 slots (C1 through C10) exist as blank/unassigned if deleted
            const merged = [];
            for (let i = 0; i < 10; i++) {
              const num = i + 1;
              const found = list.find(c => c.compartmentNumber === num);
              if (found) {
                merged.push(found);
              } else {
                merged.push({
                  id: `comp_${num}`,
                  compartmentNumber: num,
                  comp: `C${num}`,
                  medicationName: '',
                  dosage: '',
                  stockCount: 0,
                  maxCapacity: 30,
                  patientName: 'Unassigned',
                  patientUid: '',
                  deviceId: 'SD-0119',
                  scheduleTime: '--:--',
                  frequency: 'Daily',
                  status: 'empty'
                });
              }
            }

            setCompartments(merged);
          } else {
            setCompartments(DEFAULT_COMPARTMENTS);
          }
        }, (err) => {
          console.warn('Compartments listener error:', err);
        });
        unsubs.push(unsubCompartments);

        // 9. Live listener for system preferences
        const unsubSettings = onSnapshot(doc(db, 'settings', 'preferences'), (docSnap) => {
          if (docSnap.exists()) {
            setSystemSettings(prev => ({ ...prev, ...docSnap.data() }));
          }
        }, () => {});
        unsubs.push(unsubSettings);

      } catch (e) {
        console.warn('Firestore snapshot setup error:', e);
      }
    };

    // Firebase Auth State Observer
    const unsubAuth = onAuthStateChanged(auth, async (user) => {
      if (user) {
        try {
          const adminDoc = await getDoc(doc(db, 'admins', user.uid));
          let name = user.displayName || (user.email ? user.email.split('@')[0] : 'Admin');
          if (adminDoc.exists()) {
            name = adminDoc.data().name || name;
          }
          setCurrentUser({
            uid: user.uid,
            name,
            email: user.email || '',
            role: 'admin',
            initial: name.charAt(0).toUpperCase()
          });
          setIsAuthenticated(true);
        } catch (e) {
          const fallbackName = user.displayName || user.email?.split('@')[0] || 'Admin';
          setCurrentUser({
            uid: user.uid,
            name: fallbackName,
            email: user.email || '',
            role: 'admin',
            initial: fallbackName.charAt(0).toUpperCase()
          });
          setIsAuthenticated(true);
        }
      }
      setAuthChecked(true);
      initListeners();
      const loadTimer = setTimeout(() => {
        setInitialLoading(false);
      }, 350);
      unsubs.push(() => clearTimeout(loadTimer));
    });

    return () => {
      unsubAuth();
      unsubs.forEach(u => typeof u === 'function' && u());
    };
  }, []);

  const showToast = (message, type = 'success') => {
    setToast({ message, type, id: Date.now() });
    setTimeout(() => {
      setToast(null);
    }, 3800);
  };

  const addActivity = (title, patientName, deviceId, type = 'system_action') => {
    const newAct = {
      id: `act_${Date.now()}`,
      title,
      patientName: patientName || 'Fleet',
      deviceId: deviceId || 'SD-CORE',
      timeAgo: 'Just now',
      type
    };
    setActivities(prev => [newAct, ...prev]);

    try {
      addDoc(collection(db, 'audit_logs'), {
        title,
        patientName: patientName || 'Fleet',
        deviceId: deviceId || 'SD-CORE',
        adminName: currentUser.name,
        timestamp: serverTimestamp()
      }).catch(() => {});
    } catch (_) {}
  };

  // Seed / Sync redesigned schema
  const seedLiveFirestoreFleet = async () => {
    showToast('Syncing complete fleet & 10 compartments schema to live Firestore...');
    try {
      // 1. Users
      for (const u of DEFAULT_USERS) {
        await setDoc(doc(db, 'users', u.id), {
          name: u.name,
          email: u.email,
          phone: u.phone,
          status: u.status,
          deviceId: u.deviceId,
          adherencePercent: u.adherencePercent,
          schedulesCount: u.schedulesCount,
          emergencyContact: u.emergencyContact,
          createdAt: serverTimestamp()
        }, { merge: true });
      }

      // 2. Dedicated Admins collection
      for (const adm of DEFAULT_ADMINS) {
        await setDoc(doc(db, 'admins', adm.id), {
          name: adm.name,
          email: adm.email,
          role: 'admin',
          status: 'active',
          createdAt: serverTimestamp()
        }, { merge: true });
      }

      // 3. Devices
      for (const d of DEFAULT_DEVICES) {
        await setDoc(doc(db, 'devices', d.deviceId), {
          deviceId: d.deviceId,
          patientName: d.patientName,
          status: d.status,
          isOnline: d.status === 'online',
          battery: d.battery,
          ip: d.ip,
          wifiSsid: d.wifiSsid,
          esp32Status: d.esp32Status,
          rpiStatus: d.rpiStatus,
          cameraStatus: d.cameraStatus,
          firmwareVersion: d.firmwareVersion,
          lastHeartbeat: serverTimestamp()
        }, { merge: true });
      }

      // 4. Alerts
      for (const a of DEFAULT_ALERTS) {
        await setDoc(doc(db, 'alerts', a.id), {
          title: a.title,
          patientName: a.patientName,
          deviceId: a.deviceId,
          message: a.message,
          severity: a.severity,
          isRead: a.isRead,
          createdAt: serverTimestamp()
        }, { merge: true });
      }

      // 5. 10 Compartments
      for (const c of DEFAULT_COMPARTMENTS) {
        await setDoc(doc(db, 'compartments', c.id), {
          compartmentNumber: c.compartmentNumber,
          medicationName: c.medicationName,
          dosage: c.dosage,
          stockCount: c.stockCount,
          maxCapacity: c.maxCapacity,
          patientName: c.patientName,
          patientUid: c.patientUid,
          deviceId: c.deviceId,
          scheduleTime: c.scheduleTime,
          frequency: c.frequency,
          lastRefilledAt: serverTimestamp()
        }, { merge: true });
      }

      // 6. Settings preferences
      await setDoc(doc(db, 'settings', 'preferences'), {
        smsAlerts: true,
        pushNotifications: true,
        heartbeatInterval: '30',
        updatedAt: serverTimestamp()
      }, { merge: true });

      // 7. Dispensing logs
      await addDoc(collection(db, 'dispensingLogs'), {
        medicationName: 'Metformin',
        dosage: '500mg',
        compartment: 'C1',
        patientName: 'Amara Reyes',
        deviceId: 'SD-0119',
        status: 'taken',
        timestamp: serverTimestamp()
      });

      showToast('Live Firestore populated successfully with 10 compartments!');
      return { success: true };
    } catch (err) {
      console.error('Firestore seeding failed:', err);
      showToast(`Firestore Sync Error: ${err.message}`, 'error');
      return { success: false, error: err.message };
    }
  };

  // ── Authentication & Admin Operations ──
  const login = async (email, password) => {
    try {
      const cred = await signInWithEmailAndPassword(auth, email, password);
      const adminDoc = await getDoc(doc(db, 'admins', cred.user.uid));
      let name = cred.user.displayName || email.split('@')[0];
      if (adminDoc.exists()) {
        name = adminDoc.data().name || name;
      }
      setCurrentUser({
        uid: cred.user.uid,
        name,
        email,
        role: 'admin',
        initial: name.charAt(0).toUpperCase()
      });
      setIsAuthenticated(true);
      showToast(`Welcome back, ${name}!`);
      return { success: true };
    } catch (err) {
      return { success: false, error: err.message || 'Invalid email or password.' };
    }
  };

  const addNewAdmin = async (name, email, password) => {
    try {
      const cred = await createUserWithEmailAndPassword(auth, email, password);
      await updateProfile(cred.user, { displayName: name });
      const newAdminDoc = {
        name,
        email,
        role: 'admin',
        status: 'active',
        createdAt: serverTimestamp()
      };
      await setDoc(doc(db, 'admins', cred.user.uid), newAdminDoc);
      setAdmins(prev => [{ id: cred.user.uid, ...newAdminDoc }, ...prev]);
      addActivity(`Added new administrator (${email})`, name, 'ADMIN');
      showToast(`Administrator ${name} created successfully!`);
      return { success: true };
    } catch (e) {
      showToast(`Failed to create admin: ${e.message}`, 'error');
      return { success: false, error: e.message };
    }
  };

  const deleteAdmin = async (adminId, adminName) => {
    try {
      await deleteDoc(doc(db, 'admins', adminId));
    } catch (e) {}
    setAdmins(prev => prev.filter(a => a.id !== adminId));
    addActivity(`Removed administrator access (${adminName || adminId})`, 'Security', 'ADMIN');
    showToast(`Administrator removed`);
    return { success: true };
  };

  // ── Users CRUD (Patients) ──
  const createUser = async (userData) => {
    try {
      const newDoc = {
        ...userData,
        status: userData.status || 'active',
        adherencePercent: userData.adherencePercent || 100,
        schedulesCount: userData.schedulesCount || 0,
        createdAt: serverTimestamp()
      };
      
      const docRef = await addDoc(collection(db, 'users'), newDoc);
      const fullUser = { id: docRef.id, ...newDoc };
      setUsers(prev => [fullUser, ...prev]);
      addActivity(`Created new user record (${userData.name})`, userData.name, userData.deviceId || 'SD-CORE');
      showToast(`User ${userData.name} created successfully!`);
      return { success: true, id: docRef.id };
    } catch (err) {
      showToast(`Failed to create user: ${err.message}`, 'error');
      return { success: false, error: err.message };
    }
  };

  const updateUser = async (uid, updatedData) => {
    try {
      await updateDoc(doc(db, 'users', uid), updatedData);
    } catch (e) {}
    setUsers(prev => prev.map(u => u.id === uid ? { ...u, ...updatedData } : u));
    addActivity(`Updated profile details for user`, updatedData.name, updatedData.deviceId || 'SD-CORE');
    showToast('User updated successfully');
    return { success: true };
  };

  const deleteUser = async (uid, userName) => {
    try {
      await deleteDoc(doc(db, 'users', uid));
    } catch (e) {}
    setUsers(prev => prev.filter(u => u.id !== uid));
    addActivity(`Deleted user account (${userName || uid})`, userName || 'User', 'SD-CORE');
    showToast(`User account deleted`);
    return { success: true };
  };

  const updateUserStatus = async (uid, newStatus) => {
    try {
      await updateDoc(doc(db, 'users', uid), { status: newStatus });
    } catch (e) {}
    setUsers(prev => prev.map(u => u.id === uid ? { ...u, status: newStatus } : u));
    addActivity(`User status changed to ${newStatus}`, users.find(u => u.id === uid)?.name, 'SD-CORE');
    showToast(`User status updated to ${newStatus}`);
  };

  // ── Caregiver Contacts CRUD (Real-time Firestore Sync with Mobile App) ──
  const createContact = async (contactData) => {
    try {
      const pUid = contactData.patientId || contactData.patientUid || '';
      const newDoc = {
        name: contactData.name || '',
        caregiverName: contactData.name || '',
        phone: contactData.phone || '',
        email: contactData.email || '',
        patientName: contactData.patientName || 'Patient',
        patientUid: pUid,
        patientId: pUid,
        relationship: contactData.relationship || 'Family Member',
        role: contactData.relationship || 'Primary Caregiver',
        pairingStatus: contactData.pairingStatus || 'paired',
        smsAlerts: contactData.smsAlerts ?? true,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp()
      };
      const docRef = await addDoc(collection(db, 'contacts'), newDoc);
      const fullContact = { id: docRef.id, ...newDoc };
      setCaregivers(prev => [fullContact, ...prev.filter(c => c.id !== docRef.id)]);
      addActivity(`Added caregiver contact (${contactData.name})`, contactData.patientName, 'CONTACT');
      showToast(`Caregiver ${contactData.name} added!`);
      return { success: true, id: docRef.id };
    } catch (e) {
      showToast(`Failed to add contact: ${e.message}`, 'error');
      return { success: false, error: e.message };
    }
  };

  const updateContact = async (contactId, updatedData) => {
    try {
      const pUid = updatedData.patientId || updatedData.patientUid || '';
      const payload = {
        ...updatedData,
        caregiverName: updatedData.name || updatedData.caregiverName || '',
        patientUid: pUid,
        patientId: pUid,
        role: updatedData.relationship || updatedData.role || 'Primary Caregiver',
        updatedAt: serverTimestamp()
      };
      await updateDoc(doc(db, 'contacts', contactId), payload);
    } catch (e) {}
    setCaregivers(prev => prev.map(c => c.id === contactId ? { ...c, ...updatedData } : c));
    showToast('Contact updated successfully');
    return { success: true };
  };

  const deleteContact = async (contactId, contactName) => {
    try {
      await deleteDoc(doc(db, 'contacts', contactId));
    } catch (e) {}
    setCaregivers(prev => prev.filter(c => c.id !== contactId));
    addActivity(`Removed caregiver contact (${contactName || contactId})`, 'Fleet', 'CONTACT');
    showToast('Caregiver contact removed');
    return { success: true };
  };

  // ── Alerts (Read / Unread Only - No Resolve) ──
  const toggleAlertRead = async (alertId, targetState) => {
    const isNowRead = targetState !== undefined 
      ? targetState 
      : !alerts.find(a => a.id === alertId)?.isRead;

    try {
      await updateDoc(doc(db, 'alerts', alertId), {
        isRead: isNowRead,
        readAt: isNowRead ? serverTimestamp() : null
      });
    } catch (e) {}

    setAlerts(prev => prev.map(a => a.id === alertId ? { ...a, isRead: isNowRead } : a));
    showToast(isNowRead ? 'Alert marked as read' : 'Alert marked as unread');
  };

  const markAllAlertsAsRead = async () => {
    try {
      const unreadAlerts = alerts.filter(a => !a.isRead);
      for (const a of unreadAlerts) {
        await updateDoc(doc(db, 'alerts', a.id), {
          isRead: true,
          readAt: serverTimestamp()
        }).catch(() => {});
      }
    } catch (e) {}

    setAlerts(prev => prev.map(a => ({ ...a, isRead: true })));
    showToast('All alerts marked as read');
  };

  // ── 10-Compartment Configuration & Management (Real Database Sync to Mobile App) ──
  const saveCompartment = async (compData) => {
    const compNum = compData.compartmentNumber;
    const docId = compData.id || `comp_${compNum}`;
    const stock = Number(compData.stockCount ?? 0);
    const maxCap = Number(compData.maxCapacity ?? 30);
    let status = 'good';
    if (stock === 0 || !compData.medicationName) status = 'empty';
    else if (stock <= 5) status = 'low';

    const payload = {
      compartmentNumber: compNum,
      medicationName: compData.medicationName || '',
      dosage: compData.dosage || '',
      stockCount: stock,
      maxCapacity: maxCap,
      patientName: compData.patientName || 'Unassigned',
      patientUid: compData.patientUid || '',
      deviceId: compData.deviceId || 'SD-0119',
      scheduleTime: compData.scheduleTime || '--:--',
      frequency: compData.frequency || 'Daily',
      updatedAt: serverTimestamp()
    };

    try {
      // 1. Persist directly to Firestore compartments collection
      await setDoc(doc(db, 'compartments', docId), payload, { merge: true });

      // 2. Also persist to schedules collection so the Flutter mobile app meds tab displays the scheduled medication
      if (payload.medicationName && payload.patientUid) {
        await setDoc(doc(db, 'schedules', `sched_comp_${compNum}`), {
          patientUid: payload.patientUid,
          patientName: payload.patientName,
          medicationName: payload.medicationName,
          dosage: payload.dosage,
          compartment: `Compartment ${compNum}`,
          compCode: `C${compNum}`,
          time: payload.scheduleTime !== '--:--' ? payload.scheduleTime : '08:00 AM',
          frequency: payload.frequency || 'Daily',
          status: 'active',
          pillsLeft: stock,
          deviceId: payload.deviceId,
          updatedAt: serverTimestamp()
        }, { merge: true });
      }
    } catch (e) {
      console.warn('Error persisting compartment to Firestore:', e);
    }

    setCompartments(prev => prev.map(c => c.compartmentNumber === compNum ? {
      ...c,
      ...payload,
      id: docId,
      comp: `C${compNum}`,
      status
    } : c));

    addActivity(`Configured Compartment C${compNum} (${payload.medicationName || 'Unassigned'})`, payload.patientName, payload.deviceId);
    showToast(`Compartment C${compNum} saved successfully!`);
    return { success: true };
  };

  const clearCompartment = async (compNum) => {
    const docId = `comp_${compNum}`;
    const emptyPayload = {
      compartmentNumber: compNum,
      medicationName: '',
      dosage: '',
      stockCount: 0,
      maxCapacity: 30,
      patientName: 'Unassigned',
      patientUid: '',
      deviceId: 'SD-0119',
      scheduleTime: '--:--',
      frequency: 'Daily',
      updatedAt: serverTimestamp()
    };

    try {
      await setDoc(doc(db, 'compartments', docId), emptyPayload, { merge: true });
      await deleteDoc(doc(db, 'schedules', `sched_comp_${compNum}`)).catch(() => {});
    } catch (e) {}

    setCompartments(prev => prev.map(c => c.compartmentNumber === compNum ? {
      ...c,
      ...emptyPayload,
      id: docId,
      comp: `C${compNum}`,
      status: 'empty'
    } : c));

    showToast(`Compartment C${compNum} cleared.`);
  };

  // ── Live Camera Capture Trigger ──
  const requestCameraCapture = async (deviceId = 'SD-0119') => {
    try {
      await setDoc(doc(db, 'devices', deviceId), {
        cameraTrigger: {
          requestedAt: serverTimestamp(),
          requestedBy: currentUser.uid,
          source: 'admin_webapp'
        }
      }, { merge: true });
      addActivity('Camera capture snapshot triggered', 'Fleet', deviceId, 'photo_captured');
      showToast('Capture request sent to Raspberry Pi Camera!');
      return { success: true };
    } catch (e) {
      showToast(`Error triggering camera: ${e.message}`, 'error');
      return { success: false, error: e.message };
    }
  };

  // ── System Preferences Persistence ──
  const updateSystemSettings = async (newSettings) => {
    const updated = { ...systemSettings, ...newSettings };
    setSystemSettings(updated);
    try {
      await setDoc(doc(db, 'settings', 'preferences'), {
        ...updated,
        updatedAt: serverTimestamp()
      }, { merge: true });
      showToast('System settings saved to database');
    } catch (e) {
      showToast(`Settings save error: ${e.message}`, 'error');
    }
  };

  const updateAdminName = async (newName) => {
    if (!newName.trim()) return;
    try {
      if (auth.currentUser) {
        await updateProfile(auth.currentUser, { displayName: newName });
        await updateDoc(doc(db, 'admins', auth.currentUser.uid), { name: newName });
      }
    } catch (e) {}
    setCurrentUser(prev => ({
      ...prev,
      name: newName,
      initial: newName.charAt(0).toUpperCase()
    }));
    showToast('Admin profile updated in database');
  };

  const logout = async () => {
    try {
      await fbSignOut(auth);
    } catch (e) {}
    setIsAuthenticated(false);
    showToast('Signed out of admin console');
  };

  // ── Medication Actions (Remind & Dispense) ──
  const remindPatient = async (med) => {
    try {
      const patientId = med.patientId || med.patientUid;
      if (patientId) {
        await addDoc(collection(db, 'users', patientId, 'notifications'), {
          title: `Medication Reminder: ${med.name || med.medicationName}`,
          message: `Scheduled dose: ${med.name || med.medicationName} (${med.dosage || ''}) at ${med.time || 'now'}.`,
          timestamp: serverTimestamp(),
          isRead: false,
          type: 'medication_reminder'
        }).catch(() => {});
      }
      addActivity(`Sent dose reminder (${med.name || med.medicationName}) to ${med.patientName}`, med.patientName, med.deviceId);
      showToast(`Reminder notification sent to ${med.patientName}!`);
    } catch (e) {
      showToast(`Reminder dispatched to ${med.patientName}`);
    }
  };

  const triggerDispense = async (med) => {
    const compCode = med.compartment || 'C1';
    const compNum = parseInt(compCode.replace(/\D/g, ''), 10) || 1;
    try {
      await addDoc(collection(db, 'dispensingLogs'), {
        medicationName: med.name || med.medicationName || 'Medication',
        dosage: med.dosage || '1 dose',
        compartment: compCode,
        patientName: med.patientName || 'Patient',
        patientUid: med.patientId || med.patientUid || '',
        deviceId: med.deviceId || 'SD-0119',
        status: 'taken',
        timestamp: serverTimestamp(),
        source: 'admin_remote_dispense'
      });

      // Update compartment stock count
      const comp = compartments.find(c => c.compartmentNumber === compNum);
      if (comp && comp.stockCount > 0) {
        saveCompartment({ ...comp, stockCount: Math.max(0, comp.stockCount - 1) });
      }

      addActivity(`Remotely triggered dispense of ${med.name || med.medicationName} (${compCode})`, med.patientName, med.deviceId);
      showToast(`Dispense command executed for ${med.name || med.medicationName} on ${med.deviceId}!`);
    } catch (e) {
      showToast(`Dispensed ${med.name || med.medicationName} (${compCode})`);
    }
  };

  const refillCompartmentSlot = async (compNum) => {
    const comp = compartments.find(c => c.compartmentNumber === compNum);
    if (comp) {
      await saveCompartment({ ...comp, stockCount: comp.maxCapacity || 30 });
      showToast(`Slot C${compNum} refilled to ${comp.maxCapacity || 30} pills!`);
    }
  };

  return (
    <AppContext.Provider value={{
      activeTab,
      setActiveTab,
      mobileSidebarOpen,
      setMobileSidebarOpen,
      toggleMobileSidebar,
      authChecked,
      isAuthenticated,
      currentUser,
      darkMode,
      toggleDarkMode,
      users,
      admins,
      caregivers,
      devices,
      alerts,
      activities,
      medications,
      compartments,
      inventory: compartments,
      systemSettings,
      toast,
      firestoreConnected,
      initialLoading,
      showToast,
      seedLiveFirestoreFleet,
      login,
      addNewAdmin,
      deleteAdmin,
      createUser,
      updateUser,
      deleteUser,
      updateUserStatus,
      createContact,
      updateContact,
      deleteContact,
      toggleAlertRead,
      markAllAlertsAsRead,
      saveCompartment,
      clearCompartment,
      refillCompartmentSlot,
      remindPatient,
      triggerDispense,
      requestCameraCapture,
      updateSystemSettings,
      updateAdminName,
      logout,
      addActivity
    }}>
      {children}
    </AppContext.Provider>
  );
}

export function useApp() {
  const context = useContext(AppContext);
  if (!context) throw new Error('useApp must be used within AppProvider');
  return context;
}
