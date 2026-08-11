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
    status: 'degraded',
    battery: 84,
    ip: '192.168.1.120',
    wifiSsid: 'SmartDose-Mesh-5G',
    esp32Status: 'online',
    rpiStatus: 'high_load',
    cameraStatus: 'offline',
    firmwareVersion: 'v2.4.1',
    lastHeartbeat: '45 sec ago'
  },
  {
    id: 'dev_03',
    deviceId: 'SD-0121',
    patientId: 'usr_03',
    patientName: 'Miriam Cortez',
    status: 'online',
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
    status: 'active',
    timeAgo: '3 days ago'
  },
  {
    id: 'alt_02',
    title: 'Empty compartment',
    patientName: 'Miriam Cortez',
    patientId: 'usr_03',
    deviceId: 'SD-0121',
    message: 'Compartment C1 (Metformin 500mg) has reached 0 pills remaining.',
    severity: 'critical',
    status: 'active',
    timeAgo: '2 hours ago'
  },
  {
    id: 'alt_03',
    title: 'Missed medication',
    patientName: 'Miriam Cortez',
    patientId: 'usr_03',
    deviceId: 'SD-0121',
    message: 'Levothyroxine 75mcg scheduled for 08:00 was not taken within the 60m window.',
    severity: 'warning',
    status: 'active',
    timeAgo: '5 hours ago'
  },
  {
    id: 'alt_04',
    title: 'Camera offline',
    patientName: 'Joseph Tan',
    patientId: 'usr_02',
    deviceId: 'SD-0120',
    message: 'MJPEG video stream failed on dispenser SD-0120.',
    severity: 'warning',
    status: 'active',
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
    type: 'dispense_success'
  },
  {
    id: 'act_02',
    title: 'Dose confirmed taken',
    patientName: 'Amara Reyes',
    deviceId: 'SD-0119',
    timeAgo: '7 min ago',
    type: 'dispense_success'
  },
  {
    id: 'act_03',
    title: 'Compartment C1 reported empty',
    patientName: 'Miriam Cortez',
    deviceId: 'SD-0121',
    timeAgo: '2 h ago',
    type: 'compartment_empty'
  },
  {
    id: 'act_04',
    title: 'Levothyroxine 75mcg marked as missed',
    patientName: 'Miriam Cortez',
    deviceId: 'SD-0121',
    timeAgo: '5 h ago',
    type: 'dose_missed'
  }
];

const DEFAULT_MEDICATIONS = [
  { id: 'med_01', patientName: 'Amara Reyes', patientId: 'usr_01', deviceId: 'SD-0119', name: 'Metformin', dosage: '500mg', compartment: 'C1', time: '08:00 AM', frequency: 'Daily', pillsLeft: 24, adherence: 98 },
  { id: 'med_02', patientName: 'Amara Reyes', patientId: 'usr_01', deviceId: 'SD-0119', name: 'Atorvastatin', dosage: '20mg', compartment: 'C2', time: '08:00 PM', frequency: 'Daily', pillsLeft: 18, adherence: 94 },
  { id: 'med_03', patientName: 'Joseph Tan', patientId: 'usr_02', deviceId: 'SD-0120', name: 'Amlodipine', dosage: '5mg', compartment: 'C1', time: '09:00 AM', frequency: 'Daily', pillsLeft: 12, adherence: 90 },
  { id: 'med_04', patientName: 'Joseph Tan', patientId: 'usr_02', deviceId: 'SD-0120', name: 'Losartan', dosage: '50mg', compartment: 'C2', time: '07:00 PM', frequency: 'Daily', pillsLeft: 14, adherence: 86 },
  { id: 'med_05', patientName: 'Miriam Cortez', patientId: 'usr_03', deviceId: 'SD-0121', name: 'Metformin', dosage: '500mg', compartment: 'C1', time: '07:30 AM', frequency: 'Daily', pillsLeft: 0, adherence: 70 },
  { id: 'med_06', patientName: 'Miriam Cortez', patientId: 'usr_03', deviceId: 'SD-0121', name: 'Levothyroxine', dosage: '75mcg', compartment: 'C2', time: '08:00 AM', frequency: 'Daily', pillsLeft: 15, adherence: 78 },
  { id: 'med_07', patientName: 'Rosalyn Perez', patientId: 'usr_05', deviceId: 'SD-0122', name: 'Omeprazole', dosage: '20mg', compartment: 'C1', time: '06:30 AM', frequency: 'Daily', pillsLeft: 20, adherence: 95 }
];

const DEFAULT_INVENTORY = [
  { id: 'inv_01', deviceId: 'SD-0119', patientName: 'Amara Reyes', comp: 'C1', med: 'Metformin 500mg', count: 24, capacity: 30, status: 'good' },
  { id: 'inv_02', deviceId: 'SD-0119', patientName: 'Amara Reyes', comp: 'C2', med: 'Atorvastatin 20mg', count: 18, capacity: 30, status: 'good' },
  { id: 'inv_03', deviceId: 'SD-0120', patientName: 'Joseph Tan', comp: 'C1', med: 'Amlodipine 5mg', count: 12, capacity: 30, status: 'low' },
  { id: 'inv_04', deviceId: 'SD-0120', patientName: 'Joseph Tan', comp: 'C2', med: 'Losartan 50mg', count: 14, capacity: 30, status: 'good' },
  { id: 'inv_05', deviceId: 'SD-0121', patientName: 'Miriam Cortez', comp: 'C1', med: 'Metformin 500mg', count: 0, capacity: 30, status: 'empty' },
  { id: 'inv_06', deviceId: 'SD-0121', patientName: 'Miriam Cortez', comp: 'C2', med: 'Levothyroxine 75mcg', count: 15, capacity: 30, status: 'good' },
  { id: 'inv_07', deviceId: 'SD-0122', patientName: 'Rosalyn Perez', comp: 'C1', med: 'Omeprazole 20mg', count: 20, capacity: 30, status: 'good' }
];

export function AppProvider({ children }) {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [authChecked, setAuthChecked] = useState(false);
  const [isAuthenticated, setIsAuthenticated] = useState(true);
  const [currentUser, setCurrentUser] = useState({
    uid: 'adm_01',
    name: 'Super Admin',
    email: 'admin@smartpill.com',
    role: 'admin',
    initial: 'A'
  });

  const [users, setUsers] = useState(DEFAULT_USERS);
  const [admins, setAdmins] = useState(DEFAULT_ADMINS);
  const [caregivers, setCaregivers] = useState([]); // Clean empty state, populated strictly from Firestore
  const [devices, setDevices] = useState(DEFAULT_DEVICES);
  const [alerts, setAlerts] = useState(DEFAULT_ALERTS);
  const [activities, setActivities] = useState(DEFAULT_ACTIVITIES);
  const [medications, setMedications] = useState(DEFAULT_MEDICATIONS);
  const [inventory, setInventory] = useState(DEFAULT_INVENTORY);
  const [toast, setToast] = useState(null);
  const [firestoreConnected, setFirestoreConnected] = useState(false);

  // Sync real-time data from Firestore & listen to Firebase Auth
  useEffect(() => {
    let unsubs = [];

    const initListeners = () => {
      try {
        // 1. Live listener for users (patients only)
        const unsubUsers = onSnapshot(collection(db, 'users'), (snap) => {
          if (!snap.empty) {
            setFirestoreConnected(true);
            const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
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

        // 3. Live listener for contacts (caregiver contacts)
        const unsubContacts = onSnapshot(collection(db, 'contacts'), (snap) => {
          setFirestoreConnected(true);
          const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
          setCaregivers(list);
        }, () => {});
        unsubs.push(unsubContacts);

        // 4. Live listener for alerts
        const unsubAlerts = onSnapshot(collection(db, 'alerts'), (snap) => {
          if (!snap.empty) {
            setFirestoreConnected(true);
            const list = snap.docs.map(d => ({ id: d.id, ...d.data() }));
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
              if (data.timestamp?.toDate) {
                timeStr = data.timestamp.toDate().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
              }
              return {
                id: d.id,
                title: `${data.medicationName || data.medName || 'Medication'} ${data.dosage || ''} ${data.status === 'taken' ? 'dispensed & taken' : (data.status || 'dispense logged')}`,
                patientName: data.patientName || 'Patient',
                deviceId: data.deviceId || data.dispenserId || 'SD-0119',
                timeAgo: timeStr,
                type: data.type || (data.status === 'taken' ? 'dispense_success' : 'dispense_event')
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
    showToast('Syncing schema to live Firestore...');
    try {
      // 1. Users (Patients)
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
        await setDoc(doc(db, 'devices', d.id), {
          deviceId: d.deviceId,
          patientName: d.patientName,
          status: d.status,
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
          status: a.status,
          createdAt: serverTimestamp()
        }, { merge: true });
      }

      // 5. Schedules
      for (const m of DEFAULT_MEDICATIONS) {
        await setDoc(doc(db, 'schedules', m.id), {
          medicationName: m.name,
          dosage: m.dosage,
          compartment: m.compartment,
          time: m.time,
          frequency: m.frequency,
          patientName: m.patientName,
          deviceId: m.deviceId,
          pillsLeft: m.pillsLeft,
          adherence: m.adherence,
          createdAt: serverTimestamp()
        }, { merge: true });
      }

      // 6. Dispensing logs
      await addDoc(collection(db, 'dispensingLogs'), {
        medicationName: 'Metformin',
        dosage: '500mg',
        compartment: 'C1',
        patientName: 'Amara Reyes',
        deviceId: 'SD-0119',
        status: 'taken',
        timestamp: serverTimestamp()
      });

      showToast('Live Firestore populated successfully!');
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

  // ── Caregiver Contacts CRUD (Strictly Live Firestore) ──

  const createContact = async (contactData) => {
    try {
      const newDoc = {
        ...contactData,
        pairingStatus: contactData.pairingStatus || 'paired',
        smsAlerts: contactData.smsAlerts ?? true,
        createdAt: serverTimestamp()
      };
      const docRef = await addDoc(collection(db, 'contacts'), newDoc);
      const fullContact = { id: docRef.id, ...newDoc };
      setCaregivers(prev => [fullContact, ...prev]);
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
      await updateDoc(doc(db, 'contacts', contactId), updatedData);
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

  const resolveAlert = async (alertId) => {
    try {
      await updateDoc(doc(db, 'alerts', alertId), { 
        status: 'resolved', 
        resolvedAt: serverTimestamp(),
        resolvedBy: currentUser.uid 
      });
    } catch (e) {}
    setAlerts(prev => prev.filter(a => a.id !== alertId));
    addActivity(`Alert marked as resolved (#${alertId})`, 'System', 'SD-CORE');
    showToast('Alert resolved and archived');
  };

  const dismissAlert = (alertId) => {
    setAlerts(prev => prev.filter(a => a.id !== alertId));
    showToast('Alert dismissed');
  };

  const refillCompartment = (invId, amount = 30) => {
    setInventory(prev => prev.map(item => item.id === invId ? { ...item, count: amount, status: 'good' } : item));
    showToast('Compartment refilled successfully');
    addActivity('Compartment refilled to full capacity (30 pills)', 'Pharmacist', 'SD-DISPENSER');
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
    showToast('Admin profile updated');
  };

  const logout = async () => {
    try {
      await fbSignOut(auth);
    } catch (e) {}
    setIsAuthenticated(false);
    showToast('Signed out of admin console');
  };

  return (
    <AppContext.Provider value={{
      activeTab,
      setActiveTab,
      authChecked,
      isAuthenticated,
      currentUser,
      users,
      admins,
      caregivers,
      devices,
      alerts,
      activities,
      medications,
      inventory,
      toast,
      firestoreConnected,
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
      resolveAlert,
      dismissAlert,
      refillCompartment,
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
