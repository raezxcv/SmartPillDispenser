import 'package:flutter/material.dart';

/// Signup Step 1 of 3 — "Choose your role"
/// Sliding card content for Step 1.
class SignupStep1Screen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(String role) onNext;
  final void Function(VoidCallback) onRegisterSubmit;

  const SignupStep1Screen({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onRegisterSubmit,
  });

  @override
  State<SignupStep1Screen> createState() => _SignupStep1ScreenState();
}

class _SignupStep1ScreenState extends State<SignupStep1Screen>
    with SingleTickerProviderStateMixin {
  String _selectedRole = 'patient';

  late AnimationController _ctrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _patientCardFade;
  late Animation<Offset> _patientCardSlide;
  late Animation<double> _caregiverCardFade;
  late Animation<Offset> _caregiverCardSlide;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _headerFade = _iv(0.0, 0.40);
    _headerSlide = _sv(0.0, 0.45);
    _patientCardFade = _iv(0.25, 0.65);
    _patientCardSlide = _sv(0.25, 0.65);
    _caregiverCardFade = _iv(0.45, 0.85);
    _caregiverCardSlide = _sv(0.45, 0.85);
    _buttonFade = _iv(0.60, 1.0);

    _ctrl.forward();

    // Register submit handler with the parent's fixed bottom bar
    widget.onRegisterSubmit(() => widget.onNext(_selectedRole));
  }

  Animation<double> _iv(double begin, double end) => CurvedAnimation(
        parent: _ctrl,
        curve: Interval(begin, end, curve: Curves.easeOut),
      );

  Animation<Offset> _sv(double begin, double end) =>
      Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(begin, end, curve: Curves.easeOutCubic),
        ),
      );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Header Title & Subtitle — Centered
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: const SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Choose your role',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Select your account type to personalize your experience.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 2. Patient Card
                  FadeTransition(
                    opacity: _patientCardFade,
                    child: SlideTransition(
                      position: _patientCardSlide,
                      child: _RoleSelectionCard(
                        title: 'Patient',
                        subtitle:
                            'I want to manage my own medication schedule, receive alerts, and track adherence.',
                        icon: Icons.person_rounded,
                        isSelected: _selectedRole == 'patient',
                        onTap: () => setState(() => _selectedRole = 'patient'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Caregiver Card
                  FadeTransition(
                    opacity: _caregiverCardFade,
                    child: SlideTransition(
                      position: _caregiverCardSlide,
                      child: _RoleSelectionCard(
                        title: 'Caregiver / Family',
                        subtitle:
                            'I manage or assist with medication schedules for a family member or patient.',
                        icon: Icons.favorite_rounded,
                        isSelected: _selectedRole == 'caregiver',
                        onTap: () => setState(() => _selectedRole = 'caregiver'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // "Already have an account?" login link
                  FadeTransition(
                    opacity: _buttonFade,
                    child: Center(
                      child: GestureDetector(
                        onTap: widget.onBack,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                            children: [
                              TextSpan(
                                text: 'Log in',
                                style: TextStyle(
                                  color: Color(0xFF00A36C),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoleSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleSelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF00A36C) : const Color(0xFFE5E7EB),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF00A36C).withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00A36C) : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? const Color(0xFF00A36C) : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00A36C) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF00A36C) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
            ),
          ],
        ),
      ),
    );
  }
}

