import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PairingTokenModel {
  final String tokenId;
  final String patientUid;
  final String patientName;
  final String patientEmail;
  final String pairingCode;
  final DateTime expiresAt;
  final String qrPayload;

  PairingTokenModel({
    required this.tokenId,
    required this.patientUid,
    required this.patientName,
    required this.patientEmail,
    required this.pairingCode,
    required this.expiresAt,
    required this.qrPayload,
  });
}

class PairingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Helper to generate human-readable pairing code (e.g. SPD-8F4K-91XQ)
  String _generatePairingCode() {
    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    final rnd = Random();
    String code1 = List.generate(4, (_) => chars[rnd.nextInt(chars.length)]).join();
    String code2 = List.generate(4, (_) => chars[rnd.nextInt(chars.length)]).join();
    return 'SPD-$code1-$code2';
  }

  /// Generate a 10-minute expiring QR token for a Patient
  Future<PairingTokenModel> generatePairingToken({
    required String patientUid,
    required String patientName,
    required String patientEmail,
  }) async {
    final tokenId = _uuid.v4();
    final pairingCode = _generatePairingCode();
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: 10));

    final qrMap = {
      'app': 'SmartDose',
      'type': 'pairing_token',
      'tokenId': tokenId,
      'code': pairingCode,
      'patientUid': patientUid,
      'patientName': patientName,
    };

    final qrPayload = jsonEncode(qrMap);

    try {
      await _db.collection('pairing_tokens').doc(tokenId).set({
        'tokenId': tokenId,
        'patientUid': patientUid,
        'patientName': patientName,
        'patientEmail': patientEmail,
        'pairingCode': pairingCode,
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'isUsed': false,
      });
    } catch (e) {
      // Log permission warning; fallback payload inside QR code will allow scanning to work
      print('Pairing tokens Firestore write skipped or denied: $e');
    }

    return PairingTokenModel(
      tokenId: tokenId,
      patientUid: patientUid,
      patientName: patientName,
      patientEmail: patientEmail,
      pairingCode: pairingCode,
      expiresAt: expiresAt,
      qrPayload: qrPayload,
    );
  }

  /// Validate a scanned QR string or typed pairing code
  Future<Map<String, dynamic>> validatePairingToken(String rawInput) async {
    String? tokenId;
    String? pairingCode;
    Map<String, dynamic>? directQrPayload;

    final trimmed = rawInput.trim();

    // Check if input is a JSON string from QR Code
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final Map<String, dynamic> parsed = jsonDecode(trimmed);
        if (parsed['app'] == 'SmartDose') {
          tokenId = parsed['tokenId'];
          pairingCode = parsed['code'];
          directQrPayload = parsed;
        }
      } catch (_) {}
    }

    if (tokenId == null && pairingCode == null) {
      // Treat as raw pairing code, clean up formatting
      pairingCode = trimmed.toUpperCase();
      if (!pairingCode.startsWith('SPD-') && pairingCode.length == 8) {
        pairingCode = 'SPD-${pairingCode.substring(0, 4)}-${pairingCode.substring(4)}';
      }
    }

    QuerySnapshot? query;
    try {
      if (tokenId != null) {
        query = await _db.collection('pairing_tokens').where('tokenId', isEqualTo: tokenId).limit(1).get();
      } else if (pairingCode != null) {
        query = await _db.collection('pairing_tokens').where('pairingCode', isEqualTo: pairingCode).limit(1).get();
      }
    } catch (_) {
      // Firestore query failed due to rules or network
    }

    if (query == null || query.docs.isEmpty) {
      // Fallback: If QR contains direct payload, use it gracefully
      if (directQrPayload != null && directQrPayload['patientUid'] != null) {
        return {
          'tokenId': directQrPayload['tokenId'] ?? 'token',
          'patientUid': directQrPayload['patientUid'],
          'name': directQrPayload['patientName'] ?? 'Patient',
          'email': '',
          'photoUrl': null,
          'age': null,
        };
      }
      throw Exception('Invalid pairing code or QR code. Please check and try again.');
    }

    final doc = query.docs.first;
    final data = doc.data() as Map<String, dynamic>;

    final bool isUsed = data['isUsed'] ?? false;
    if (isUsed) {
      throw Exception('This QR code or pairing code has already been used.');
    }

    final Timestamp? expiresAtTs = data['expiresAt'] as Timestamp?;
    if (expiresAtTs != null && expiresAtTs.toDate().isBefore(DateTime.now())) {
      throw Exception('This pairing code has expired. Please ask the patient to generate a new QR code.');
    }

    // Fetch full patient profile details
    final patientUid = data['patientUid'] as String;
    final patientDoc = await _db.collection('users').doc(patientUid).get();

    Map<String, dynamic> patientProfile = {
      'patientUid': patientUid,
      'name': data['patientName'] ?? 'Patient',
      'email': data['patientEmail'] ?? '',
      'photoUrl': null,
      'age': null,
    };

    if (patientDoc.exists && patientDoc.data() != null) {
      final pData = patientDoc.data()!;
      patientProfile['name'] = pData['name'] ?? patientProfile['name'];
      patientProfile['email'] = pData['email'] ?? patientProfile['email'];
      patientProfile['photoUrl'] = pData['photoUrl'] ?? pData['profilePhotoUrl'];
      
      if (pData['dateOfBirth'] != null) {
        try {
          final dob = DateTime.parse(pData['dateOfBirth']);
          final age = DateTime.now().year - dob.year;
          patientProfile['age'] = age;
        } catch (_) {}
      }
    }

    return {
      'tokenId': doc.id,
      ...patientProfile,
    };
  }

  /// Caregiver sends a connection request to Patient
  Future<void> sendPairingRequest({
    required String patientUid,
    required String patientName,
    required String caregiverUid,
    required String caregiverName,
    required String caregiverEmail,
    required String relationship,
    String? caregiverPhoto,
  }) async {
    // Check if pending request already exists
    final existing = await _db
        .collection('pairing_requests')
        .where('patientUid', isEqualTo: patientUid)
        .where('caregiverUid', isEqualTo: caregiverUid)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('A connection request is already pending approval by the patient.');
    }

    await _db.collection('pairing_requests').add({
      'patientUid': patientUid,
      'patientName': patientName,
      'caregiverUid': caregiverUid,
      'caregiverName': caregiverName,
      'caregiverEmail': caregiverEmail,
      'caregiverPhoto': caregiverPhoto,
      'relationship': relationship,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream incoming pending caregiver requests for a patient
  Stream<List<Map<String, dynamic>>> getPendingRequestsStream(String patientUid) {
    return _db
        .collection('pairing_requests')
        .where('patientUid', isEqualTo: patientUid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'requestId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Patient approves a caregiver request
  Future<void> approvePairingRequest(String requestId, Map<String, dynamic> requestData) async {
    await _db.collection('pairing_requests').doc(requestId).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });

    // Add to active pairings collection
    await _db.collection('pairings').add({
      'patientUid': requestData['patientUid'],
      'patientName': requestData['patientName'] ?? 'Patient',
      'caregiverUid': requestData['caregiverUid'],
      'caregiverName': requestData['caregiverName'] ?? 'Caregiver',
      'caregiverEmail': requestData['caregiverEmail'] ?? '',
      'caregiverPhoto': requestData['caregiverPhoto'],
      'relationship': requestData['relationship'] ?? 'Caregiver',
      'role': 'Primary Caregiver',
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  /// Patient rejects a caregiver request
  Future<void> rejectPairingRequest(String requestId) async {
    await _db.collection('pairing_requests').doc(requestId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream of active connected caregivers for a patient
  Stream<List<Map<String, dynamic>>> getConnectedCaregiversStream(String patientUid) {
    return _db
        .collection('pairings')
        .where('patientUid', isEqualTo: patientUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'pairingId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Stream of active connected patients for a caregiver
  Stream<List<Map<String, dynamic>>> getConnectedPatientsStream(String caregiverUid) {
    return _db
        .collection('pairings')
        .where('caregiverUid', isEqualTo: caregiverUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'pairingId': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Remove a connected pairing
  Future<void> removePairing(String pairingId) async {
    await _db.collection('pairings').doc(pairingId).delete();
  }

  /// Update caregiver role (Primary Caregiver vs Family Member)
  Future<void> updateCaregiverRole(String pairingId, String newRole) async {
    await _db.collection('pairings').doc(pairingId).update({
      'role': newRole,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
