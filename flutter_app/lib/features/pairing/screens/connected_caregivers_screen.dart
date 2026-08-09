import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/pairing_service.dart';
import '../../dashboard/screens/alerts_tab.dart';
import 'package:smartdose/shared/widgets/smartdose_loading.dart';

class ConnectedCaregiversScreen extends StatefulWidget {
  const ConnectedCaregiversScreen({super.key});

  @override
  State<ConnectedCaregiversScreen> createState() => _ConnectedCaregiversScreenState();
}

class _ConnectedCaregiversScreenState extends State<ConnectedCaregiversScreen> {
  final PairingService _pairingService = PairingService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  void _showCaregiverDetails(Map<String, dynamic> caregiver) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFECFDF5),
                child: Text(
                  (caregiver['caregiverName'] ?? 'C')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                caregiver['caregiverName'] ?? 'Caregiver',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              Text(
                caregiver['caregiverEmail'] ?? '',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.people_outline_rounded, color: Color(0xFF10B981)),
                title: const Text('Relationship'),
                subtitle: Text(caregiver['relationship'] ?? 'Family Member'),
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined, color: Color(0xFF10B981)),
                title: const Text('Caregiver Status'),
                subtitle: Text(caregiver['role'] ?? 'Primary Caregiver'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showChangeRoleDialog(String pairingId, String currentRole) {
    String selectedRole = currentRole;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Change Caregiver Role'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Primary Caregiver'),
                    subtitle: const Text('Full access to dispenser schedules & alerts'),
                    value: 'Primary Caregiver',
                    groupValue: selectedRole,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setDialogState(() => selectedRole = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Family Member'),
                    subtitle: const Text('View-only adherence status'),
                    value: 'Family Member',
                    groupValue: selectedRole,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setDialogState(() => selectedRole = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _pairingService.updateCaregiverRole(pairingId, selectedRole);
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Caregiver role updated successfully!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmRemoveCaregiver(String pairingId, String caregiverName) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Remove Caregiver?'),
          content: Text('Are you sure you want to remove $caregiverName? They will lose access to your pill dispenser status.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              onPressed: () async {
                await _pairingService.removePairing(pairingId);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$caregiverName access removed.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF10B981);

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
          'Connected Caregivers',
          style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.bell, color: primaryTextColor, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PatientAlertsTab()),
              );
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: _uid == null
          ? const Center(child: Text('Please log in first'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _pairingService.getConnectedCaregiversStream(_uid!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: SmartDoseLoading(size: 80));
                }

                final caregivers = snapshot.data ?? [];
                if (caregivers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.people_outline_rounded, color: emerald, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Caregivers Connected',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Generate a QR code from the Pair Caregiver screen to connect a caregiver.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: secondaryTextColor),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: caregivers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final c = caregivers[index];
                    final pairingId = c['pairingId'];
                    final caregiverName = c['caregiverName'] ?? 'Caregiver';
                    final relationship = c['relationship'] ?? 'Family Member';
                    final role = c['role'] ?? 'Primary Caregiver';
                    final lastActive = c['lastActive'];

                    String lastActiveStr = 'Active today';
                    if (lastActive != null) {
                      try {
                        final dt = lastActive.toDate();
                        lastActiveStr = 'Last active ${DateFormat('MMM d, h:mm a').format(dt)}';
                      } catch (_) {}
                    }

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                                child: Text(
                                  caregiverName[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: emerald),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      caregiverName,
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryTextColor),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$relationship · $lastActiveStr',
                                      style: TextStyle(fontSize: 13, color: secondaryTextColor),
                                    ),
                                  ],
                                ),
                              ),

                              // Popup Menu Actions
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF9CA3AF)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                onSelected: (value) {
                                  if (value == 'details') {
                                    _showCaregiverDetails(c);
                                  } else if (value == 'role') {
                                    _showChangeRoleDialog(pairingId, role);
                                  } else if (value == 'remove') {
                                    _confirmRemoveCaregiver(pairingId, caregiverName);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'details',
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF4B5563)),
                                        SizedBox(width: 10),
                                        Text('View Details'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'role',
                                    child: Row(
                                      children: [
                                        Icon(Icons.badge_outlined, size: 20, color: Color(0xFF4B5563)),
                                        SizedBox(width: 10),
                                        Text('Change Role'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(Icons.person_remove_outlined, size: 20, color: Colors.redAccent),
                                        SizedBox(width: 10),
                                        Text('Remove Access', style: TextStyle(color: Colors.redAccent)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Chip(
                                label: Text(role, style: const TextStyle(color: Color(0xFF047857), fontSize: 12, fontWeight: FontWeight.bold)),
                                backgroundColor: const Color(0xFFECFDF5),
                                padding: EdgeInsets.zero,
                                side: BorderSide.none,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
