import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartdose/shared/widgets/smartdose_loading.dart';

class CaregiverLiveCameraScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const CaregiverLiveCameraScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<CaregiverLiveCameraScreen> createState() => _CaregiverLiveCameraScreenState();
}

class _CaregiverLiveCameraScreenState extends State<CaregiverLiveCameraScreen> {
  bool _isCameraAvailable = true;
  bool _isMuted = false;
  bool _isTakingSnapshot = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    const emerald = Color(0xFF00A36C);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardBgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live Monitoring', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 17)),
            Text(widget.patientName, style: TextStyle(color: secondaryTextColor, fontSize: 12)),
          ],
        ),
        actions: [
          // Toggle offline state for demo/testing
          IconButton(
            icon: Icon(
              _isCameraAvailable ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              color: _isCameraAvailable ? emerald : const Color(0xFFEF4444),
            ),
            onPressed: () {
              setState(() => _isCameraAvailable = !_isCameraAvailable);
            },
            tooltip: 'Toggle Camera State',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Frame Viewfinder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      if (_isCameraAvailable) ...[
                        // Simulated Camera Feed (Dark gradient with grid overlay)
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.person_rounded, size: 84, color: Colors.white.withValues(alpha: 0.15)),
                              const Positioned(
                                bottom: 20,
                                child: Text(
                                  'SmartDose M2 · Dispenser Tray Feed',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // LIVE Badge Top Left
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                CircleAvatar(radius: 4, backgroundColor: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'LIVE',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Timestamp Top Right
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              DateFormat('HH:mm:ss').format(DateTime.now()),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Friendly Camera Unavailable Empty State Variant
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.videocam_off_rounded, color: Colors.white70, size: 38),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Camera is currently unavailable.',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Please check Wi-Fi connection and power cable.',
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton(
                                  onPressed: () => setState(() => _isCameraAvailable = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: emerald,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text('Retry Connection', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Controls Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCameraButton(
                    icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    label: _isMuted ? 'Muted' : 'Sound',
                    color: _isMuted ? const Color(0xFFEF4444) : emerald,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  _buildCameraButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Snapshot',
                    color: const Color(0xFF3B82F6),
                    isLoading: _isTakingSnapshot,
                    onTap: () async {
                      setState(() => _isTakingSnapshot = true);
                      await Future.delayed(const Duration(milliseconds: 600));
                      if (mounted) {
                        setState(() => _isTakingSnapshot = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Camera snapshot saved to gallery!'),
                            backgroundColor: Color(0xFF00A36C),
                          ),
                        );
                      }
                    },
                  ),
                  _buildCameraButton(
                    icon: Icons.fullscreen_rounded,
                    label: 'Fullscreen',
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Entering fullscreen view...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hardware Connection Info Card
            Text('Stream Info & Hardware', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Status', _isCameraAvailable ? 'Online (1080p @ 30fps)' : 'Disconnected', _isCameraAvailable ? emerald : const Color(0xFFEF4444)),
                  const Divider(height: 20),
                  _buildInfoRow('Latency', '48 ms', primaryTextColor),
                  const Divider(height: 20),
                  _buildInfoRow('Camera Device', 'Raspberry Pi Camera V2', primaryTextColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const SmartDoseLoading(size: 24)
                  : Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String val, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
        Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valColor)),
      ],
    );
  }
}
