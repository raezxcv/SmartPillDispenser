import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/auth_choice_screen.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/screens/signup_step1_screen.dart';
import 'features/auth/screens/signup_step2_screen.dart';
import 'features/auth/screens/signup_step3_screen.dart';
import 'features/auth/providers/auth_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'features/patient/screens/patient_home_screen.dart';
import 'features/caregiver/screens/caregiver_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: SmartDoseApp()));
}
// ── Route helpers ─────────────────────────────────────────────────────────────



/// Fade — used for top-level auth transitions (splash, auth choice, login, dashboard)
Route<T> _fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 380),
    transitionsBuilder: (_, anim, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
      child: child,
    ),
  );
}

// ── App ───────────────────────────────────────────────────────────────────────

class SmartDoseApp extends ConsumerWidget {
  const SmartDoseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'SmartDose',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const _RootNavigator(),
    );
  }
}

// ── Root Navigator ────────────────────────────────────────────────────────────

class _RootNavigator extends StatefulWidget {
  const _RootNavigator();
  @override
  State<_RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<_RootNavigator> {
  final _navKey = GlobalKey<NavigatorState>();
  final _auth = AuthService();

  NavigatorState get _nav => _navKey.currentState!;

  // ── Routing helpers ───────────────────────────────────────────────────────

  void _pushDashboard(String role, String name) {
    final Widget dashboard = role == 'caregiver'
        ? CaregiverDashboardScreen(onSwitchRole: _signOut)
        : PatientHomeScreen(userName: name, onSignOut: _signOut);
    _nav.pushAndRemoveUntil(_fadeRoute(dashboard), (_) => false);
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    _nav.pushAndRemoveUntil(_fadeRoute(_buildAuthChoice()), (_) => false);
  }

  /// Persistent Auth Check: Automatically skip login if user has an active session
  Future<void> _checkInitialAuthSession() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final profile = await _auth.getUserProfile(currentUser.uid);
        final role = profile?['role'] ?? 'patient';
        final name = profile?['name'] ?? currentUser.displayName ?? 'User';
        _pushDashboard(role, name);
        return;
      } catch (e) {
        debugPrint('Error checking auth session: $e');
      }
    }
    _nav.pushReplacement(_fadeRoute(_buildLogin()));
  }

  // ── Screen builders ───────────────────────────────────────────────────────

  Widget _buildAuthChoice() => Theme(
        data: AppTheme.lightTheme,
        child: AuthChoiceScreen(
          onLogin: () => _nav.push(_fadeRoute(_buildLogin())),
          onSignup: () => _nav.push(
            // Fade in for the FIRST step (same entrance as login)
            _fadeRoute(_SignupFlow(onSuccess: _pushDashboard)),
          ),
          onGoogleSignIn: _handleGoogle,
          onFacebookSignIn: _handleFacebook,
        ),
      );

  Widget _buildLogin() => Theme(
        data: AppTheme.lightTheme,
        child: AuthScreen(
          onLoginSuccess: _pushDashboard,
          onGoToSignUp: () => _nav.push(
            _fadeRoute(_SignupFlow(onSuccess: _pushDashboard)),
          ),
          onBack: () => _nav.pop(),
        ),
      );

  // ── Google Sign-In ────────────────────────────────────────────────────────

  Future<void> _handleGoogle() async {
    try {
      final userData = await _auth.signInWithGoogle();
      if (userData == null) return;
      if (userData['role'] == 'new_google_user') {
        _nav.push(_fadeRoute(_SignupFlow(
          onSuccess: _pushDashboard,
          initialName: userData['name'] ?? '',
          initialEmail: userData['email'] ?? '',
          googleUid: userData['uid'],
          profilePhotoUrl: userData['profilePhotoUrl'],
        )));
      } else {
        _pushDashboard(
            userData['role'] ?? 'patient', userData['name'] ?? 'User');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    }
  }

  // ── Facebook Sign-In ──────────────────────────────────────────────────────

  Future<void> _handleFacebook() async {
    try {
      final userData = await _auth.signInWithFacebook();
      if (userData == null) return; // user cancelled
      if (userData['role'] == 'new_facebook_user') {
        // New Facebook user → pre-fill signup flow
        _nav.push(_fadeRoute(_SignupFlow(
          onSuccess: _pushDashboard,
          initialName: userData['name'] ?? '',
          initialEmail: userData['email'] ?? '',
          googleUid: userData['uid'], // reuse googleUid field for social uid
          profilePhotoUrl: userData['profilePhotoUrl'],
          authProvider: 'facebook',
        )));
      } else {
        _pushDashboard(
            userData['role'] ?? 'patient', userData['name'] ?? 'User');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) {
        if (_navKey.currentState?.canPop() ?? false) {
          _navKey.currentState?.pop();
        }
      },
      child: Navigator(
        key: _navKey,
        onGenerateInitialRoutes: (_, __) => [
          MaterialPageRoute(
            builder: (_) => SplashScreen(
              onFinish: _checkInitialAuthSession,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Self-contained 3-step Signup Flow ────────────────────────────────────────
// Uses a custom sliding page switcher so that BOTH the outgoing and incoming
// pages animate simultaneously (old exits left, new enters from right).
// The floating top bar stays completely fixed.

class _SignupFlow extends StatefulWidget {
  final void Function(String role, String name) onSuccess;
  final String initialName;
  final String initialEmail;
  final String? googleUid;
  final String? profilePhotoUrl;
  final String authProvider;

  const _SignupFlow({
    required this.onSuccess,
    this.initialName = '',
    this.initialEmail = '',
    this.googleUid,
    this.profilePhotoUrl,
    this.authProvider = 'google',
  });

  @override
  State<_SignupFlow> createState() => _SignupFlowState();
}

class _SignupFlowState extends State<_SignupFlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset> _incomingSlide;
  late Animation<Offset> _outgoingSlide;

  int _currentStep = 1;
  bool _isForward = true;
  bool _isAnimating = false;
  bool _isCreating = false;
  bool _isStepLoading = false;

  // Submit handler registered by the active step
  VoidCallback? _stepSubmit;

  // We keep both old and new page widgets to cross-animate them
  late Widget _currentPage;
  Widget? _previousPage;

  // Signup draft
  String _role = 'patient';
  late String _name;
  String _phone = '';
  String? _dob;
  String? _gender;
  String? _address;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
          _previousPage = null;
        });
      }
    });

    _buildTweens();
    _currentPage = _buildStep1();
  }

  void _buildTweens() {
    const curve = Curves.easeInOutCubic;
    if (_isForward) {
      _incomingSlide =
          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .animate(CurvedAnimation(parent: _slideCtrl, curve: curve));
      _outgoingSlide =
          Tween(begin: Offset.zero, end: const Offset(-1.0, 0.0))
              .animate(CurvedAnimation(parent: _slideCtrl, curve: curve));
    } else {
      _incomingSlide =
          Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
              .animate(CurvedAnimation(parent: _slideCtrl, curve: curve));
      _outgoingSlide =
          Tween(begin: Offset.zero, end: const Offset(1.0, 0.0))
              .animate(CurvedAnimation(parent: _slideCtrl, curve: curve));
    }
  }

  void _animateToPage(Widget newPage, {required bool forward}) {
    if (_isAnimating) return;
    setState(() {
      _isForward = forward;
      _buildTweens();
      _previousPage = _currentPage;
      _currentPage = newPage;
      _isAnimating = true;
      _stepSubmit = null;
    });
    _slideCtrl.forward(from: 0.0);
  }

  // Called by each step on initState to register its submit handler
  void _registerSubmit(VoidCallback fn) {
    // Use post-frame so it doesn't conflict with build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _stepSubmit = fn);
    });
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  // ── Step callbacks ─────────────────────────────────────────────────────────

  void _onStep1Done(String role) {
    _role = role;
    _currentStep = 2;
    _animateToPage(_buildStep2(), forward: true);
  }

  void _onStep2Done(
      String name, String phone, String? dob, String? gender, String? address) {
    _name = name;
    _phone = phone;
    _dob = dob;
    _gender = gender;
    _address = address;
    _currentStep = 3;
    _animateToPage(_buildStep3(), forward: true);
  }

  void _handleBack() {
    if (_isAnimating || _isCreating) return;
    if (_currentStep > 1) {
      _currentStep--;
      final Widget target =
          _currentStep == 1 ? _buildStep1() : _buildStep2();
      _animateToPage(target, forward: false);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onSignupSuccess(String role, String name) {
    setState(() {
      _isCreating = false;
      _isStepLoading = false;
      _currentStep = 4;
    });
    _animateToPage(_buildSuccessScreen(role, name), forward: true);
  }

  void _onCreatingChanged(bool creating) {
    if (mounted) {
      setState(() {
        _isCreating = creating;
        _isStepLoading = creating;
      });
    }
  }

  // ── Page builders ──────────────────────────────────────────────────────────

  Widget _buildStep1() => SignupStep1Screen(
        key: const ValueKey('step1'),
        onBack: _handleBack,
        onNext: _onStep1Done,
        onRegisterSubmit: _registerSubmit,
      );

  Widget _buildStep2() => SignupStep2Screen(
        key: const ValueKey('step2'),
        initialName: _name,
        onBack: _handleBack,
        onNext: _onStep2Done,
        onRegisterSubmit: _registerSubmit,
      );

  Widget _buildStep3() => SignupStep3Screen(
        key: const ValueKey('step3'),
        role: _role,
        name: _name,
        phone: _phone,
        dob: _dob,
        gender: _gender,
        address: _address,
        initialEmail: widget.initialEmail,
        googleUid: widget.googleUid,
        profilePhotoUrl: widget.profilePhotoUrl,
        onBack: _handleBack,
        onSignupSuccess: _onSignupSuccess,
        onCreatingChanged: _onCreatingChanged,
        onRegisterSubmit: _registerSubmit,
      );

  Widget _buildSuccessScreen(String role, String name) =>
      _SignupSuccessScreen(
        key: const ValueKey('success'),
        name: name,
        onContinue: () => widget.onSuccess(role, name),
      );

  @override
  Widget build(BuildContext context) {
    final bool showSteps = _currentStep <= 3;
    final int step = _currentStep.clamp(1, 3);
    final bool isLastStep = _currentStep == 3;

    return Theme(
      data: AppTheme.lightTheme,
      child: PopScope(
        canPop: _currentStep <= 1 && !_isCreating,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBack();
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF005837),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF005837),
                  Color(0xFF00754C),
                  Color(0xFF00905D),
                  Color(0xFF00A86E),
                ],
                stops: [0.0, 0.35, 0.70, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // ── Background Decor — Fixed ──────────────────────────────
                Positioned(
                  top: -30, right: -30,
                  child: Container(
                    width: 170, height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  top: 60, left: -40,
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  top: 30, right: 30,
                  child: Icon(LucideIcons.sparkles, size: 28,
                      color: Colors.white.withValues(alpha: 0.25)),
                ),
                Positioned(
                  top: 100, left: 24,
                  child: Icon(LucideIcons.shieldCheck, size: 26,
                      color: Colors.white.withValues(alpha: 0.22)),
                ),
                Positioned(
                  top: 160, right: 28,
                  child: Icon(LucideIcons.pill, size: 26,
                      color: Colors.white.withValues(alpha: 0.24)),
                ),

                // ── Main Content Layout ────────────────────────────────────
                Column(
                  children: [
                    // Compact Hero (smaller = more card space)
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.asset(
                                  'assets/Smart Dose Logo No Bg.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'SmartDose',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      'Your smart medication companion',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(alpha: 0.90),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // White Card — taller
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 24, offset: Offset(0, -6)),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Column(
                            children: [
                              // ── Numbered Step Indicator (fixed, never scrolls)
                              if (showSteps)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(32, 22, 32, 0),
                                  child: _StepIndicator(currentStep: step),
                                ),

                              // ── Scrollable step content ───────────────────
                              Expanded(
                                child: ClipRect(
                                  child: Stack(
                                    children: [
                                      if (_previousPage != null)
                                        SlideTransition(
                                          position: _outgoingSlide,
                                          child: _previousPage!,
                                        ),
                                      _isAnimating
                                          ? SlideTransition(
                                              position: _incomingSlide,
                                              child: _currentPage,
                                            )
                                          : _currentPage,
                                    ],
                                  ),
                                ),
                              ),

                              // ── Fixed Bottom Action Bar ──────────────────
                              if (showSteps)
                                Container(
                                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 12,
                                        offset: const Offset(0, -4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Back button (steps 2 & 3 only)
                                      if (_currentStep >= 2) ...[
                                        GestureDetector(
                                          onTap: (_isCreating || _isAnimating) ? null : _handleBack,
                                          child: AnimatedOpacity(
                                            duration: const Duration(milliseconds: 200),
                                            opacity: (_isCreating || _isAnimating) ? 0.35 : 1.0,
                                            child: Container(
                                              width: 52,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(0xFFE5E7EB),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.chevron_left_rounded,
                                                color: Color(0xFF374151),
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],

                                      // Continue / Create Account button
                                      Expanded(
                                        child: _isStepLoading
                                            ? Container(
                                                height: 52,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFD1D5DB),
                                                  borderRadius: BorderRadius.circular(26),
                                                ),
                                                child: const Center(
                                                  child: SizedBox(
                                                    width: 22, height: 22,
                                                    child: CircularProgressIndicator(
                                                        color: Colors.white, strokeWidth: 2.5),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                height: 52,
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [Color(0xFF00C882), Color(0xFF00A36C)],
                                                  ),
                                                  borderRadius: BorderRadius.circular(26),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xFF00A36C).withValues(alpha: 0.35),
                                                      blurRadius: 14,
                                                      offset: const Offset(0, 5),
                                                    ),
                                                  ],
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: _stepSubmit,
                                                    borderRadius: BorderRadius.circular(26),
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            isLastStep ? 'Create account' : 'Continue',
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w900,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Icon(
                                                            isLastStep
                                                                ? Icons.check_circle_rounded
                                                                : Icons.arrow_forward_rounded,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step Indicator Widget ─────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepCircle(stepNum: 1, currentStep: currentStep),
        _StepLine(isActive: currentStep >= 2),
        _StepCircle(stepNum: 2, currentStep: currentStep),
        _StepLine(isActive: currentStep >= 3),
        _StepCircle(stepNum: 3, currentStep: currentStep),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int stepNum;
  final int currentStep;
  const _StepCircle({required this.stepNum, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = currentStep > stepNum;
    final bool isCurrent = currentStep == stepNum;

    final Color bgColor = (isCompleted || isCurrent)
        ? const Color(0xFF00A36C)
        : const Color(0xFFE5E7EB);
    final Color textColor = (isCompleted || isCurrent) ? Colors.white : const Color(0xFF9CA3AF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: (isCompleted || isCurrent)
            ? [BoxShadow(color: const Color(0xFF00A36C).withValues(alpha: 0.30), blurRadius: 8, offset: const Offset(0, 3))]
            : [],
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : Text(
                '$stepNum',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;
  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00A36C) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ─── Signup Success Screen ────────────────────────────────────────────────────

class _SignupSuccessScreen extends StatefulWidget {
  final String name;
  final VoidCallback onContinue;

  const _SignupSuccessScreen({
    super.key,
    required this.name,
    required this.onContinue,
  });

  @override
  State<_SignupSuccessScreen> createState() => _SignupSuccessScreenState();
}

class _SignupSuccessScreenState extends State<_SignupSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _checkScale;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkScale = CurvedAnimation(
      parent: _checkCtrl,
      curve: Curves.elasticOut,
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOut,
    );

    // Check bounces in → then text fades in
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _checkCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated checkmark circle
            ScaleTransition(
              scale: _checkScale,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00C882), Color(0xFF00A36C)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF00A36C).withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Title & subtitle
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  const Text(
                    'Account Created!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome, ${widget.name}!\nYour account has been successfully created.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Continue button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C882), Color(0xFF00A36C)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00A36C)
                              .withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onContinue,
                        borderRadius: BorderRadius.circular(28),
                        child: const Center(
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
