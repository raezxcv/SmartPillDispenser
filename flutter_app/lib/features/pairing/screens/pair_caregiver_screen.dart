import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/pairing_service.dart';
import 'connection_requests_screen.dart';
import 'connected_caregivers_screen.dart';

class PairCaregiverScreen extends StatefulWidget {
  const PairCaregiverScreen({super.key});

  @override
  State<PairCaregiverScreen> createState() => _PairCaregiverScreenState();
}

class _PairCaregiverScreenState extends State<PairCaregiverScreen> {
  final PairingService _pairingService = PairingService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  final String _userName = FirebaseAuth.instance.currentUser?.displayName ?? 'Patient';
  final String _userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  PairingTokenModel? _currentToken;
  bool _isLoading = false;
  Timer? _timer;
  int _secondsRemaining = 600; // 10 minutes

  @override
  void initState() {
    super.initState();
    _generateNewToken();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 600;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTimer {
    final minutes = (_secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return 'Expires in $minutes:$seconds';
  }

  Future<void> _generateNewToken() async {
    final uid = _uid;
    if (uid == null) return;
    setState(() => _isLoading = true);

    try {
      final token = await _pairingService.generatePairingToken(
        patientUid: uid,
        patientName: _userName,
        patientEmail: _userEmail,
      );
      if (mounted) {
        setState(() {
          _currentToken = token;
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating QR code: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF10B981);
    final currentUid = _uid;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pair Caregiver',
          style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // Connection Requests Badge Action Button
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: currentUid != null ? _pairingService.getPendingRequestsStream(currentUid) : const Stream.empty(),
            builder: (context, snapshot) {
              final pendingCount = snapshot.data?.length ?? 0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_active_outlined, color: emerald, size: 26),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConnectionRequestsScreen()),
                      );
                    },
                    tooltip: 'Connection Requests',
                  ),
                  if (pendingCount > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$pendingCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title & Description
            Text(
              'Connect a Caregiver',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Generate a secure QR code that trusted family members can scan to connect to your account.',
              style: TextStyle(fontSize: 14, color: secondaryTextColor, height: 1.4),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Large Centered QR Code Card (24px rounded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_isLoading)
                    const SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(color: emerald),
                      ),
                    )
                  else if (_currentToken != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: emerald.withValues(alpha: 0.3), width: 2),
                      ),
                      child: QrImageView(
                        data: _currentToken!.qrPayload,
                        version: QrVersions.auto,
                        size: 200.0,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF047857),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pairing Code Box
                    Text(
                      'OR USE PAIRING CODE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: secondaryTextColor, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _currentToken!.pairingCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pairing code copied to clipboard!')),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentToken!.pairingCode,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.copy_rounded, size: 18, color: emerald),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Countdown Timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: _secondsRemaining < 60 ? Colors.redAccent : emerald,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _secondsRemaining > 0 ? _formattedTimer : 'Expired',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _secondsRemaining < 60 ? Colors.redAccent : emerald,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Button: Generate New QR Code
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _generateNewToken,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  'Generate New QR Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: emerald,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Button: View Connected Caregivers
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ConnectedCaregiversScreen()),
                  );
                },
                icon: const Icon(Icons.people_outline_rounded, color: emerald),
                label: const Text(
                  'View Connected Caregivers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: emerald),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: emerald, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Information Box explaining double approval safety
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: emerald.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: emerald, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'For your security, scanning this code will send a connection request. Only approved caregivers will gain access.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF065F46), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
