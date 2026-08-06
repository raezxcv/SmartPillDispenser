import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CaregiverReportsTab extends StatefulWidget {
  const CaregiverReportsTab({super.key});

  @override
  State<CaregiverReportsTab> createState() => _CaregiverReportsTabState();
}

class _CaregiverReportsTabState extends State<CaregiverReportsTab> {
  String _selectedPatient = 'Maria';

  final List<String> _patientNames = ['Maria', 'João', 'Elena'];

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
          // Header Row: Reports Title + Export Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: primaryTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adherence insights',
                    style: TextStyle(fontSize: 15, color: secondaryTextColor),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Exporting PDF report...'),
                      backgroundColor: emerald,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.download, size: 16, color: emerald),
                label: const Text(
                  'Export',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardBgColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Patient Filter Chips Row
          Row(
            children: _patientNames.map((name) {
              final isSelected = _selectedPatient == name;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPatient = name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? emerald : cardBgColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? emerald.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : primaryTextColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Weekly Adherence Section Card (Matching Image 4)
          Text('Weekly adherence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryTextColor)),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _WeeklyBar(day: 'Mon', percentage: 100),
                _WeeklyBar(day: 'Tue', percentage: 80),
                _WeeklyBar(day: 'Wed', percentage: 100),
                _WeeklyBar(day: 'Thu', percentage: 60),
                _WeeklyBar(day: 'Fri', percentage: 100),
                _WeeklyBar(day: 'Sat', percentage: 80),
                _WeeklyBar(day: 'Sun', percentage: 92),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Monthly Adherence Section Card (Matching Image 4)
          Text('Monthly adherence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryTextColor)),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _MonthlyCircle(week: 'W1', percentage: 88),
                _MonthlyCircle(week: 'W2', percentage: 94),
                _MonthlyCircle(week: 'W3', percentage: 79),
                _MonthlyCircle(week: 'W4', percentage: 92),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Missed Medications Section Card (Matching Image 4)
          Text('Missed medications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryTextColor)),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _MissedCup(label: 'W1', count: 3, fillRatio: 0.4),
                _MissedCup(label: 'W2', count: 1, fillRatio: 0.15),
                _MissedCup(label: 'W3', count: 5, fillRatio: 0.8),
                _MissedCup(label: 'W4', count: 2, fillRatio: 0.3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBar extends StatelessWidget {
  final String day;
  final int percentage;

  const _WeeklyBar({required this.day, required this.percentage});

  @override
  Widget build(BuildContext context) {
    const barHeight = 140.0;
    const barWidth = 28.0;
    const emerald = Color(0xFF00A36C);
    final theme = Theme.of(context);
    final secondaryTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.65);

    final filledHeight = barHeight * (percentage / 100);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$percentage%',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: secondaryTextColor),
        ),
        const SizedBox(height: 6),
        Container(
          width: barWidth,
          height: barHeight,
          decoration: BoxDecoration(
            color: emerald.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: barWidth,
            height: filledHeight,
            decoration: BoxDecoration(
              color: emerald,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: secondaryTextColor),
        ),
      ],
    );
  }
}

class _MonthlyCircle extends StatelessWidget {
  final String week;
  final int percentage;

  const _MonthlyCircle({required this.week, required this.percentage});

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF00A36C);
    final theme = Theme.of(context);
    final secondaryTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.65);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$percentage%',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: secondaryTextColor),
        ),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: emerald.withValues(alpha: 0.1),
              ),
            ),
            Container(
              width: 58 * (percentage / 100),
              height: 58 * (percentage / 100),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: emerald,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          week,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: secondaryTextColor),
        ),
      ],
    );
  }
}

class _MissedCup extends StatelessWidget {
  final String label;
  final int count;
  final double fillRatio;

  const _MissedCup({required this.label, required this.count, required this.fillRatio});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFEF4444);
    final theme = Theme.of(context);
    final secondaryTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.65);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: secondaryTextColor),
        ),
        const SizedBox(height: 6),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: red.withValues(alpha: 0.08),
          ),
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 54,
                height: 54 * fillRatio,
                color: red,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: secondaryTextColor),
        ),
      ],
    );
  }
}
