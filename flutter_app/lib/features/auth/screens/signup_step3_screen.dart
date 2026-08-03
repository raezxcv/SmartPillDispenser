import 'package:flutter/material.dart';
import '../providers/auth_service.dart';

enum _PwStrength { weak, fair, strong, veryStrong }

_PwStrength _calcStrength(String pw) {
  if (pw.length < 6) return _PwStrength.weak;
  int score = 0;
  if (pw.length >= 8) score++;
  if (pw.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(pw)) score++;
  if (RegExp(r'[a-z]').hasMatch(pw)) score++;
  if (RegExp(r'[0-9]').hasMatch(pw)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) score++;
  if (score <= 2) return _PwStrength.weak;
  if (score <= 3) return _PwStrength.fair;
  if (score <= 4) return _PwStrength.strong;
  return _PwStrength.veryStrong;
}

extension _PwStrengthX on _PwStrength {
  String get label {
    switch (this) {
      case _PwStrength.weak: return 'Weak';
      case _PwStrength.fair: return 'Fair';
      case _PwStrength.strong: return 'Strong';
      case _PwStrength.veryStrong: return 'Very Strong';
    }
  }

  Color get color {
    switch (this) {
      case _PwStrength.weak: return const Color(0xFFEF4444);
      case _PwStrength.fair: return const Color(0xFFF97316);
      case _PwStrength.strong: return const Color(0xFF84CC16);
      case _PwStrength.veryStrong: return const Color(0xFF00A36C);
    }
  }
}

/// Signup Step 3 of 3 — "Account Credentials"
/// Stepper is rendered by the parent fixed header in main.dart.
class SignupStep3Screen extends StatefulWidget {
  final String role;
  final String name;
  final String phone;
  final String? dob;
  final String? gender;
  final String? address;
  final String initialEmail;
  final String? googleUid;
  final String? profilePhotoUrl;
  final VoidCallback onBack;
  final Function(String role, String name) onSignupSuccess;
  final ValueChanged<bool>? onCreatingChanged;
  final void Function(VoidCallback) onRegisterSubmit;

  const SignupStep3Screen({
    super.key,
    required this.role,
    required this.name,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.address,
    required this.initialEmail,
    this.googleUid,
    this.profilePhotoUrl,
    required this.onBack,
    required this.onSignupSuccess,
    this.onCreatingChanged,
    required this.onRegisterSubmit,
  });

  @override
  State<SignupStep3Screen> createState() => _SignupStep3ScreenState();
}

class _SignupStep3ScreenState extends State<SignupStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = true;
  String? _errorMessage;
  _PwStrength? _pwStrength;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    // Register submit handler with the parent's fixed bottom bar
    widget.onRegisterSubmit(_submitRegistration);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String pw) {
    setState(() => _pwStrength = pw.isEmpty ? null : _calcStrength(pw));
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      setState(() => _errorMessage = 'Please agree to the Terms and Privacy Policy.');
      return;
    }

    if (widget.googleUid == null) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() => _errorMessage = 'Passwords do not match.');
        return;
      }
    }

    setState(() => _errorMessage = null);
    widget.onCreatingChanged?.call(true);

    try {
      String? error;
      if (widget.googleUid != null) {
        error = await _authService.completeGoogleUserProfile(
          uid: widget.googleUid!,
          name: widget.name,
          email: _emailController.text.trim(),
          role: widget.role,
          phone: widget.phone,
          dateOfBirth: widget.dob,
          gender: widget.gender,
          address: widget.address,
          profilePhotoUrl: widget.profilePhotoUrl,
        );
      } else {
        error = await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: widget.name,
          role: widget.role,
          phone: widget.phone,
          dateOfBirth: widget.dob,
          gender: widget.gender,
          address: widget.address,
        );
      }

      if (error != null) {
        setState(() => _errorMessage = error);
        widget.onCreatingChanged?.call(false);
      } else {
        widget.onSignupSuccess(widget.role, widget.name);
      }
    } catch (e) {
      final msg = e.toString();
      setState(() => _errorMessage = msg.startsWith('Exception: ') ? msg.substring(11) : msg);
      widget.onCreatingChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isGoogleUser = widget.googleUid != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title & Subtitle
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Account Credentials',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1F2937),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isGoogleUser
                                ? 'Verify your email to complete registration.'
                                : 'Set up your account login credentials.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Error banner
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEF4444)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(_errorMessage!,
                                  style: const TextStyle(
                                      color: Color(0xFFB91C1C), fontSize: 13, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // EMAIL
                    const _FieldLabel(icon: Icons.email_rounded, label: 'EMAIL', required: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: isGoogleUser,
                      style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.w700),
                      decoration: _pillDecoration('you@example.com'),
                      validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                    ),

                    if (!isGoogleUser) ...[
                      const SizedBox(height: 18),

                      // PASSWORD
                      const _FieldLabel(icon: Icons.lock_rounded, label: 'PASSWORD', required: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: _onPasswordChanged,
                        style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.w700),
                        decoration: _pillDecoration('At least 8 characters').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: const Color(0xFF6B7280), size: 22),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 8) return 'Password must be at least 8 characters';
                          if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Add at least one uppercase letter';
                          if (!RegExp(r'[0-9]').hasMatch(v)) return 'Add at least one number';
                          return null;
                        },
                      ),

                      if (_pwStrength != null) ...[
                        const SizedBox(height: 10),
                        _PasswordStrengthBar(strength: _pwStrength!),
                      ],

                      const SizedBox(height: 18),

                      // CONFIRM PASSWORD
                      const _FieldLabel(icon: Icons.lock_reset_rounded, label: 'CONFIRM PASSWORD', required: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.w700),
                        decoration: _pillDecoration('Repeat your password').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: const Color(0xFF6B7280), size: 22),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm password';
                          if (v != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 22),

                    // Terms Checkbox
                    GestureDetector(
                      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _agreedToTerms ? const Color(0xFF00A36C) : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: _agreedToTerms ? const Color(0xFF00A36C) : const Color(0xFFD1D5DB),
                                  width: 1.5),
                            ),
                            child: _agreedToTerms
                                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                text: 'I agree to the ',
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xFF374151), fontWeight: FontWeight.w600),
                                children: [
                                  TextSpan(
                                      text: 'Terms',
                                      style: TextStyle(
                                          color: Color(0xFF00A36C), fontWeight: FontWeight.w900)),
                                  TextSpan(text: ' and '),
                                  TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                          color: Color(0xFF00A36C), fontWeight: FontWeight.w900)),
                                  TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _pillDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFF00A36C), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFEF4444))),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
      );
}

class _PasswordStrengthBar extends StatelessWidget {
  final _PwStrength strength;
  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(builder: (_, constraints) {
          const gap = 4.0;
          final segW = (constraints.maxWidth - gap * 3) / 4;
          return Row(
            children: List.generate(4, (i) {
              final filled = i < (strength.index + 1);
              return Padding(
                padding: EdgeInsets.only(right: i < 3 ? gap : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  width: segW,
                  height: 5,
                  decoration: BoxDecoration(
                    color: filled ? strength.color : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          );
        }),
        const SizedBox(height: 5),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Row(
            key: ValueKey(strength),
            children: [
              const Text('Password strength: ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              Text(strength.label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: strength.color)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool required;

  const _FieldLabel({required this.icon, required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF00A36C)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF6B7280), letterSpacing: 0.8)),
        if (required) ...[
          const SizedBox(width: 3),
          const Text('*', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
        ],
      ],
    );
  }
}

