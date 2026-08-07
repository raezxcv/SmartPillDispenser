import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'caregiver_connect_patient_screen.dart';
import 'caregiver_patient_schedule_screen.dart';
import 'caregiver_live_camera_screen.dart';
import 'caregiver_notifications_screen.dart';
import '../../pairing/services/pairing_service.dart';
import 'package:smartdose/shared/widgets/smartdose_loading.dart';

class CaregiverDashboardTab extends StatefulWidget {
  final VoidCallback onGoToPatients;
  final VoidCallback onGoToReports;
  final VoidCallback onGoToProfile;

  const CaregiverDashboardTab({
    super.key,
    required this.onGoToPatients,
    required this.onGoToReports,
    required this.onGoToProfile,
  });

  @override
  State<CaregiverDashboardTab> createState() => _CaregiverDashboardTabState();
}

class _CaregiverDashboardTabState extends State<CaregiverDashboardTab> {
  final PairingService _pairingService = PairingService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  Stream<List<Map<String, dynamic>>>? _patientsStream;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userDocStream;
  StreamSubscription? _unreadSub;
  StreamSubscription? _deviceSub;

  int _unreadAlertsCount = 0;
  bool _dispatchingEmergency = false;
  Timer? _countdownTimer;
  Map<String, dynamic>? _deviceData;
  String? _deviceId;

  String _cachedHeaderPhotoUrl = '';
  String _cachedHeaderName = '';
  int _cachedAvatarGradIdx = 0;

  static const List<List<Color>> _avatarGradients = [
    [Color(0xFF00C882), Color(0xFF00A36C)], // Emerald Mint
    [Color(0xFF06B6D4), Color(0xFF0891B2)], // Ocean Cyan
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)], // Royal Purple
    [Color(0xFFEC4899), Color(0xFFDB2777)], // Vibrant Pink
    [Color(0xFFF43F5E), Color(0xFFE11D48)], // Coral Rose
    [Color(0xFF475569), Color(0xFF1E293B)], // Midnight Slate
  ];

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _patientsStream = _pairingService.getConnectedPatientsStream(_uid!);
      _userDocStream = FirebaseFirestore.instance.collection('users').doc(_uid).snapshots();
      _listenToUnreadNotifications();
      _initDeviceStream();
    }
    _startCountdown();
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    _deviceSub?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _listenToUnreadNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _unreadSub = FirebaseFirestore.instance
        .collection('notifications')
        .doc(user.uid)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _unreadAlertsCount = snapshot.docs.length;
        });
      }
    });
  }

  Future<void> _initDeviceStream() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final deviceId = userDoc.data()?['deviceId'] as String? ?? 'ESP32_DISPENSER_01';
      if (!mounted) return;
      setState(() => _deviceId = deviceId);
      _deviceSub = FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .snapshots()
          .listen((snap) {
        if (mounted && snap.exists) {
          setState(() => _deviceData = snap.data());
        }
      });
    } catch (_) {}
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'CG';
    final parts = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first[0].toUpperCase();
    }
    return 'CG';
  }

  Widget _buildAvatarImage(String photoVal, String initials, double size) {
    final trimmed = photoVal.trim();
    if (trimmed.isEmpty) {
      return Center(
        child: Text(
          initials,
          style: TextStyle(color: Colors.white, fontSize: size * 0.38, fontWeight: FontWeight.w900),
        ),
      );
    }
    if (trimmed.startsWith('data:image')) {
      try {
        final base64Str = trimmed.contains(',') ? trimmed.split(',').last : trimmed;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => Center(
            child: Text(initials, style: TextStyle(color: Colors.white, fontSize: size * 0.38, fontWeight: FontWeight.w900)),
          ),
        );
      } catch (_) {}
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => Center(
          child: Text(initials, style: TextStyle(color: Colors.white, fontSize: size * 0.38, fontWeight: FontWeight.w900)),
        ),
      );
    }
    final file = File(trimmed);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => Center(
          child: Text(initials, style: TextStyle(color: Colors.white, fontSize: size * 0.38, fontWeight: FontWeight.w900)),
        ),
      );
    }
    return Center(
      child: Text(initials, style: TextStyle(color: Colors.white, fontSize: size * 0.38, fontWeight: FontWeight.w900)),
    );
  }

  // Fallback sample patients
  final List<Map<String, dynamic>> _samplePatients = [
    {
      'id': 'patient-1',
      'patientName': 'Maria Delgado',
      'relationship': 'Mother',
      'age': 68,
      'isOnline': true,
      'adherence': 92,
      'nextDose': 'Next: Metformin 500 mg · 20:00',
      'needsAttention': false,
      'initials': 'MD',
      'photoUrl': null,
    },
    {
      'id': 'patient-2',
      'patientName': 'João Ferreira',
      'relationship': 'Father',
      'age': 74,
      'isOnline': true,
      'adherence': 74,
      'nextDose': 'Next: Warfarin 3 mg · 18:30',
      'needsAttention': true,
      'initials': 'JF',
      'photoUrl': null,
    },
    {
      'id': 'patient-3',
      'patientName': 'Elena Costa',
      'relationship': 'Aunt',
      'age': 71,
      'isOnline': false,
      'adherence': 58,
      'nextDose': 'Next: Levothyroxine 50 mcg · 07:30',
      'needsAttention': true,
      'initials': 'EC',
      'photoUrl': null,
    },
  ];

  Future<void> _onEmergencyDispense() async {
    final uid = _uid;
    if (uid == null) return;
    setState(() => _dispatchingEmergency = true);
    try {
      if (_deviceId != null) {
        try {
          await FirebaseFirestore.instance.collection('devices').doc(_deviceId).update({
            'emergencyDispense': true,
            'emergencyRequestedAt': FieldValue.serverTimestamp(),
            'emergencyRequestedBy': uid,
          });
        } catch (_) {}
      }

      await FirebaseFirestore.instance.collection('emergencyRequests').add({
        'initiatedBy': 'caregiver',
        'caregiverUid': uid,
        'patientName': 'Maria Delgado',
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(LucideIcons.siren, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Emergency alert & dispense signal sent!'),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error triggering emergency alert: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _dispatchingEmergency = false);
    }
  }

  Future<void> _onDispenseNow() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      if (_deviceId != null) {
        await FirebaseFirestore.instance.collection('devices').doc(_deviceId).update({
          'pendingDispense': {
            'compartment': 'Compartment 1',
            'medicationName': 'Metformin 500 mg',
            'requestedAt': FieldValue.serverTimestamp(),
            'requestedBy': uid,
          },
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dispense signal sent for Maria Delgado (Metformin 500 mg)!'),
            backgroundColor: const Color(0xFF00A36C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTextColor = theme.colorScheme.onSurface;
    const emerald = Color(0xFF00A36C);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header Row matching Patient Home Tab
          _buildHeader(),
          const SizedBox(height: 20),

          // 2. Low Stock Alert Banner matching Patient Home Tab
          _buildLowStockBanner(1),
          const SizedBox(height: 14),

          // 3. Device Status Card matching Patient Home Tab
          _buildDeviceStatusCard(),
          const SizedBox(height: 20),

          // 4. Next Patient Medication Highlight Card matching Patient Home Tab
          _buildNextMedCard(),
          const SizedBox(height: 24),

          // 5. Today's Adherence & Progress Section matching Patient Home Tab
          _buildProgressSection(6, 2, 8, 0.75, 1),
          const SizedBox(height: 24),

          // 6. Quick Actions Row matching Patient Home Tab
          Text(
            'Quick actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionCircle(
                icon: LucideIcons.qrCode,
                label: 'Connect',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CaregiverConnectPatientScreen()),
                  );
                },
              ),
              _buildQuickActionCircle(
                icon: LucideIcons.camera,
                label: 'Live camera',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaregiverLiveCameraScreen(
                        patientName: 'Maria Delgado',
                        patientId: 'patient-1',
                      ),
                    ),
                  );
                },
              ),
              _buildQuickActionCircle(
                icon: LucideIcons.calendar,
                label: 'Schedule',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaregiverPatientScheduleScreen(
                        patientName: 'Maria Delgado',
                        patientId: 'patient-1',
                      ),
                    ),
                  );
                },
              ),
              _buildQuickActionCircle(
                icon: LucideIcons.trendingUp,
                label: 'Reports',
                onTap: widget.onGoToReports,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // 7. Overview Metrics Grid
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildOverviewCard(
                icon: LucideIcons.users,
                iconBg: const Color(0xFFD1FAE5),
                iconColor: emerald,
                value: '3',
                title: 'Connected patients',
                subtitle: 'All paired',
                onTap: widget.onGoToPatients,
              ),
              _buildOverviewCard(
                icon: LucideIcons.alertTriangle,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                value: '2',
                title: 'Need attention',
                subtitle: 'Missed or low adherence',
                onTap: widget.onGoToPatients,
              ),
              _buildOverviewCard(
                icon: LucideIcons.heart,
                iconBg: const Color(0xFFD1FAE5),
                iconColor: emerald,
                value: '75%',
                title: 'Avg. adherence',
                subtitle: 'Last 30 days',
                onTap: widget.onGoToReports,
              ),
              _buildOverviewCard(
                icon: LucideIcons.bell,
                iconBg: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFEF4444),
                value: '1',
                title: 'Emergency alerts',
                subtitle: 'Active now',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CaregiverNotificationsScreen()),
                  );
                },
              ),
              _buildOverviewCard(
                icon: LucideIcons.wifi,
                iconBg: const Color(0xFFD1FAE5),
                iconColor: emerald,
                value: '2/3',
                title: 'Device status',
                subtitle: '1 offline',
              ),
              _buildOverviewCard(
                icon: LucideIcons.package,
                iconBg: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                value: '1',
                title: 'Low medicine stock',
                subtitle: 'Compartments to refill',
              ),
            ],
          ),

          const SizedBox(height: 28),

          // 8. Patients Today Roster Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patients today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: primaryTextColor,
                ),
              ),
              GestureDetector(
                onTap: widget.onGoToPatients,
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: emerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _uid == null
              ? _buildSamplePatientList()
              : StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _patientsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: SmartDoseLoading(size: 60),
                        ),
                      );
                    }
                    final patients = snapshot.data ?? [];
                    if (patients.isEmpty) {
                      return _buildSamplePatientList();
                    }
                    return Column(
                      children: patients.map((p) => _buildPatientsTodayCard(p)).toList(),
                    );
                  },
                ),

          const SizedBox(height: 24),

          // 9. Emergency Alert / Dispense Button matching Patient Home Tab
          _buildEmergencyButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Header matching Patient Home Tab layout
  Widget _buildHeader() {
    final theme = Theme.of(context);
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userDocStream,
      builder: (context, userSnap) {
        if (userSnap.hasData && userSnap.data?.data() != null) {
          final userData = userSnap.data!.data()!;
          _cachedHeaderName = userData['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? 'Anna Delgado';
          _cachedHeaderPhotoUrl = (userData['photoUrl'] ?? userData['profilePhotoUrl'] ?? FirebaseAuth.instance.currentUser?.photoURL ?? '').toString();
          _cachedAvatarGradIdx = (userData['avatarGradientIndex'] as int? ?? 0).clamp(0, _avatarGradients.length - 1);
        }

        final name = _cachedHeaderName.isNotEmpty ? _cachedHeaderName : (FirebaseAuth.instance.currentUser?.displayName ?? 'Anna Delgado');
        final photoUrl = _cachedHeaderPhotoUrl.isNotEmpty ? _cachedHeaderPhotoUrl : (FirebaseAuth.instance.currentUser?.photoURL ?? '');
        final initials = _getInitials(name);
        final activeGradient = _avatarGradients[_cachedAvatarGradIdx];

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: TextStyle(fontSize: 15, color: secondaryTextColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyle(fontSize: 24, color: primaryTextColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CaregiverNotificationsScreen()),
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(LucideIcons.bell, color: primaryTextColor, size: 22),
                        if (_unreadAlertsCount > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                                border: Border.all(color: cardBgColor, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: widget.onGoToProfile,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: activeGradient),
                      border: Border.all(color: activeGradient.last, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: activeGradient.last.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: _buildAvatarImage(photoUrl, initials, 44),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Low Stock Banner matching Patient Home Tab
  Widget _buildLowStockBanner(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertTriangle, color: Color(0xFFF59E0B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Low stock alert: $count compartment${count > 1 ? 's have' : ' has'} 3 or fewer pills remaining.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Device Status Card matching Patient Home Tab
  Widget _buildDeviceStatusCard() {
    final isOnline = _deviceData?['isOnline'] as bool? ?? true;
    final battery = _deviceData?['batteryPercent'] as int? ?? 88;
    final model = _deviceData?['model'] as String? ?? 'SmartDose Dispenser';
    final lastSync = _deviceData?['lastSyncAt'] as Timestamp?;
    final syncStr = lastSync != null
        ? DateFormat('hh:mm a').format(lastSync.toDate())
        : 'Just now';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isOnline
                  ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.wifi,
              color: isOnline ? const Color(0xFF00A36C) : const Color(0xFF9CA3AF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryTextColor),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline ? 'Online · Last sync $syncStr' : 'Offline · Last sync $syncStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? secondaryTextColor : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CaregiverLiveCameraScreen(
                    patientName: 'Maria Delgado',
                    patientId: 'patient-1',
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00A36C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00A36C).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.camera, color: Color(0xFF00A36C), size: 16),
                  SizedBox(width: 4),
                  Text('Live Stream', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00A36C))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (battery > 0)
            Row(
              children: [
                Icon(
                  battery > 20 ? Icons.battery_std_rounded : Icons.battery_alert_rounded,
                  color: battery > 20 ? secondaryTextColor : const Color(0xFFEF4444),
                  size: 18,
                ),
                const SizedBox(width: 2),
                Text(
                  '$battery%',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primaryTextColor),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Next Patient Medication Highlight Card matching Patient Home Tab
  Widget _buildNextMedCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF00A36C),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00A36C).withValues(alpha: 0.30), blurRadius: 16, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('NEXT PATIENT DOSE',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(LucideIcons.clock, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'In 45m',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: const Icon(LucideIcons.pill, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metformin 500 mg',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Maria Delgado · 20:00 · Compartment 1',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00A36C),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: _onDispenseNow,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Dispense now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(LucideIcons.arrowRight, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Today's Adherence & Progress Section matching Patient Home Tab
  Widget _buildProgressSection(int taken, int missed, int total, double progress, int lowStock) {
    final pct = total > 0 ? '${(progress * 100).round()}%' : '—';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's progress",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
            GestureDetector(
              onTap: widget.onGoToReports,
              child: const Text('Reports',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF00A36C))),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00A36C)),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(pct,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryTextColor)),
                        Text('of today',
                            style: TextStyle(fontSize: 11, color: secondaryTextColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildProgressRow(const Color(0xFF10B981), 'Pills taken', '$taken of $total'),
                    const SizedBox(height: 10),
                    _buildProgressRow(const Color(0xFFEF4444), 'Missed doses', '$missed'),
                    const SizedBox(height: 10),
                    _buildProgressRow(const Color(0xFFF59E0B), 'Low stock items', '$lowStock'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(Color dotColor, String label, String value) {
    final primaryTextColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 13, color: secondaryTextColor)),
        ),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryTextColor)),
      ],
    );
  }

  // Emergency Button matching Patient Home Tab
  Widget _buildEmergencyButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        onPressed: _dispatchingEmergency ? null : _onEmergencyDispense,
        icon: _dispatchingEmergency
            ? const SmartDoseLoading(size: 36)
            : const Icon(LucideIcons.siren, size: 20),
        label: Text(
          _dispatchingEmergency ? 'Sending Emergency Alert…' : 'Emergency Alert / Dispense',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Quick Action Circular Icon Button
  Widget _buildQuickActionCircle({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    const emerald = Color(0xFF00A36C);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cardBgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: emerald.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: emerald, size: 22),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // Overview Rounded Metric Card
  Widget _buildOverviewCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: secondaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Patients Today Roster Cards
  Widget _buildSamplePatientList() {
    return Column(
      children: _samplePatients.map((p) => _buildPatientsTodayCard(p)).toList(),
    );
  }

  Widget _buildPatientsTodayCard(Map<String, dynamic> patient) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.6);

    final name = (patient['patientName'] ?? patient['name'] ?? 'Patient').toString();
    final nextDose = (patient['nextDose'] ?? 'Next: Metformin 500 mg · 20:00').toString();
    final adherence = (patient['adherence'] as num? ?? 92).toInt();
    final initials = (patient['initials'] ?? (name.isNotEmpty ? name.substring(0, 2).toUpperCase() : 'MD')).toString();

    Color pillBg = const Color(0xFFD1FAE5);
    Color pillTextColor = const Color(0xFF00A36C);

    if (adherence < 70) {
      pillBg = const Color(0xFFFEE2E2);
      pillTextColor = const Color(0xFFEF4444);
    } else if (adherence < 85) {
      pillBg = const Color(0xFFFEF3C7);
      pillTextColor = const Color(0xFFD97706);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Color(0xFF00A36C),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nextDose,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$adherence%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: pillTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
