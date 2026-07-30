// File generated with real project options from google-services.json
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macOS;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDfPRQ-uUKxFcVa5M1hkkKYNWZ9e4Ef4v4',
    appId: '1:757028886151:android:d7e93028db8ad37babca22',
    messagingSenderId: '757028886151',
    projectId: 'smart-pill-dispenser-baa02',
    authDomain: 'smart-pill-dispenser-baa02.firebaseapp.com',
    storageBucket: 'smart-pill-dispenser-baa02.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfPRQ-uUKxFcVa5M1hkkKYNWZ9e4Ef4v4',
    appId: '1:757028886151:android:d7e93028db8ad37babca22',
    messagingSenderId: '757028886151',
    projectId: 'smart-pill-dispenser-baa02',
    storageBucket: 'smart-pill-dispenser-baa02.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfPRQ-uUKxFcVa5M1hkkKYNWZ9e4Ef4v4',
    appId: '1:757028886151:android:d7e93028db8ad37babca22',
    messagingSenderId: '757028886151',
    projectId: 'smart-pill-dispenser-baa02',
    storageBucket: 'smart-pill-dispenser-baa02.firebasestorage.app',
    iosBundleId: 'com.smartpilldispenser.app',
  );

  static const FirebaseOptions macOS = FirebaseOptions(
    apiKey: 'AIzaSyDfPRQ-uUKxFcVa5M1hkkKYNWZ9e4Ef4v4',
    appId: '1:757028886151:android:d7e93028db8ad37babca22',
    messagingSenderId: '757028886151',
    projectId: 'smart-pill-dispenser-baa02',
    storageBucket: 'smart-pill-dispenser-baa02.firebasestorage.app',
    iosBundleId: 'com.smartpilldispenser.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDfPRQ-uUKxFcVa5M1hkkKYNWZ9e4Ef4v4',
    appId: '1:757028886151:android:d7e93028db8ad37babca22',
    messagingSenderId: '757028886151',
    projectId: 'smart-pill-dispenser-baa02',
    authDomain: 'smart-pill-dispenser-baa02.firebaseapp.com',
    storageBucket: 'smart-pill-dispenser-baa02.firebasestorage.app',
  );
}
