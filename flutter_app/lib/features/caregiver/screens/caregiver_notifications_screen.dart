import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CaregiverNotificationsScreen extends StatefulWidget {
  const CaregiverNotificationsScreen({super.key});

  @override
  State<CaregiverNotificationsScreen> createState() => _CaregiverNotificationsScreenState();
}

class _CaregiverNotificationsScreenState extends State<CaregiverNotificationsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _sampleAlerts = [
    {
      'id': 'alert-1',
      'title': 'Emergency Alert',
      'body': 'Maria Delgado triggered emergency dispense assistance request.',
      'type': 'emergency',
      'patientName': 'Maria Delgado',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 12)),
      'isRead': false,
    },
    {
      'id': 'alert-2',
      'title': 'Missed Dose Warning',
      'body': 'Elena Costa missed scheduled dose of Levothyroxine (50 mcg).',
      'type': 'missed',
      'patientName': 'Elena Costa',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
    },
    {
      'id': 'alert-3',
      'title': 'Low Medicine Stock',
      'body': 'Compartment 3 for João Ferreira has only 2 pills remaining.',
      'type': 'stock',
      'patientName': 'João Ferreira',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': true,
    },
    {
      'id': 'alert-4',
      'title': 'Device Offline',
      'body': 'SmartDose M2 unit for Robert Chen disconnected from Wi-Fi.',
      'type': 'device',
      'patientName': 'Robert Chen',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
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

    final uid = FirebaseAuth.instance.currentUser?.uid;

    final filteredAlerts = _sampleAlerts.where((alert) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Emergency') return alert['type'] == 'emergency';
      if (_selectedFilter == 'Missed') return alert['type'] == 'missed';
      if (_selectedFilter == 'Stock') return alert['type'] == 'stock';
      if (_selectedFilter == 'Device') return alert['type'] == 'device';
      return true;
    }).toList();

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
          'Notifications & Alerts',
          style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var a in _sampleAlerts) {
                  a['isRead'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: emerald, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['All', 'Emergency', 'Missed', 'Stock', 'Device'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: emerald,
                      backgroundColor: cardBgColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : primaryTextColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Notifications Stream / List
            if (filteredAlerts.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: secondaryTextColor.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text('No notifications found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryTextColor)),
                      const SizedBox(height: 4),
                      Text('You are all caught up!', style: TextStyle(fontSize: 13, color: secondaryTextColor)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Column(
                children: filteredAlerts.map((alert) {
                  final type = alert['type'] as String;
                  final isRead = alert['isRead'] as bool? ?? false;
                  final title = alert['title'] as String;
                  final body = alert['body'] as String;
                  final patientName = alert['patientName'] as String;
                  final dt = alert['timestamp'] as DateTime;

                  Color badgeColor = emerald;
                  IconData icon = Icons.notifications_active_outlined;

                  if (type == 'emergency') {
                    badgeColor = const Color(0xFFEF4444);
                    icon = Icons.error_outline_rounded;
                  } else if (type == 'missed') {
                    badgeColor = const Color(0xFFF59E0B);
                    icon = Icons.alarm_off_rounded;
                  } else if (type == 'stock') {
                    badgeColor = const Color(0xFF8B5CF6);
                    icon = Icons.inventory_2_outlined;
                  } else if (type == 'device') {
                    badgeColor = const Color(0xFF6B7280);
                    icon = Icons.wifi_off_rounded;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: !isRead
                            ? badgeColor.withValues(alpha: 0.4)
                            : (isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6)),
                        width: !isRead ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: badgeColor, size: 22),
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
                                      title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(dt),
                                    style: TextStyle(fontSize: 11, color: secondaryTextColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                body,
                                style: TextStyle(fontSize: 13, color: secondaryTextColor, height: 1.3),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF27272A) : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      patientName,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryTextColor),
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
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
