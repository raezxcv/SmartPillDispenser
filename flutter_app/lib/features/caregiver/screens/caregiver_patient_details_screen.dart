import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../widgets/adherence_ring_widget.dart';
import '../widgets/hardware_status_row.dart';
import 'caregiver_patient_schedule_screen.dart';
import 'caregiver_live_camera_screen.dart';
import 'caregiver_patient_history_screen.dart';

class CaregiverPatientDetailsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const CaregiverPatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<CaregiverPatientDetailsScreen> createState() => _CaregiverPatientDetailsScreenState();
}

class _CaregiverPatientDetailsScreenState extends State<CaregiverPatientDetailsScreen> {
  bool _dispatchingEmergency = false;

  void _triggerEmergencyDispense() async {
    setState(() => _dispatchingEmergency = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() => _dispatchingEmergency = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.emergency_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text('Emergency dispense triggered for ${widget.patientName}!'),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

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
        title: Text(
          widget.patientName,
          style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, size: 20),
            onPressed: () {},
            tooltip: 'Patient Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF00C882), Color(0xFF00A36C)]),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.patientName.isNotEmpty ? widget.patientName[0].toUpperCase() : 'P',
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: emerald,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBgColor, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patientName,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTextColor),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Age 68 · Relationship: Mother',
                          style: TextStyle(fontSize: 13, color: secondaryTextColor),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Online', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: emerald)),
                            ),
                            const SizedBox(width: 8),
                            Text('SmartDose M2', style: TextStyle(fontSize: 12, color: secondaryTextColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Adherence Ring & Today Progress Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const AdherenceRingWidget(
                    percentage: 94,
                    size: 96,
                    strokeWidth: 10,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Dose Progress',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTextColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '3 of 4 doses taken on time',
                          style: TextStyle(fontSize: 13, color: secondaryTextColor),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const LinearProgressIndicator(
                            value: 0.75,
                            minHeight: 8,
                            backgroundColor: Color(0xFFE5E7EB),
                            valueColor: AlwaysStoppedAnimation<Color>(emerald),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Next Scheduled Medication Highlight Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00C882), Color(0xFF00A36C)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: emerald.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'NEXT SCHEDULED DOSE',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('In 45m', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Metformin (500mg)', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('08:00 PM · Compartment 1 · Take after dinner', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions Grid
            Text('Patient Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTileButton(
                    icon: Icons.videocam_outlined,
                    label: 'Live Camera',
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CaregiverLiveCameraScreen(
                            patientId: widget.patientId,
                            patientName: widget.patientName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTileButton(
                    icon: Icons.calendar_today_rounded,
                    label: 'Med Schedule',
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CaregiverPatientScheduleScreen(
                            patientId: widget.patientId,
                            patientName: widget.patientName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTileButton(
                    icon: Icons.history_rounded,
                    label: 'History Timeline',
                    color: const Color(0xFF00A36C),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CaregiverPatientHistoryScreen(
                            patientId: widget.patientId,
                            patientName: widget.patientName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTileButton(
                    icon: Icons.notifications_active_outlined,
                    label: 'Emergency Dispense',
                    color: const Color(0xFFEF4444),
                    onTap: _dispatchingEmergency ? () {} : _triggerEmergencyDispense,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Hardware Status Section
            Text('Hardware Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
            const SizedBox(height: 12),

            const HardwareStatusRow(
              label: 'ESP32 Microcontroller',
              sublabel: 'Controls servo motors & sensors',
              icon: Icons.developer_board_rounded,
              isOnline: true,
              statusText: 'Connected',
            ),
            const HardwareStatusRow(
              label: 'Raspberry Pi Camera Host',
              sublabel: 'Video stream & AI face detection',
              icon: Icons.memory_rounded,
              isOnline: true,
              statusText: 'Connected',
            ),
            const HardwareStatusRow(
              label: 'Wi-Fi Network',
              sublabel: 'Signal strength: -62 dBm (Strong)',
              icon: Icons.wifi_rounded,
              isOnline: true,
              statusText: 'Online',
            ),
            const HardwareStatusRow(
              label: 'Tray Weight Sensor',
              sublabel: 'Detects pill removal accurately',
              icon: Icons.scale_rounded,
              isOnline: true,
              statusText: 'Clear',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
