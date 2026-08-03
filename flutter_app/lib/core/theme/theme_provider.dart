import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String kDarkModePrefKey = 'darkMode';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(kDarkModePrefKey)) {
        final isDark = prefs.getBool(kDarkModePrefKey) ?? false;
        state = isDark ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (state == newMode) return;

    state = newMode;

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kDarkModePrefKey, isDark);
    } catch (e) {
      debugPrint('Error saving theme preference to SharedPreferences: $e');
    }

    // Sync to Firestore if authenticated
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
          'preferences': {'darkMode': isDark}
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error syncing theme preference to Firestore: $e');
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    await toggleTheme(isDark);
  }

  void syncFromFirestore(bool isDark) {
    final expectedMode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (state != expectedMode) {
      state = expectedMode;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool(kDarkModePrefKey, isDark);
      });
    }
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
