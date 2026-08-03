import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// WelcomeScreen — Centered intro screen with entrance animations and green gradient.
class WelcomeScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00B074),
              Color(0xFF008E5D),
              Color(0xFF00754C),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Center Circular Cropped Logo Badge
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/Smart Dose Logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Name Title
                    Text(
                      'SmartDose',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle: Your smart medication companion
                    const Text(
                      'Your smart medication companion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Pairs with your physical smart dispenser to release the right pill, at the right time — keeping your care circle in the loop.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 3 Centered Feature Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCompactPill(LucideIcons.pill, 'Dispensing'),
                        const SizedBox(width: 8),
                        _buildCompactPill(LucideIcons.bell, 'Reminders'),
                        const SizedBox(width: 8),
                        _buildCompactPill(LucideIcons.heart, 'Caregiver'),
                      ],
                    ),

                    const Spacer(),

                    // Get Started Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: widget.onGetStarted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00A36C),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: const Text(
                          'Get started',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00A36C),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Privacy Note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.shieldCheck,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your health data stays private',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
