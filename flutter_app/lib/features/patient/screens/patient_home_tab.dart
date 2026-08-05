import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'compartment_inventory_screen.dart';
import 'camera_feed_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smartdose/shared/widgets/smartdose_loading.dart';

class PatientHomeTab extends StatefulWidget {
  final String displayName;
  final String userInitials;
  final VoidCallback onGoToMeds;
  final VoidCallback onGoToHistory;
  final VoidCallback onGoToAlerts;
  final VoidCallback onGoToProfile;
  final int unreadCount;

  const PatientHomeTab({
    super.key,
    required this.displayName,
    required this.userInitials,
    required this.onGoToMeds,
    required this.onGoToHistory,
    required this.onGoToAlerts,
    required this.onGoToProfile,
    required this.unreadCount,
  });

  @override
  State<PatientHomeTab> createState() => _PatientHomeTabState();
}

class _PatientHomeTabState extends State<PatientHomeTab> {
  Timer? _countdownTimer;
  Map<String, dynamic>? _nextMed;
  bool _dispatchingEmergency = false;
  StreamSubscription? _deviceSub;
  Map<String, dynamic>? _deviceData;
  String? _deviceId;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _initDeviceStream();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _deviceSub?.cancel();
    super.dispose();
  }

  Future<void> _initDeviceStream() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final deviceId = userDoc.data()?['deviceId'] as String?;
      if (deviceId == null || !mounted) return;
      setState(() => _deviceId = deviceId);
      _deviceSub = FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .snapshots()
          .listen((snap) {
        if (mounted) setState(() => _deviceData = snap.data());
      });
    } catch (_) {}
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_nextMed != null && mounted) setState(() {});
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? get _schedulesStream {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('schedules')
        .where('patientUid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? get _todayLogsStream {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('dispensingLogs')
        .where('patientUid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? get _compartmentsStream {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('compartments')
        .where('patientUid', isEqualTo: uid)
        .snapshots();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatCountdown(Duration d) {
    if (d == Duration.zero) return 'Due now';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return 'In ${h}h ${m}m';
    if (m > 0) return 'In ${m}m ${s}s';
    return 'In ${s}s';
  }

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
        } catch (e) {
          debugPrint('Device status update warning: $e');
        }
      }

      // Add emergency request record
      await FirebaseFirestore.instance.collection('emergencyRequests').add({
        'patientId': uid,
        'patientUid': uid,
        'initiatedBy': 'patient',
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      // Add to dispensing logs for history
      await FirebaseFirestore.instance.collection('dispensingLogs').add({
        'patientUid': uid,
        'patientId': uid,
        'medicationName': 'Emergency Request',
        'type': 'emergency',
        'status': 'requested',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add notification item
      try {
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(uid)
            .collection('items')
            .add({
          'title': 'Emergency dispense requested',
          'body': 'An emergency dispense request was sent to the device.',
          'type': 'emergency',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Notification add warning: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.emergency_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Emergency dispense signal sent!'),
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
            content: Text('Error triggering emergency dispense: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _dispatchingEmergency = false);
    }
  }

  Future<void> _onDispenseNow(Map<String, dynamic> med) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      if (_deviceId != null) {
        await FirebaseFirestore.instance.collection('devices').doc(_deviceId).update({
          'pendingDispense': {
            'compartment': med['compartment'] ?? 'Compartment 1',
            'medicationName': med['medicationName'] ?? '',
            'requestedAt': FieldValue.serverTimestamp(),
            'requestedBy': uid,
          },
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dispense signal sent for ${med['medicationName']}!'),
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
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _schedulesStream,
      builder: (context, schedSnap) {
        final allSchedDocs = schedSnap.data?.docs ?? [];
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = todayStart.add(const Duration(days: 1));

        final schedDocs = allSchedDocs.where((doc) {
          final data = doc.data();
          if ((data['isActive'] ?? true) != true) return false;
          final ts = data['scheduledTime'] as Timestamp?;
          if (ts == null) return false;
          final schedDate = ts.toDate();
          final schedDay = DateTime(schedDate.year, schedDate.month, schedDate.day);

          if (todayStart.isBefore(schedDay)) return false;

          final freq = (data['frequency'] as String? ?? 'Daily').trim().toLowerCase();
          if (freq == 'daily') {
            return true;
          } else if (freq == 'weekly') {
            return todayStart.weekday == schedDay.weekday;
          } else {
            return todayStart.year == schedDay.year &&
                   todayStart.month == schedDay.month &&
                   todayStart.day == schedDay.day;
          }
        }).toList();

        schedDocs.sort((a, b) {
          final tsA = a.data()['scheduledTime'] as Timestamp?;
          final tsB = b.data()['scheduledTime'] as Timestamp?;
          if (tsA == null || tsB == null) return 0;
          return tsA.compareTo(tsB);
        });

        // Find next upcoming medication whose scheduled time is strictly in the future
        Map<String, dynamic>? upcomingMed;
        for (final doc in schedDocs) {
          final data = doc.data();
          final ts = data['scheduledTime'] as Timestamp?;
          if (ts != null) {
            final t = ts.toDate();
            final todayTime = DateTime(now.year, now.month, now.day, t.hour, t.minute);
            if (todayTime.isAfter(now)) {
              upcomingMed = {...data, 'id': doc.id, 'scheduledTime': Timestamp.fromDate(todayTime)};
              break;
            }
          }
        }

        if (upcomingMed != null && _nextMed?['id'] != upcomingMed['id']) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _nextMed = upcomingMed);
          });
        } else if (upcomingMed == null && _nextMed != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _nextMed = null);
          });
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _todayLogsStream,
          builder: (context, logsSnap) {
            final allLogsDocs = logsSnap.data?.docs ?? [];
            final logs = allLogsDocs.where((doc) {
              final data = doc.data();
              final ts = data['timestamp'] as Timestamp?;
              if (ts == null) return false;
              final date = ts.toDate();
              return (date.isAfter(todayStart.subtract(const Duration(seconds: 1))) || date.isAtSameMomentAs(todayStart)) &&
                     date.isBefore(todayEnd);
            }).toList();

            final taken = logs.where((d) => d.data()['status'] == 'taken').length;
            final missed = logs.where((d) => d.data()['status'] == 'missed').length;
            final total = schedDocs.isEmpty ? 0 : schedDocs.length;
            final progress = total > 0 ? (taken / total).clamp(0.0, 1.0) : 0.0;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _compartmentsStream,
              builder: (context, compSnap) {
                final compDocs = compSnap.data?.docs ?? [];
                final lowStockCount = compDocs
                    .where((d) => (d.data()['stockCount'] as int? ?? 0) <= 3)
                    .length;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      if (lowStockCount > 0) ...[
                        _buildLowStockBanner(lowStockCount),
                        const SizedBox(height: 14),
                      ],
                      _buildDeviceStatusCard(),
                      const SizedBox(height: 20),
                      _buildNextMedCard(upcomingMed),
                      const SizedBox(height: 24),
                      _buildProgressSection(taken, missed, total, progress, lowStockCount),
                      const SizedBox(height: 24),
                      _buildQuickActions(total, compDocs.isEmpty ? 0 : compDocs.length),
                      const SizedBox(height: 20),
                      _buildEmergencyButton(),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

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
              widget.displayName,
              style: TextStyle(fontSize: 24, color: primaryTextColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: widget.onGoToAlerts,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: cardBgColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 10)]),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(LucideIcons.bell, color: primaryTextColor, size: 22),
                    if (widget.unreadCount > 0)
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
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.userInitials,
                  style: const TextStyle(color: Color(0xFF00A36C), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

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
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 20),
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

  Widget _buildDeviceStatusCard() {
    final isOnline = _deviceData?['isOnline'] as bool? ?? false;
    final battery = _deviceData?['batteryPercent'] as int? ?? 0;
    final model = _deviceData?['model'] as String? ?? 'SmartDose Dispenser';
    final lastSync = _deviceData?['lastSyncAt'] as Timestamp?;
    final syncStr = lastSync != null
        ? DateFormat('hh:mm a').format(lastSync.toDate())
        : (_deviceData == null ? 'Loading…' : 'Never synced');

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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 12, offset: const Offset(0, 4))],
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
              Icons.wifi_rounded,
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
                  _deviceData == null
                      ? 'Connecting…'
                      : (isOnline ? 'Online · Last sync $syncStr' : 'Offline · Last sync $syncStr'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? secondaryTextColor : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          // Direct Live Camera Feed button right on device card
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraFeedScreen()));
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
                  Icon(Icons.videocam_outlined, color: Color(0xFF00A36C), size: 16),
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

  Widget _buildNextMedCard(Map<String, dynamic>? med) {
    final ts = med?['scheduledTime'] as Timestamp?;
    final isUpcoming = med != null && ts != null && ts.toDate().isAfter(DateTime.now());

    final name = isUpcoming ? (med['medicationName'] ?? 'Medication') : 'No upcoming medications';
    final dosage = isUpcoming ? (med['dosage'] ?? '') : '';
    final comp = isUpcoming ? (med['compartment'] ?? '') : '';
    final timeStr = isUpcoming ? DateFormat('hh:mm a').format(ts.toDate()) : '';

    String countdownLabel = 'All clear';
    if (isUpcoming) {
      final diff = ts.toDate().difference(DateTime.now());
      countdownLabel = _formatCountdown(diff.isNegative ? Duration.zero : diff);
    }

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
              const Text('NEXT MEDICATION',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      countdownLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
                child: const Icon(Icons.medication_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (isUpcoming && (dosage.isNotEmpty || timeStr.isNotEmpty || comp.isNotEmpty))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          [if (dosage.isNotEmpty) dosage, if (timeStr.isNotEmpty) timeStr, if (comp.isNotEmpty) comp]
                              .join(' · '),
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      )
                    else if (!isUpcoming)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'No more doses scheduled for today',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // DO NOT SHOW DISPENSE NOW BUTTON WHEN THERE IS NO UPCOMING MEDICATION
          if (isUpcoming) ...[
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
                onPressed: () => _onDispenseNow(med),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Dispense now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

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
            : const Icon(Icons.notifications_active_outlined, size: 20),
        label: Text(
          _dispatchingEmergency ? 'Sending Emergency Request…' : 'Emergency Dispense',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

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
              onTap: widget.onGoToHistory,
              child: const Text('Details',
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
    final theme = Theme.of(context);
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: secondaryTextColor))),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTextColor)),
      ],
    );
  }

  Widget _buildQuickActions(int totalDoses, int compCount) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    final actions = [
      {
        'icon': Icons.calendar_month_outlined,
        'title': 'Schedule',
        'subtitle': '$totalDoses dose${totalDoses == 1 ? '' : 's'} today',
        'cb': widget.onGoToMeds,
      },
      {
        'icon': Icons.videocam_outlined,
        'title': 'Live Camera',
        'subtitle': 'Pi camera stream',
        'cb': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraFeedScreen())),
      },
      {
        'icon': Icons.access_time_rounded,
        'title': 'History',
        'subtitle': 'Dispensing logs',
        'cb': widget.onGoToHistory,
      },
      {
        'icon': Icons.inventory_2_outlined,
        'title': 'Inventory',
        'subtitle': '$compCount compartment${compCount == 1 ? '' : 's'}',
        'cb': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompartmentInventoryScreen())),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.35,
          children: actions.map((a) {
            return GestureDetector(
              onTap: a['cb'] as VoidCallback,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 4))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(a['icon'] as IconData, color: const Color(0xFF00A36C), size: 22),
                    ),
                    const SizedBox(height: 12),
                    Text(a['title'] as String,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTextColor)),
                    const SizedBox(height: 2),
                    Text(a['subtitle'] as String,
                        style: TextStyle(fontSize: 13, color: secondaryTextColor)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
