import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class CaregiverPatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback onTap;
  final VoidCallback? onScheduleTap;
  final VoidCallback? onCameraTap;

  const CaregiverPatientCard({
    super.key,
    required this.patient,
    required this.onTap,
    this.onScheduleTap,
    this.onCameraTap,
  });

  Widget _buildAvatar(String? photoUrl, String name) {
    const size = 54.0;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    if (photoUrl == null || photoUrl.trim().isEmpty) {
      return Text(
        initials,
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
      );
    }

    final trimmed = photoUrl.trim();

    if (trimmed.startsWith('data:image')) {
      try {
        final base64Str = trimmed.contains(',') ? trimmed.split(',').last : trimmed;
        final bytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: BorderRadius.circular(27),
          child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true),
        );
      } catch (_) {}
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Image.network(
          trimmed,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => Text(
            initials,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ),
      );
    }

    final file = File(trimmed);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => Text(
            initials,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ),
      );
    }

    return Text(
      initials,
      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    final name = (patient['patientName'] ?? patient['name'] ?? 'Patient').toString();
    final relationship = (patient['relationship'] ?? 'Relative').toString();
    final age = patient['age'] ?? 68;
    final isOnline = patient['isOnline'] as bool? ?? true;
    final adherence = (patient['adherence'] as num? ?? 94).toInt();
    final nextDose = (patient['nextDose'] ?? 'In 2h 15m · Metformin').toString();
    final needsAttention = patient['needsAttention'] as bool? ?? false;
    final photoUrl = patient['photoUrl'] as String?;

    const emerald = Color(0xFF00A36C);
    const amber = Color(0xFFF59E0B);
    const red = Color(0xFFEF4444);

    final statusColor = needsAttention
        ? red
        : (isOnline ? emerald : const Color(0xFF6B7280));
    final statusText = needsAttention
        ? 'Attention Needed'
        : (isOnline ? 'Online' : 'Offline');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: needsAttention
              ? red.withValues(alpha: 0.5)
              : (isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6)),
          width: needsAttention ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Avatar + Name + Online badge + Adherence Ring
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C882), Color(0xFF00A36C)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _buildAvatar(photoUrl, name),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardBgColor, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  relationship,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: emerald,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$age yrs · SmartDose M2',
                            style: TextStyle(fontSize: 13, color: secondaryTextColor),
                          ),
                        ],
                      ),
                    ),

                    // Adherence Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (adherence >= 85 ? emerald : amber).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$adherence%',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: adherence >= 85 ? emerald : amber,
                            ),
                          ),
                          Text(
                            'Adherence',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: adherence >= 85 ? emerald : amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Next dose banner row
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: emerald),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Next Dose: $nextDose',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                // Action buttons if callbacks provided
                if (onScheduleTap != null || onCameraTap != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (onScheduleTap != null)
                        Expanded(
                          child: SizedBox(
                            height: 38,
                            child: OutlinedButton.icon(
                              onPressed: onScheduleTap,
                              icon: const Icon(Icons.calendar_today_outlined, size: 15),
                              label: const Text('Schedule', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: theme.dividerColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      if (onScheduleTap != null && onCameraTap != null) const SizedBox(width: 8),
                      if (onCameraTap != null)
                        Expanded(
                          child: SizedBox(
                            height: 38,
                            child: ElevatedButton.icon(
                              onPressed: onCameraTap,
                              icon: const Icon(Icons.videocam_outlined, size: 16, color: Colors.white),
                              label: const Text('Live Camera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: emerald,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
