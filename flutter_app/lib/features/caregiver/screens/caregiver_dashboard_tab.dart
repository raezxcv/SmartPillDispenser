import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _patientsStream = _pairingService.getConnectedPatientsStream(_uid!);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // Fallback sample patients matching Mockup Image 2 & 3
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    const emerald = Color(0xFF00A36C);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Emerald Welcome Card (Matching Mockup Image 1)
          _buildEmeraldWelcomeCard(),

          const SizedBox(height: 24),

          // Quick Actions Row (Matching Mockup Image 1)
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

          // Overview Metrics Section (Matching Mockup Image 1)
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 14),

          // 2x3 Grid of Rounded Overview Cards
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

          // Patients Today Section (Matching Mockup Image 2 & 3)
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

          // Patient Roster List Stream or Sample Fallback
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
                      children: patients.map((p) {
                        return _buildPatientsTodayCard(p);
                      }).toList(),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // Emerald Welcome Header Card (Image 1)
  Widget _buildEmeraldWelcomeCard() {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Anna Delgado';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C882), Color(0xFF00A36C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A36C).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Primary Caregiver · 3 patients connected',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              // Standalone Notifications Bell Icon Button on Top Right (Image 1)
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
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(LucideIcons.bell, color: Colors.white, size: 20),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Inner Semi-Transparent Pill Container (Image 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All dispensers reporting. 2 patients need attention today.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Action Circular Icon Button (Image 1)
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

  // Overview Rounded Metric Card (Image 1)
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

  // Patients Today Roster Cards (Image 2 & 3)
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
          // Mint Initials Avatar Badge
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
