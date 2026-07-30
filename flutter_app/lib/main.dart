import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/auth_choice_screen.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/screens/signup_step1_screen.dart';
import 'features/auth/screens/signup_step2_screen.dart';
import 'features/auth/screens/signup_step3_screen.dart';
import 'features/auth/providers/auth_service.dart';
import 'features/patient/screens/patient_home_screen.dart';
import 'features/caregiver/screens/caregiver_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: SmartPillDispenserApp()));
}

// ── Route helpers ─────────────────────────────────────────────────────────────

/// Slide right→left (forward between signup steps).
/// When popped, Flutter automatically reverses to left→right.
Route<T> _slideForwardRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (_, anim, __, child) {
      // forward: slide in from right (right→left)
      // reverse (pop): slide out to right (left→right) — automatic
      final tween = Tween(begin: const Offset(1.0, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: anim.drive(tween), child: child);
    },
  );
}

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

class SmartPillDispenserApp extends StatelessWidget {
  const SmartPillDispenserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pill Dispenser',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
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

  // ── Screen builders ───────────────────────────────────────────────────────

  Widget _buildAuthChoice() => AuthChoiceScreen(
        onLogin: () => _nav.push(_fadeRoute(_buildLogin())),
        onSignup: () => _nav.push(
          // Fade in for the FIRST step (same entrance as login)
          _fadeRoute(_SignupFlow(onSuccess: _pushDashboard)),
        ),
        onGoogleSignIn: _handleGoogle,
        onFacebookSignIn: _handleFacebook,
      );

  Widget _buildLogin() => AuthScreen(
        onLoginSuccess: _pushDashboard,
        onGoToSignUp: () => _nav.push(
          _fadeRoute(_SignupFlow(onSuccess: _pushDashboard)),
        ),
        onBack: () => _nav.pop(),
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
              onFinish: () =>
                  _nav.pushReplacement(_fadeRoute(_buildAuthChoice())),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Self-contained 3-step Signup Flow ────────────────────────────────────────
// Uses its own nested Navigator so step-to-step slides (right→left / left→right)
// are isolated from the outer Navigator.
// The outer Navigator pushes this widget with a FADE route so step 1's entrance
// matches the login screen. Steps 2 and 3 slide right→left; back slides left→right.

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

class _SignupFlowState extends State<_SignupFlow> {
  final _flowKey = GlobalKey<NavigatorState>();
  NavigatorState get _flow => _flowKey.currentState!;

  int _currentStep = 1;

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
  }

  void _onStep1Done(String role) {
    _role = role;
    setState(() => _currentStep = 2);
    // Step 1 → 2: slide right→left
    _flow.push(_slideForwardRoute(_buildStep2()));
  }

  void _onStep2Done(
      String name, String phone, String? dob, String? gender, String? address) {
    _name = name;
    _phone = phone;
    _dob = dob;
    _gender = gender;
    _address = address;
    setState(() => _currentStep = 3);
    // Step 2 → 3: slide right→left
    _flow.push(_slideForwardRoute(_buildStep3()));
  }

  void _handleBack() {
    if (_flowKey.currentState?.canPop() ?? false) {
      setState(() => _currentStep--);
      _flow.pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildStep2() => SignupStep2Screen(
        initialName: _name,
        onBack: _handleBack,
        onNext: _onStep2Done,
      );

  Widget _buildStep3() => SignupStep3Screen(
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
        onSignupSuccess: widget.onSuccess,
      );

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) => _handleBack(),
      child: Scaffold(
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
            child: Column(
              children: [
                // ── FLOATING STATIC TOP BAR (Does not slide with card pages) ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _handleBack,
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
                      Expanded(
                        child: _SignupProgressBar(value: _currentStep / 3.0),
                      ),
                      const SizedBox(width: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          'STEP $_currentStep OF 3',
                          key: ValueKey(_currentStep),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00A36C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── SLIDING STEP CONTENT PAGES ─────────────────────────────
                Expanded(
                  child: Navigator(
                    key: _flowKey,
                    onGenerateInitialRoutes: (_, __) => [
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => SignupStep1Screen(
                          onBack: _handleBack,
                          onNext: _onStep1Done,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                        transitionsBuilder: (_, __, ___, child) => child,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Floating Signup Progress Bar ─────────────────────────────────────────────

class _SignupProgressBar extends StatelessWidget {
  final double value;
  const _SignupProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              width: constraints.maxWidth,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              width: constraints.maxWidth * value,
              height: 6,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C882), Color(0xFF00A36C)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        );
      },
    );
  }
}
