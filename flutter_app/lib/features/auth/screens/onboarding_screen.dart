import 'package:flutter/material.dart';

/// OnboardingScreen — 3-step carousel matching reference UI.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const OnboardingScreen({
    super.key,
    required this.onFinish,
    required this.onSkip,
    required this.onBack,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingStep> _steps = const [
    _OnboardingStep(
      stepNumber: 1,
      title: 'Automated dispensing',
      description:
          'Your dispenser releases the exact pill from the right compartment, exactly on schedule.',
      icon: Icons.medication_liquid_rounded,
      useLogo: true,
    ),
    _OnboardingStep(
      stepNumber: 2,
      title: 'Gentle reminders',
      description:
          'Get timely notifications on your smartphone and audible chimes on the dispenser unit.',
      icon: Icons.notifications_active_rounded,
      useLogo: false,
    ),
    _OnboardingStep(
      stepNumber: 3,
      title: 'Caregiver alerts',
      description:
          'Keep family and caregivers notified of adherence and emergency missed doses.',
      icon: Icons.favorite_rounded,
      useLogo: false,
    ),
  ];

  void _nextPage() {
    if (_currentIndex < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onFinish();
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onBack();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentIndex + 1) / _steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Back Circular Button
                  GestureDetector(
                    onTap: _previousPage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFF1F2937),
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Center Linear Progress Bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF00A36C)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Skip Button -> Redirects to Auth Choice Screen
                  GestureDetector(
                    onTap: widget.onSkip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Main Content Area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // STEP X OF 3 Label
                        Text(
                          'STEP ${step.stepNumber} OF ${_steps.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00A36C),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Title
                        const Text(
                          'Smart Pill Dispenser',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1F2937),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle
                        const Text(
                          "Here's what your dispenser does for you.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Center Elevated Card
                        Expanded(
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxHeight: 380),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 36,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Green Icon Circle Badge with Circular Cropped Logo
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00A36C),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: step.useLogo
                                          ? ClipOval(
                                              child: Image.asset(
                                                'assets/Smart Pill Dispenser Logo.png',
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              ),
                                            )
                                          : Icon(
                                              step.icon,
                                              size: 46,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Step Title
                                  Text(
                                    step.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Step Description
                                  Text(
                                    step.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.45,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Page Dots Indicator
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _steps.length,
                            (idx) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentIndex == idx ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentIndex == idx
                                    ? const Color(0xFF00A36C)
                                    : const Color(0xFFD1D5DB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Full-Width Continue / Get Started Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A36C),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    _currentIndex == _steps.length - 1
                        ? 'Get Started'
                        : 'Continue',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final int stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final bool useLogo;

  const _OnboardingStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.useLogo,
  });
}
