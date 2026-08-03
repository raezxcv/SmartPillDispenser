import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/theme_provider.dart';
import '../../pairing/screens/pair_caregiver_screen.dart';
import '../../pairing/screens/connected_caregivers_screen.dart';
import 'compartment_inventory_screen.dart';
import 'camera_feed_screen.dart';

class PatientProfileTab extends ConsumerStatefulWidget {
  final VoidCallback onSignOut;
  final String fallbackName;

  const PatientProfileTab({
    super.key,
    required this.onSignOut,
    required this.fallbackName,
  });

  @override
  ConsumerState<PatientProfileTab> createState() => _PatientProfileTabState();
}

class _PatientProfileTabState extends ConsumerState<PatientProfileTab> {
  bool _pushNotificationsEnabled = true;
  bool _smsToCaregiverEnabled = true;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? get _userProfileStream {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Future<void> _updatePreferences(String key, bool val) async {
    final uid = _uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'preferences.$key': val,
    });
  }

  void _showEditProfileSheet(Map<String, dynamic>? data) {
    final nameCtrl = TextEditingController(text: data?['name'] ?? widget.fallbackName);
    final phoneCtrl = TextEditingController(text: data?['phone'] ?? '');
    final dobCtrl = TextEditingController(text: data?['dob'] ?? '');
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textColor.withValues(alpha: 0.6)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF00A36C)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF00A36C)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: dobCtrl,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                hintText: 'YYYY-MM-DD',
                prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFF00A36C)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A36C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  elevation: 0,
                ),
                onPressed: () async {
                  final uid = _uid;
                  if (uid != null) {
                    await FirebaseFirestore.instance.collection('users').doc(uid).update({
                      'name': nameCtrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                      'dob': dobCtrl.text.trim(),
                    });
                  }
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: Color(0xFF00A36C),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    final cardBgColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final primaryTextColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userProfileStream,
      builder: (context, snapshot) {
        final userData = snapshot.data?.data();
        final name = userData?['name'] ?? widget.fallbackName;
        final phone = userData?['phone'] ?? '+351 912 004 118';
        final dob = userData?['dob'] ?? 'Not set';

        final initials = name.trim().isNotEmpty
            ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
            : 'MD';

        final prefs = userData?['preferences'] as Map<String, dynamic>?;
        if (prefs != null) {
          _pushNotificationsEnabled = prefs['pushNotifications'] ?? true;
          _smsToCaregiverEnabled = prefs['smsToCaregiver'] ?? true;
          if (prefs.containsKey('darkMode')) {
            final fsDark = prefs['darkMode'] as bool;
            if (fsDark != isDarkMode) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(themeModeProvider.notifier).syncFromFirestore(fsDark);
              });
            }
          }
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: primaryTextColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Account & device settings',
                style: TextStyle(
                  fontSize: 15,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 20),

              // User Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00C882), Color(0xFF00A36C)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'DOB: $dob · $phone',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF00A36C)),
                      onPressed: () => _showEditProfileSheet(userData),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Device & Monitoring Section
              Text(
                'Device & Monitoring',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileListTile(
                      icon: Icons.videocam_outlined,
                      title: 'Live Camera Feed',
                      subtitle: 'Visual check of pill tray',
                      showDivider: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CameraFeedScreen()),
                        );
                      },
                    ),
                    _buildProfileListTile(
                      icon: Icons.inventory_2_outlined,
                      title: 'Medicine Inventory',
                      subtitle: '10 compartments stock status',
                      showDivider: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CompartmentInventoryScreen()),
                        );
                      },
                    ),
                    _buildProfileListTile(
                      icon: Icons.developer_board_rounded,
                      title: 'About Device',
                      subtitle: 'SmartDose ESP32 · Firmware v2.4.1',
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Care Circle Section
              Text(
                'Care Circle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileListTile(
                      icon: Icons.qr_code_scanner_rounded,
                      title: 'Pair Caregiver via QR',
                      subtitle: 'Generate secure QR code for caregivers',
                      showDivider: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PairCaregiverScreen()),
                        );
                      },
                    ),
                    _buildProfileListTile(
                      icon: Icons.people_outline_rounded,
                      title: 'Connected Caregivers',
                      subtitle: 'Manage active caregiver access',
                      showDivider: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ConnectedCaregiversScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Preferences Section
              Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileSwitchTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Push Notifications',
                      subtitle: 'Dose reminders & alerts',
                      value: _pushNotificationsEnabled,
                      onChanged: (val) {
                        setState(() => _pushNotificationsEnabled = val);
                        _updatePreferences('pushNotifications', val);
                      },
                      showDivider: true,
                    ),
                    _buildProfileSwitchTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'SMS to Caregiver',
                      subtitle: phone,
                      value: _smsToCaregiverEnabled,
                      onChanged: (val) {
                        setState(() => _smsToCaregiverEnabled = val);
                        _updatePreferences('smsToCaregiver', val);
                      },
                      showDivider: true,
                    ),
                    _buildProfileSwitchTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      subtitle: 'Easier on the eyes at night',
                      value: isDarkMode,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).toggleTheme(val);
                        _updatePreferences('darkMode', val);
                      },
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  onPressed: widget.onSignOut,
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showDivider,
    VoidCallback? onTap,
  }) {
    final primaryTextColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B) : const Color(0xFFE6F7F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF00A36C), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: secondaryTextColor, size: 24),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 74,
            endIndent: 18,
            color: Theme.of(context).dividerColor,
          ),
      ],
    );
  }

  Widget _buildProfileSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showDivider,
  }) {
    final primaryTextColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = primaryTextColor.withValues(alpha: 0.65);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFE6F7F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF00A36C), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                activeTrackColor: const Color(0xFF00A36C),
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 74,
            endIndent: 18,
            color: Theme.of(context).dividerColor,
          ),
      ],
    );
  }
}
