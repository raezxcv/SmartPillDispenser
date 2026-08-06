import 'package:flutter/material.dart';

class CaregiverMedicationDetailsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final Map<String, dynamic> medication;

  const CaregiverMedicationDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.medication,
  });

  @override
  State<CaregiverMedicationDetailsScreen> createState() => _CaregiverMedicationDetailsScreenState();
}

class _CaregiverMedicationDetailsScreenState extends State<CaregiverMedicationDetailsScreen> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.medication['isEnabled'] as bool? ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = theme.colorScheme.onSurface;
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    const emerald = Color(0xFF00A36C);

    final medName = (widget.medication['medicationName'] ?? 'Medication').toString();
    final dosage = (widget.medication['dosage'] ?? '500 mg').toString();
    final compartment = (widget.medication['compartment'] ?? 'Compartment 1').toString();
    final time = (widget.medication['time'] ?? '08:00 AM').toString();
    final frequency = (widget.medication['frequency'] ?? 'Daily').toString();
    final notes = (widget.medication['notes'] ?? 'No special notes recorded.').toString();
    final startDate = (widget.medication['startDate'] ?? '2026-01-01').toString();
    final endDate = (widget.medication['endDate'] ?? '2026-12-31').toString();

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
          medName,
          style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: emerald),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening schedule editor...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Edit Medication',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C882), Color(0xFF00A36C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: emerald.withValues(alpha: 0.3),
                    blurRadius: 16,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          compartment,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Switch(
                        value: _isEnabled,
                        activeThumbColor: Colors.white,
                        activeTrackColor: Colors.white.withValues(alpha: 0.4),
                        onChanged: (val) => setState(() => _isEnabled = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(medName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('$dosage · $frequency', style: const TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Schedule Overview
            Text('Schedule & Dosage Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
            const SizedBox(height: 12),

            _buildDetailTile(
              icon: Icons.access_time_rounded,
              label: 'Scheduled Dispense Time',
              value: time,
              color: emerald,
            ),
            _buildDetailTile(
              icon: Icons.repeat_rounded,
              label: 'Frequency & Days',
              value: '$frequency (Mon, Tue, Wed, Thu, Fri, Sat, Sun)',
              color: const Color(0xFF3B82F6),
            ),
            _buildDetailTile(
              icon: Icons.grid_view_rounded,
              label: 'Dispenser Compartment',
              value: '$compartment (Tray Sensor Monitored)',
              color: const Color(0xFF8B5CF6),
            ),
            _buildDetailTile(
              icon: Icons.date_range_rounded,
              label: 'Prescription Duration',
              value: 'From $startDate to $endDate',
              color: const Color(0xFFF59E0B),
            ),

            const SizedBox(height: 20),

            // Doctor Notes
            Text('Doctor & Caregiver Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2_outlined, color: emerald, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notes,
                      style: TextStyle(fontSize: 14, color: primaryTextColor, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Emergency / Immediate Dispense Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Dispensing 1 dose of $medName now...'),
                      backgroundColor: emerald,
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: Text(
                  'Dispense 1 Dose Now to ${widget.patientName}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: emerald,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: secondaryTextColor)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryTextColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
