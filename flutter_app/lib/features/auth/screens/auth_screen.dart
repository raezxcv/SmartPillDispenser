import 'package:flutter/material.dart';
import '../providers/auth_service.dart';

/// AuthScreen — Login with staggered component animations.
class AuthScreen extends StatefulWidget {
  final Function(String role, String name) onLoginSuccess;
  final VoidCallback onGoToSignUp;
  final VoidCallback onBack;

  const AuthScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onGoToSignUp,
    required this.onBack,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final bool _isFacebookLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  late AnimationController _ctrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _fieldsFade;
  late Animation<Offset> _fieldsSlide;
  late Animation<double> _btnFade;
  late Animation<Offset> _btnSlide;
  late Animation<double> _socialFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _headerFade = _iv(0.0, 0.40);
    _headerSlide = _sv(0.0, 0.45);
    _fieldsFade = _iv(0.25, 0.60);
    _fieldsSlide = _sv(0.25, 0.65);
    _btnFade = _iv(0.50, 0.80);
    _btnSlide = _sv(0.50, 0.85);
    _socialFade = _iv(0.65, 1.0);

    _ctrl.forward();
  }

  Animation<double> _iv(double b, double e) => CurvedAnimation(
      parent: _ctrl, curve: Interval(b, e, curve: Curves.easeOut));

  Animation<Offset> _sv(double b, double e) =>
      Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: Interval(b, e, curve: Curves.easeOutCubic)));

  @override
  void dispose() {
    _ctrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final userData = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (userData != null) {
        widget.onLoginSuccess(userData['role'] ?? 'patient', userData['name'] ?? 'User');
      } else {
        setState(() => _errorMessage = 'User record not found.');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isGoogleLoading = true; _errorMessage = null; });
    try {
      final userData = await _authService.signInWithGoogle();
      if (userData != null) {
        widget.onLoginSuccess(userData['role'] ?? 'patient', userData['name'] ?? 'User');
      } else {
        setState(() => _errorMessage = 'Google sign-in was cancelled.');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _signInWithFacebook() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Facebook sign-in coming soon!'),
      backgroundColor: Color(0xFF1877F2),
    ));
  }

  void _showForgotPassword() {
    final emailCtrl = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Enter your email to receive a reset link.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 16),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'you@example.com',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFF00A36C), width: 2)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280)))),
          ElevatedButton(
            onPressed: () async {
              if (emailCtrl.text.contains('@')) {
                await _authService.sendPasswordReset(emailCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent!'), backgroundColor: Color(0xFF00A36C)));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A36C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('Send Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
            colors: [Color(0xFFC5F2DC), Color(0xFFE8F8F0), Color(0xFFFFFFFF)],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: const Icon(Icons.chevron_left_rounded, color: Color(0xFF1F2937), size: 26),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text('Smart Pill Dispenser',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Header: logo + title + subtitle — staggered
                        FadeTransition(
                          opacity: _headerFade,
                          child: SlideTransition(
                            position: _headerSlide,
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // App logo centered
                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00A36C),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00A36C).withValues(alpha: 0.28),
                                          blurRadius: 22,
                                          offset: const Offset(0, 8),
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
                                  const SizedBox(height: 20),
                                  const Text('Welcome back',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), letterSpacing: -0.5)),
                                  const SizedBox(height: 8),
                                  const Text('Sign in to keep your medication routine on track.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 15, color: Color(0xFF6B7280))),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Error banner
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFEF4444)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                              const SizedBox(width: 10),
                              Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13))),
                            ]),
                          ),

                        // Fields — staggered
                        FadeTransition(
                          opacity: _fieldsFade,
                          child: SlideTransition(
                            position: _fieldsSlide,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel(
                                  icon: Icons.email_rounded,
                                  label: 'EMAIL',
                                  required: true,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _pill('you@example.com'),
                                  validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                                ),
                                const SizedBox(height: 20),
                                const _FieldLabel(
                                  icon: Icons.lock_rounded,
                                  label: 'PASSWORD',
                                  required: true,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: _pill('••••••••').copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF6B7280), size: 22),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                                      child: Row(children: [
                                        Container(
                                          width: 22, height: 22,
                                          decoration: BoxDecoration(
                                            color: _rememberMe ? const Color(0xFF00A36C) : Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: _rememberMe ? const Color(0xFF00A36C) : const Color(0xFFD1D5DB), width: 1.5),
                                          ),
                                          child: _rememberMe ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('Remember me', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                                      ]),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: _showForgotPassword,
                                      child: const Text('Forgot password?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00A36C))),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Button — staggered
                        FadeTransition(
                          opacity: _btnFade,
                          child: SlideTransition(
                            position: _btnSlide,
                            child: _GradientButton(text: 'Log in', isLoading: _isLoading, onPressed: _signIn),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Social — staggered
                        FadeTransition(
                          opacity: _socialFade,
                          child: Column(
                            children: [
                              Row(children: [
                                const Expanded(child: Divider(color: Color(0xFFD1D5DB), thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Text('or sign in with', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                ),
                                const Expanded(child: Divider(color: Color(0xFFD1D5DB), thickness: 1)),
                              ]),
                              const SizedBox(height: 20),
                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                _CircularSocialButton(isLoading: _isGoogleLoading, onTap: _signInWithGoogle,
                                    child: SizedBox(width: 26, height: 26, child: CustomPaint(painter: _GoogleLogoPainter()))),
                                const SizedBox(width: 20),
                                _CircularSocialButton(isLoading: _isFacebookLoading, onTap: _signInWithFacebook,
                                    child: SizedBox(width: 26, height: 26, child: CustomPaint(painter: _FacebookLogoPainter()))),
                              ]),
                              const SizedBox(height: 32),
                              GestureDetector(
                                onTap: widget.onGoToSignUp,
                                child: RichText(text: const TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                                  children: [TextSpan(text: 'Create an account', style: TextStyle(color: Color(0xFF00A36C), fontWeight: FontWeight.bold))],
                                )),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _pill(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFF00A36C), width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFEF4444))),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
  );
}

// ─── Gradient Button ──────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _GradientButton({required this.text, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 56,
      decoration: BoxDecoration(
        gradient: isLoading ? null : const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF00C882), Color(0xFF00A36C)]),
        color: isLoading ? const Color(0xFFD1D5DB) : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: isLoading ? [] : [BoxShadow(color: const Color(0xFF00A36C).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _CircularSocialButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final Widget child;
  const _CircularSocialButton({required this.isLoading, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 58, height: 58,
        decoration: BoxDecoration(
          color: Colors.white, shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Center(child: isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF00A36C))) : child),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48.0;
    canvas.scale(s, s);
    canvas.drawPath(Path()..moveTo(43.611,20.083)..lineTo(24,20)..lineTo(24,28)..lineTo(35.303,28)..cubicTo(33.654,32.657,29.223,36,24,36)..cubicTo(17.373,36,12,30.627,12,24)..cubicTo(12,17.373,17.373,12,24,12)..cubicTo(27.059,12,29.842,13.154,31.961,15.039)..lineTo(37.618,9.382)..cubicTo(34.046,6.053,29.268,4,24,4)..cubicTo(12.955,4,4,12.955,4,24)..cubicTo(4,35.045,12.955,44,24,44)..cubicTo(35.045,44,44,35.045,44,24)..cubicTo(44,22.659,43.862,21.35,43.611,20.083)..close(), Paint()..color = const Color(0xFFFFC107));
    canvas.drawPath(Path()..moveTo(6.306,14.691)..lineTo(12.877,19.51)..cubicTo(14.655,15.108,18.961,12,24,12)..cubicTo(27.059,12,29.842,13.154,31.961,15.039)..lineTo(37.618,9.382)..cubicTo(34.046,6.053,29.268,4,24,4)..cubicTo(16.318,4,9.656,8.337,6.306,14.691)..close(), Paint()..color = const Color(0xFFFF3D00));
    canvas.drawPath(Path()..moveTo(24,44)..cubicTo(29.166,44,33.86,42.023,37.409,38.808)..lineTo(31.219,33.57)..cubicTo(29.211,35.091,26.715,36,24,36)..cubicTo(18.798,36,14.381,32.683,12.717,28.054)..lineTo(6.195,33.079)..cubicTo(9.505,39.556,16.227,44,24,44)..close(), Paint()..color = const Color(0xFF4CAF50));
    canvas.drawPath(Path()..moveTo(43.611,20.083)..lineTo(24,20)..lineTo(24,28)..lineTo(35.303,28)..cubicTo(34.511,30.237,33.072,32.166,31.216,33.571)..lineTo(37.406,38.809)..cubicTo(36.971,39.205,44,34,44,24)..cubicTo(44,22.659,43.862,21.35,43.611,20.083)..close(), Paint()..color = const Color(0xFF1976D2));
  }
  @override
  bool shouldRepaint(CustomPainter _) => false;
}

class _FacebookLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48.0;
    canvas.scale(s, s);
    canvas.drawPath(Path()..addOval(Rect.fromCircle(center: const Offset(24,24), radius: 19)), Paint()..color = const Color(0xFF039BE5));
    canvas.drawPath(Path()..moveTo(26.572,29.036)..lineTo(31.489,29.036)..lineTo(32.261,24.041)..lineTo(26.571,24.041)..lineTo(26.571,21.311)..cubicTo(26.571,19.236,27.249,17.396,29.19,17.396)..lineTo(32.309,17.396)..lineTo(32.309,13.037)..cubicTo(31.761,12.963,30.602,12.801,28.412,12.801)..cubicTo(23.839,12.801,21.158,15.216,21.158,20.718)..lineTo(21.158,24.041)..lineTo(16.457,24.041)..lineTo(16.457,29.036)..lineTo(21.158,29.036)..lineTo(21.158,42.765)..cubicTo(22.089,42.905,23.032,43,24,43)..cubicTo(24.875,43,25.729,42.92,26.572,42.806)..close(), Paint()..color = Colors.white);
  }
  @override
  bool shouldRepaint(CustomPainter _) => false;
}

// ─── Field Label with Icon ────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool required;

  const _FieldLabel({
    required this.icon,
    required this.label,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF00A36C)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6B7280),
            letterSpacing: 0.8,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFFEF4444),
            ),
          ),
        ],
      ],
    );
  }
}

