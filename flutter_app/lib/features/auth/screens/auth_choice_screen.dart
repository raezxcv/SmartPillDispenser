import 'package:flutter/material.dart';

/// AuthChoiceScreen — Landing screen with staggered component animations.
class AuthChoiceScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final Future<void> Function() onGoogleSignIn;
  final Future<void> Function() onFacebookSignIn;

  const AuthChoiceScreen({
    super.key,
    required this.onLogin,
    required this.onSignup,
    required this.onGoogleSignIn,
    required this.onFacebookSignIn,
  });

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;

  // Staggered animations for each component
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _btnFade;
  late Animation<Offset> _btnSlide;
  late Animation<double> _socialFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoFade = _interval(0.0, 0.35);
    _logoSlide = _slideInterval(0.0, 0.40);
    _titleFade = _interval(0.20, 0.55);
    _titleSlide = _slideInterval(0.20, 0.55);
    _subtitleFade = _interval(0.35, 0.65);
    _btnFade = _interval(0.50, 0.80);
    _btnSlide = _slideInterval(0.50, 0.85);
    _socialFade = _interval(0.65, 1.0);

    _ctrl.forward();
  }

  Animation<double> _interval(double begin, double end) =>
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(begin, end, curve: Curves.easeOut),
      );

  Animation<Offset> _slideInterval(double begin, double end) =>
      Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(begin, end, curve: Curves.easeOutCubic),
        ),
      );

  Future<void> _tapGoogle() async {
    if (_isGoogleLoading || _isFacebookLoading) return;
    setState(() => _isGoogleLoading = true);
    try {
      await widget.onGoogleSignIn();
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _tapFacebook() async {
    if (_isGoogleLoading || _isFacebookLoading) return;
    setState(() => _isFacebookLoading = true);
    try {
      await widget.onFacebookSignIn();
    } finally {
      if (mounted) setState(() => _isFacebookLoading = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
              Color(0xFFC5F2DC),
              Color(0xFFE8F8F0),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const Spacer(),

                // Logo — staggered fade + slide
                FadeTransition(
                  opacity: _logoFade,
                  child: SlideTransition(
                    position: _logoSlide,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A36C),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00A36C).withValues(alpha: 0.3),
                            blurRadius: 26,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/Smart Pill Dispenser Logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title — staggered
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: const Text(
                      'Smart Pill Dispenser',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle — staggered
                FadeTransition(
                  opacity: _subtitleFade,
                  child: const Column(
                    children: [
                      Text(
                        'Your smart medication companion',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00A36C),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Sign in or create an account to manage your medication schedule effortlessly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Buttons — staggered
                FadeTransition(
                  opacity: _btnFade,
                  child: SlideTransition(
                    position: _btnSlide,
                    child: Column(
                      children: [
                        // Log in
                        _GradientButton(
                          text: 'Log in',
                          onPressed: widget.onLogin,
                        ),
                        const SizedBox(height: 14),

                        // Create an account
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: widget.onSignup,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF00A36C),
                              side: const BorderSide(
                                color: Color(0xFF00A36C),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Create an account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00A36C),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Social Section — staggered
                FadeTransition(
                  opacity: _socialFade,
                  child: Column(
                    children: [
                      // Divider
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                                color: Color(0xFFD1D5DB), thickness: 1),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'or sign in with',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                                color: Color(0xFFD1D5DB), thickness: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Social buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CircularSocialButton(
                            isLoading: _isGoogleLoading,
                            onTap: _tapGoogle,
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CustomPaint(painter: _GoogleLogoPainter()),
                            ),
                          ),
                          const SizedBox(width: 20),
                          _CircularSocialButton(
                            isLoading: _isFacebookLoading,
                            onTap: _tapFacebook,
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child:
                                  CustomPaint(painter: _FacebookLogoPainter()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _GradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed == null
            ? null
            : const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF00C882), Color(0xFF00A36C)],
              ),
        color: onPressed == null ? const Color(0xFFD1D5DB) : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: onPressed == null
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF00A36C).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

// ─── Circular Social Button ───────────────────────────────────────────────────

class _CircularSocialButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final Widget child;

  const _CircularSocialButton(
      {required this.isLoading, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Color(0xFF00A36C)),
                )
              : child,
        ),
      ),
    );
  }
}

// ─── Google SVG ───────────────────────────────────────────────────────────────

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48.0;
    canvas.scale(s, s);
    canvas.drawPath(
        Path()
          ..moveTo(43.611, 20.083)
          ..lineTo(24, 20)
          ..lineTo(24, 28)
          ..lineTo(35.303, 28)
          ..cubicTo(33.654, 32.657, 29.223, 36, 24, 36)
          ..cubicTo(17.373, 36, 12, 30.627, 12, 24)
          ..cubicTo(12, 17.373, 17.373, 12, 24, 12)
          ..cubicTo(27.059, 12, 29.842, 13.154, 31.961, 15.039)
          ..lineTo(37.618, 9.382)
          ..cubicTo(34.046, 6.053, 29.268, 4, 24, 4)
          ..cubicTo(12.955, 4, 4, 12.955, 4, 24)
          ..cubicTo(4, 35.045, 12.955, 44, 24, 44)
          ..cubicTo(35.045, 44, 44, 35.045, 44, 24)
          ..cubicTo(44, 22.659, 43.862, 21.35, 43.611, 20.083)
          ..close(),
        Paint()..color = const Color(0xFFFFC107));
    canvas.drawPath(
        Path()
          ..moveTo(6.306, 14.691)
          ..lineTo(12.877, 19.51)
          ..cubicTo(14.655, 15.108, 18.961, 12, 24, 12)
          ..cubicTo(27.059, 12, 29.842, 13.154, 31.961, 15.039)
          ..lineTo(37.618, 9.382)
          ..cubicTo(34.046, 6.053, 29.268, 4, 24, 4)
          ..cubicTo(16.318, 4, 9.656, 8.337, 6.306, 14.691)
          ..close(),
        Paint()..color = const Color(0xFFFF3D00));
    canvas.drawPath(
        Path()
          ..moveTo(24, 44)
          ..cubicTo(29.166, 44, 33.86, 42.023, 37.409, 38.808)
          ..lineTo(31.219, 33.57)
          ..cubicTo(29.211, 35.091, 26.715, 36, 24, 36)
          ..cubicTo(18.798, 36, 14.381, 32.683, 12.717, 28.054)
          ..lineTo(6.195, 33.079)
          ..cubicTo(9.505, 39.556, 16.227, 44, 24, 44)
          ..close(),
        Paint()..color = const Color(0xFF4CAF50));
    canvas.drawPath(
        Path()
          ..moveTo(43.611, 20.083)
          ..lineTo(24, 20)
          ..lineTo(24, 28)
          ..lineTo(35.303, 28)
          ..cubicTo(34.511, 30.237, 33.072, 32.166, 31.216, 33.571)
          ..lineTo(37.406, 38.809)
          ..cubicTo(36.971, 39.205, 44, 34, 44, 24)
          ..cubicTo(44, 22.659, 43.862, 21.35, 43.611, 20.083)
          ..close(),
        Paint()..color = const Color(0xFF1976D2));
  }

  @override
  bool shouldRepaint(CustomPainter _) => false;
}

// ─── Facebook SVG ─────────────────────────────────────────────────────────────

class _FacebookLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48.0;
    canvas.scale(s, s);
    canvas.drawPath(
        Path()..addOval(Rect.fromCircle(center: const Offset(24, 24), radius: 19)),
        Paint()..color = const Color(0xFF039BE5));
    canvas.drawPath(
        Path()
          ..moveTo(26.572, 29.036)
          ..lineTo(31.489, 29.036)
          ..lineTo(32.261, 24.041)
          ..lineTo(26.571, 24.041)
          ..lineTo(26.571, 21.311)
          ..cubicTo(26.571, 19.236, 27.249, 17.396, 29.19, 17.396)
          ..lineTo(32.309, 17.396)
          ..lineTo(32.309, 13.037)
          ..cubicTo(31.761, 12.963, 30.602, 12.801, 28.412, 12.801)
          ..cubicTo(23.839, 12.801, 21.158, 15.216, 21.158, 20.718)
          ..lineTo(21.158, 24.041)
          ..lineTo(16.457, 24.041)
          ..lineTo(16.457, 29.036)
          ..lineTo(21.158, 29.036)
          ..lineTo(21.158, 42.765)
          ..cubicTo(22.089, 42.905, 23.032, 43, 24, 43)
          ..cubicTo(24.875, 43, 25.729, 42.92, 26.572, 42.806)
          ..close(),
        Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter _) => false;
}
