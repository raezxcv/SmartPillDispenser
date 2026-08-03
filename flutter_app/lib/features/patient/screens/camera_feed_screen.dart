import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraFeedScreen extends StatefulWidget {
  const CameraFeedScreen({super.key});

  @override
  State<CameraFeedScreen> createState() => _CameraFeedScreenState();
}

class _CameraFeedScreenState extends State<CameraFeedScreen> {
  Timer? _refreshTimer;
  Timer? _controlsTimer;
  DateTime _lastRefreshed = DateTime.now();
  bool _isCapturing = false;
  bool _isFullscreen = false;
  bool _showControls = true;
  String? _deviceId;
  Map<String, dynamic>? _deviceData;
  StreamSubscription? _deviceSub;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _initDeviceStream();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() => _lastRefreshed = DateTime.now());
    });
  }

  @override
  void dispose() {
    _exitFullscreen();
    _refreshTimer?.cancel();
    _controlsTimer?.cancel();
    _deviceSub?.cancel();
    super.dispose();
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _resetControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() {
      _isFullscreen = true;
      _showControls = true;
    });
    _resetControlsTimer();
  }

  void _exitFullscreen() {
    _controlsTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (mounted) {
      setState(() {
        _isFullscreen = false;
        _showControls = true;
      });
    }
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

  Future<void> _requestCapture() async {
    final uid = _uid;
    if (uid == null || _deviceId == null) return;
    setState(() => _isCapturing = true);
    try {
      await FirebaseFirestore.instance.collection('devices').doc(_deviceId).update({
        'cameraTrigger': {
          'requestedAt': FieldValue.serverTimestamp(),
          'requestedBy': uid,
        },
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.camera, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text('Capture request sent to Raspberry Pi Camera!',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: const Color(0xFF00A36C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _lastRefreshed = DateTime.now();
        });
      }
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? get _activityLogsStream {
    final uid = _uid;
    if (uid == null) return null;
    // Try dispensingLogs collection — returns null stream on permission error
    return FirebaseFirestore.instance
        .collection('dispensingLogs')
        .where('patientUid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .handleError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) return _buildFullscreenView();

    final cameraUrl = _deviceData?['latestSnapshotUrl'] as String?;
    final isOnline = _deviceData?['isOnline'] as bool? ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1F2937), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Live Camera Feed',
          style: GoogleFonts.manrope(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF00A36C), size: 20),
            onPressed: () => setState(() => _lastRefreshed = DateTime.now()),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── VIDEO BLOCK ───────────────────────────────────────────────────
          Container(
            height: 250,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Stream image (fills box)
                Positioned.fill(
                  child: cameraUrl != null && cameraUrl.isNotEmpty
                      ? Image.network(
                          '$cameraUrl?t=${_lastRefreshed.millisecondsSinceEpoch}',
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) => progress == null
                              ? child
                              : const Center(child: CircularProgressIndicator(color: Color(0xFF00A36C))),
                          errorBuilder: (_, __, ___) => _buildStreamPlaceholder(isOnline),
                        )
                      : _buildStreamPlaceholder(isOnline),
                ),

                // Top-left: LIVE badge
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE41E3F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: GoogleFonts.manrope(
                            color: Colors.white, fontSize: 11,
                            fontWeight: FontWeight.w900, letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top-right: Device status badge
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOnline ? LucideIcons.wifi : LucideIcons.wifiOff,
                          color: isOnline ? const Color(0xFF00C882) : Colors.grey,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isOnline ? 'Raspberry Pi · Online' : 'Standby',
                          style: GoogleFonts.manrope(
                            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom-left: Take Photo button
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: GestureDetector(
                    onTap: _isCapturing ? null : _requestCapture,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: _isCapturing
                            ? const Color(0xFF00A36C).withValues(alpha: 0.7)
                            : const Color(0xFF00A36C),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00A36C).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isCapturing
                              ? const SizedBox(
                                  width: 14, height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(LucideIcons.camera, size: 15, color: Colors.white),
                          const SizedBox(width: 7),
                          Text(
                            _isCapturing ? 'Capturing…' : 'Take Photo',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom-right: Fullscreen circular button
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: _enterFullscreen,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.maximize2,
                        color: Color(0xFF00A36C),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── ACTIVITY LOG HEADER ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Detection & Activity Logs',
                        style: GoogleFonts.manrope(
                          fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Patient detection, medicine intake & captures',
                        style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.activity, color: Color(0xFF00A36C), size: 22),
              ],
            ),
          ),

          // ─── REAL FIRESTORE ACTIVITY LOG LIST ──────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _activityLogsStream,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00A36C)),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                // Empty state — no fake data
                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.activity, size: 36, color: Color(0xFF00A36C)),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'No activity yet',
                            style: GoogleFonts.manrope(
                              fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Patient detections, medicine intake events, and camera captures will appear here in real-time.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF6B7280), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: docs.length,
                  itemBuilder: (_, i) => _buildActivityCard(docs[i].data()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── FULLSCREEN VIEW ───────────────────────────────────────────────────────
  Widget _buildFullscreenView() {
    final cameraUrl = _deviceData?['latestSnapshotUrl'] as String?;
    final isOnline = _deviceData?['isOnline'] as bool? ?? false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitFullscreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          child: SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full frame image / adaptive placeholder
                if (cameraUrl != null && cameraUrl.isNotEmpty)
                  Image.network(
                    '$cameraUrl?t=${_lastRefreshed.millisecondsSinceEpoch}',
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator(color: Color(0xFF00A36C))),
                    errorBuilder: (_, __, ___) => _buildStreamPlaceholder(isOnline),
                  )
                else
                  _buildStreamPlaceholder(isOnline),

                // Animated Overlay Controls (Auto fade-in / fade-out)
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_showControls,
                    child: Stack(
                      children: [
                        // Top-left: LIVE badge
                        Positioned(
                          top: 24,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE41E3F),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'LIVE',
                                  style: GoogleFonts.manrope(
                                    color: Colors.white, fontSize: 11,
                                    fontWeight: FontWeight.w900, letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom-left: Take Photo button (Matching normal view position)
                        Positioned(
                          bottom: 24,
                          left: 20,
                          child: GestureDetector(
                            onTap: () {
                              _resetControlsTimer();
                              if (!_isCapturing) _requestCapture();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                              decoration: BoxDecoration(
                                color: _isCapturing
                                    ? const Color(0xFF00A36C).withValues(alpha: 0.7)
                                    : const Color(0xFF00A36C),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _isCapturing
                                      ? const SizedBox(
                                          width: 16, height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Icon(LucideIcons.camera, size: 18, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isCapturing ? 'Capturing…' : 'Take Photo',
                                    style: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom-right: Minimize / Exit Fullscreen button (Matching normal view position)
                        Positioned(
                          bottom: 24,
                          right: 20,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _exitFullscreen,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                LucideIcons.minimize2,
                                color: Color(0xFF00A36C),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── ACTIVITY CARD ─────────────────────────────────────────────────────────
  Widget _buildActivityCard(Map<String, dynamic> item) {
    final name = item['medicationName'] as String? ?? 'Event';
    final desc = (item['desc'] as String?) ??
        (item['dosage'] != null ? '${item['dosage']} · Dispensed & verified' : '');
    final status = (item['status'] as String? ?? 'taken').toLowerCase();
    final type = item['type'] as String? ?? 'taken';
    final ts = item['timestamp'] as Timestamp?;
    final timeStr = ts != null ? DateFormat('hh:mm a').format(ts.toDate()) : 'Just now';
    final photoUrl = (item['capturedPhotoUrl'] ?? item['imageUrl']) as String?;

    Color badgeBg;
    Color badgeText;
    IconData icon;
    String badgeLabel;

    if (type == 'patient_detected' || status == 'detected') {
      badgeBg = const Color(0xFFDBEAFE);
      badgeText = const Color(0xFF1D4ED8);
      icon = LucideIcons.scanFace;
      badgeLabel = 'Patient Detected';
    } else if (type == 'photo_captured' || status == 'captured') {
      badgeBg = const Color(0xFFE0E7FF);
      badgeText = const Color(0xFF4338CA);
      icon = LucideIcons.camera;
      badgeLabel = 'Captured Image';
    } else if (status == 'missed') {
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = const Color(0xFFEF4444);
      icon = LucideIcons.xCircle;
      badgeLabel = 'Missed Dose';
    } else if (type == 'emergency') {
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = const Color(0xFFEF4444);
      icon = LucideIcons.siren;
      badgeLabel = 'Emergency';
    } else {
      badgeBg = const Color(0xFFD1FAE5);
      badgeText = const Color(0xFF059669);
      icon = LucideIcons.checkCircle;
      badgeLabel = 'Medicine Taken';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
            child: Icon(icon, color: badgeText, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                      ),
                    ),
                    Text(
                      timeStr,
                      style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF6B7280), height: 1.3),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        badgeLabel,
                        style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: badgeText),
                      ),
                    ),
                    if (photoUrl != null && photoUrl.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.image, size: 12, color: Color(0xFF4338CA)),
                            const SizedBox(width: 4),
                            Text(
                              'Photo Attached',
                              style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF4338CA), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STREAM PLACEHOLDER ────────────────────────────────────────────────────
  Widget _buildStreamPlaceholder(bool isOnline) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOnline
              ? const [
                  Color(0xFF0F172A),
                  Color(0xFF064E3B),
                  Color(0xFF022C22),
                ]
              : const [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFF00A36C).withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOnline
                      ? const Color(0xFF00A36C).withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.12),
                  width: 2,
                ),
                boxShadow: isOnline
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00A36C).withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                isOnline ? LucideIcons.video : LucideIcons.videoOff,
                size: 40,
                color: isOnline ? const Color(0xFF10B981) : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isOnline ? 'Raspberry Pi Camera Connected' : 'Camera Standby',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                isOnline
                    ? 'Streaming live patient monitoring feed from Raspberry Pi.'
                    : 'Waiting for camera connection or dispensing event trigger…',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
