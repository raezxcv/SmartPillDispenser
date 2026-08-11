import { initializeApp, getApps, getApp } from 'firebase/app';
import { 
  getAuth, 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword,
  signOut, 
  onAuthStateChanged,
  sendPasswordResetEmail,
  updateProfile
} from 'firebase/auth';
import { 
  getFirestore, 
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
  where, 
  limit, 
  serverTimestamp, 
  Timestamp 
} from 'firebase/firestore';

export const firebaseConfig = {
  apiKey: "AIzaSyAL5AdET4zAj3kjdeKLeNbC_PY4_Nab6vw",
  authDomain: "smart-pill-dispenser-baa02.firebaseapp.com",
  projectId: "smart-pill-dispenser-baa02",
  storageBucket: "smart-pill-dispenser-baa02.firebasestorage.app",
  messagingSenderId: "757028886151",
  appId: "1:757028886151:web:f27463bdea39fef9abca22",
  measurementId: "G-H5J8Q5R2EF"
};

const app = !getApps().length ? initializeApp(firebaseConfig) : getApp();
export const auth = getAuth(app);
export const db = getFirestore(app);

export {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
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
  where,
  limit,
  serverTimestamp,
  Timestamp
};
