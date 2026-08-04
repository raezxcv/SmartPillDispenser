import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'patient_home_tab.dart';
import 'patient_meds_tab.dart';
import 'patient_history_tab.dart';
import 'patient_alerts_tab.dart';
import 'patient_profile_tab.dart';

class PatientHomeScreen extends StatefulWidget {
  final String userName;
  final VoidCallback onSignOut;

  const PatientHomeScreen({
    super.key,
    this.userName = 'Maria Delgado',
    required this.onSignOut,
  });

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;
  int _unreadAlertsCount = 0;
  Map<String, dynamic>? _userFirestoreData;
  StreamSubscription? _userSub;
  StreamSubscription? _unreadSub;

  @override
  void initState() {
    super.initState();
    _listenToRealtimeUserData();
    _listenToUnreadNotifications();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _unreadSub?.cancel();
    super.dispose();
  }

  void _listenToRealtimeUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data() != null && mounted) {
        setState(() {
          _userFirestoreData = doc.data();
        });
      }
    });
  }

  void _listenToUnreadNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _unreadSub = FirebaseFirestore.instance
        .collection('notifications')
        .doc(user.uid)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _unreadAlertsCount = snapshot.docs.length;
        });
      }
    });
  }

  String get _displayName {
    if (_userFirestoreData != null &&
        _userFirestoreData!['name'] != null &&
        (_userFirestoreData!['name'] as String).trim().isNotEmpty) {
      return _userFirestoreData!['name'];
    }
    return widget.userName;
  }

  String get _userInitials {
    final name = _displayName.trim();
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'MD';
  }

  final List<int> _tabHistory = [0];

  void _switchTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
        _tabHistory.add(index);
      });
    }
  }

  Future<void> _markAllNotificationsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _unreadAlertsCount = 0);
      return;
    }

    final batch = FirebaseFirestore.instance.batch();
    final unreadDocs = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(user.uid)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadDocs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();

    if (mounted) {
      setState(() => _unreadAlertsCount = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read.'),
          backgroundColor: Color(0xFF00A36C),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_tabHistory.length > 1) {
          setState(() {
            _tabHistory.removeLast();
            _currentIndex = _tabHistory.last;
          });
        } else if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
            _tabHistory.clear();
            _tabHistory.add(0);
          });
        }
      },
      child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            PatientHomeTab(
              displayName: _displayName,
              userInitials: _userInitials,
              onGoToMeds: () => _switchTab(1),
              onGoToHistory: () => _switchTab(2),
              onGoToAlerts: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatientAlertsTab(onMarkAllRead: _markAllNotificationsRead),
                ),
              ),
              onGoToProfile: () => _switchTab(3),
              unreadCount: _unreadAlertsCount,
            ),
            const PatientMedsTab(),
            const PatientHistoryTab(),
            PatientProfileTab(
              fallbackName: _displayName,
              onSignOut: widget.onSignOut,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, LucideIcons.home, 'Home'),
            _buildNavItem(1, LucideIcons.calendar, 'Meds'),
            _buildNavItem(2, LucideIcons.history, 'History'),
            _buildNavItem(3, LucideIcons.user, 'Profile'),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildNavItem(int index, IconData icon, String label, {int badgeCount = 0}) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF00A36C);
    final unselectedColor = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final activePillColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);

    return InkWell(
      onTap: () => _switchTab(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? activePillColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? primaryColor : unselectedColor,
                    size: 22,
                  ),
                  if (badgeCount > 0 && index == 3)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.surface, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
