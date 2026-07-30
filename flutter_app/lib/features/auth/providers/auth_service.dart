import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Sign Up ──────────────────────────────────────────────────────────────

  /// Sign Up new user with full personal profile.
  /// Returns null on success or an error message string.
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String role, // 'patient' | 'caregiver'
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final String uid = cred.user!.uid;
      await cred.user!.updateDisplayName(name);

      final String nowIso = DateTime.now().toIso8601String();

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone ?? '',
        'dateOfBirth': dateOfBirth ?? '',
        'gender': gender ?? '',
        'address': address ?? '',
        'status': 'active',
        'authProvider': 'email',
        'profilePhotoUrl': '',
        'createdAt': nowIso,
        'updatedAt': nowIso,
      }, SetOptions(merge: true));

      if (role == 'patient') {
        await _firestore.collection('patients').doc(uid).set({
          'patientId': uid,
          'name': name,
          'deviceId': '',
          'faceEnrollmentStatus': 'pending',
          'adherencePercent': 0,
          'caregiverIds': [],
          'createdAt': nowIso,
        }, SetOptions(merge: true));
      } else if (role == 'caregiver') {
        await _firestore.collection('caregivers').doc(uid).set({
          'caregiverId': uid,
          'name': name,
          'patientIds': [],
          'createdAt': nowIso,
        }, SetOptions(merge: true));
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed';
    } catch (e) {
      return 'Account created, but Firestore error: ${e.toString()}';
    }
  }

  // ─── Sign In (Email/Password) ─────────────────────────────────────────────

  Future<Map<String, dynamic>?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final String uid = cred.user!.uid;
      try {
        final DocumentSnapshot doc =
            await _firestore.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          return doc.data() as Map<String, dynamic>;
        }
      } catch (firestoreError) {
        // If Firestore doc read fails due to security rules permission-denied,
        // fallback gracefully using Auth info
      }
      return {
        'uid': uid,
        'name': (cred.user?.displayName?.isNotEmpty == true)
            ? cred.user!.displayName!
            : email.split('@').first.toUpperCase(),
        'email': email,
        'role': 'patient',
      };
    } catch (e) {
      rethrow;
    }
  }

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential cred =
          await _auth.signInWithCredential(credential);
      final String uid = cred.user!.uid;

      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return {
          'uid': uid,
          'name': cred.user?.displayName ?? 'User',
          'email': cred.user?.email ?? '',
          'role': 'new_google_user',
          'profilePhotoUrl': cred.user?.photoURL ?? '',
          'authProvider': 'google',
        };
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Google sign-in failed');
    } catch (e) {
      rethrow;
    }
  }

  // ─── Facebook Sign-In ─────────────────────────────────────────────────────

  /// Sign in with Facebook. Creates Firestore doc if first time.
  /// Returns user data map, or null if cancelled.
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      // Trigger the Facebook login dialog
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status == LoginStatus.cancelled) return null;

      if (result.status == LoginStatus.failed) {
        throw Exception(result.message ?? 'Facebook sign-in failed');
      }

      // Get the access token
      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.tokenString);

      // Sign in with Firebase
      final UserCredential cred =
          await _auth.signInWithCredential(credential);
      final String uid = cred.user!.uid;

      // Fetch Facebook user data for profile photo
      final userData = await FacebookAuth.instance.getUserData(
        fields: 'name,email,picture.width(200)',
      );
      final String? profilePhotoUrl =
          userData['picture']?['data']?['url'] as String?;

      // Check if Firestore doc already exists
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        // Returning Facebook user → return existing data
        return doc.data() as Map<String, dynamic>;
      } else {
        // New Facebook user → route to signup flow with pre-filled data
        return {
          'uid': uid,
          'name': cred.user?.displayName ?? userData['name'] ?? 'User',
          'email': cred.user?.email ?? userData['email'] ?? '',
          'role': 'new_facebook_user',
          'profilePhotoUrl': profilePhotoUrl ?? cred.user?.photoURL ?? '',
          'authProvider': 'facebook',
        };
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Facebook sign-in failed');
    } catch (e) {
      rethrow;
    }
  }

  // ─── Complete Google / Facebook Profile ───────────────────────────────────

  Future<String?> completeGoogleUserProfile({
    required String uid,
    required String name,
    required String email,
    required String role,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? profilePhotoUrl,
    String authProvider = 'google',
  }) async {
    try {
      final String nowIso = DateTime.now().toIso8601String();

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone ?? '',
        'dateOfBirth': dateOfBirth ?? '',
        'gender': gender ?? '',
        'address': address ?? '',
        'status': 'active',
        'authProvider': authProvider,
        'profilePhotoUrl': profilePhotoUrl ?? '',
        'createdAt': nowIso,
        'updatedAt': nowIso,
      }, SetOptions(merge: true));

      if (role == 'patient') {
        await _firestore.collection('patients').doc(uid).set({
          'patientId': uid,
          'name': name,
          'deviceId': '',
          'faceEnrollmentStatus': 'pending',
          'adherencePercent': 0,
          'caregiverIds': [],
          'createdAt': nowIso,
        }, SetOptions(merge: true));
      } else if (role == 'caregiver') {
        await _firestore.collection('caregivers').doc(uid).set({
          'caregiverId': uid,
          'name': name,
          'patientIds': [],
          'createdAt': nowIso,
        }, SetOptions(merge: true));
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ─── Password Reset ───────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Get Role & Profile ───────────────────────────────────────────────────

  Future<String> getUserRole(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] ?? 'patient';
      }
    } catch (_) {}
    return 'patient';
  }

  /// Fetch user profile data from Firestore.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Real-time stream of user profile data from Firestore.
  Stream<DocumentSnapshot<Map<String, dynamic>>> userProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Update user profile fields in Firestore.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
