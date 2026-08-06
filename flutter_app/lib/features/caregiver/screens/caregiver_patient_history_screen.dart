import 'package:flutter/material.dart';

class CaregiverPatientHistoryScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const CaregiverPatientHistoryScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<CaregiverPatientHistoryScreen> createState() => _CaregiverPatientHistoryScreenState();
}

class _CaregiverPatientHistoryScreenState extends State<CaregiverPatientHistoryScreen> {
  String _selectedRange = 'This Week'; // This Week, This Month, All Time

  final List<Map<String, dynamic>> _historyLogs = [
    {
      'medicationName': 'Metformin',
      'dosage': '500 mg',
      'scheduledTime': '08:00 AM',
      'dispensedTime': '08:01 AM',
      'status': 'Taken',
      'date': 'Today',
      'faceVerified': true,
      'sensorConfirmed': true,
    },
    {
      'medicationName': 'Lisinopril',
      'dosage': '10 mg',
      'scheduledTime': '12:30 PM',
      'dispensedTime': '12:35 PM',
      'status': 'Taken',
      'date': 'Today',
      'faceVerified': true,
      'sensorConfirmed': true,
    },
    {
      'medicationName': 'Atorvastatin',
      'dosage': '20 mg',
      'scheduledTime': '09:00 PM',
      'dispensedTime': '09:45 PM',
      'status': 'Late',
      'date': 'Yesterday',
      'faceVerified': true,
      'sensorConfirmed': true,
    },
    {
      'medicationName': 'Metformin',
      'dosage': '500 mg',
      'scheduledTime': '08:00 AM',
      'dispensedTime': '—',
      'status': 'Missed',
      'date': '2 days ago',
      'faceVerified': false,
      'sensorConfirmed': false,
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
    const amber = Color(0xFFF59E0B);
    const red = Color(0xFFEF4444);

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
            Text('Medication History', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 17)),
            Text(widget.patientName, style: TextStyle(color: secondaryTextColor, fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Summary Row
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Weekly Rate',
                    value: '94%',
                    subtitle: '28 of 30 taken',
                    color: emerald,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Monthly Rate',
                    value: '91%',
                    subtitle: '110 of 120 taken',
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Timeline Header & Range Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dose Log Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRange,
                    dropdownColor: cardBgColor,
                    style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 13),
                    items: ['This Week', 'This Month', 'All Time']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRange = val);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Vertical Timeline List
            Column(
              children: _historyLogs.map((log) {
                final status = log['status'] as String;
                final isTaken = status == 'Taken';
                final isLate = status == 'Late';

                final statusColor = isTaken ? emerald : (isLate ? amber : red);
                final statusBg = statusColor.withValues(alpha: 0.12);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(log['date'], style: TextStyle(fontSize: 13, color: secondaryTextColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(10)),
                            child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(log['medicationName'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                      const SizedBox(height: 4),
                      Text('${log['dosage']} · Scheduled: ${log['scheduledTime']} · Dispensed: ${log['dispensedTime']}', style: TextStyle(fontSize: 13, color: secondaryTextColor)),

                      if (isTaken || isLate) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (log['faceVerified'] == true)
                              _buildChip('Face verified', Icons.face_rounded, emerald),
                            if (log['faceVerified'] == true) const SizedBox(width: 8),
                            if (log['sensorConfirmed'] == true)
                              _buildChip('Sensor confirmed', Icons.sensors_rounded, const Color(0xFF3B82F6)),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
