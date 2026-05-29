import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

enum _AuthView { landing, signIn, signUp }

class AuthScreen extends StatefulWidget {
  final void Function(AuthSession session) onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ApiService().checkHealth(); // Trigger asynchronous non-blocking cold-start wake up
  }

  _AuthView _view = _AuthView.landing;
  bool _loading = false;
  String _message = 'Welcome to PlantLens.';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isSignIn => _view == _AuthView.signIn;
  bool get _isSignUp => _view == _AuthView.signUp;

  Future<void> _submit() async {
    if (!_isSignIn && !_isSignUp) {
      return;
    }

    setState(() {
      _loading = true;
      _message = _isSignIn ? 'Signing in...' : 'Creating account...';
    });

    try {
      final session = _isSignIn
          ? await _authService.login(
              email: _emailController.text,
              password: _passwordController.text,
            )
          : await _authService.signUp(
              name: _nameController.text,
              email: _emailController.text,
              password: _passwordController.text,
            );

      if (!mounted) {
        return;
      }
      widget.onAuthenticated(session);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _goToSignIn() {
    setState(() {
      _view = _AuthView.signIn;
      _message = 'Sign in to continue.';
    });
  }

  void _goToSignUp() {
    setState(() {
      _view = _AuthView.signUp;
      _message = 'Create your account.';
    });
  }

  void _goToLanding() {
    setState(() {
      _view = _AuthView.landing;
      _message = 'Welcome to PlantLens.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _view == _AuthView.landing
            ? _LandingView(
                key: const ValueKey('landing'),
                onSignIn: _goToSignIn,
                onSignUp: _goToSignUp,
              )
            : SafeArea(
                child: _AuthFormView(
                  key: ValueKey(_view.name),
                  isSignIn: _isSignIn,
                  loading: _loading,
                  message: _message,
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onBack: _goToLanding,
                  onSwitchMode: _isSignIn ? _goToSignUp : _goToSignIn,
                  onSubmit: _submit,
                ),
              ),
      ),
    );
  }
}

class _LandingView extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  const _LandingView({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF020E0A), // Extra deep forest black
            Color(0xFF071F15), // Deep dark emerald
            Color(0xFF030D09), // Black forest
          ],
        ),
      ),
      child: Stack(
        children: [
          // Overlapping large glowing liquid circles
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF52B788).withValues(alpha: 0.3),
                    const Color(0xFF52B788).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E6091).withValues(alpha: 0.22),
                    const Color(0xFF1E6091).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 220,
            right: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF74C69D).withValues(alpha: 0.2),
                    const Color(0xFF74C69D).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF40916C).withValues(alpha: 0.15),
                    const Color(0xFF40916C).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // High-density blur filter over background orbs to blend into a seamless mesh glow
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: const SizedBox.shrink(),
            ),
          ),

          // Content (wrapped in a ScrollView to prevent overflow, constrained for responsive design)
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF52B788), Color(0xFF2D6A4F)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.15),
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF52B788).withValues(alpha: 0.4),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'PlantLens',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 22,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.06),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.12),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF52B788),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0xFF52B788),
                                                    blurRadius: 6,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(
                                              'v2.0 Beta',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 36),
                                  RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        height: 1.15,
                                        letterSpacing: -0.5,
                                      ),
                                      children: [
                                        TextSpan(text: 'Detect plant '),
                                        TextSpan(
                                          text: 'diseases',
                                          style: TextStyle(
                                            color: Color(0xFF52B788),
                                            shadows: [
                                              Shadow(
                                                color: Color(0xFF52B788),
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextSpan(text: '\nbefore they spread.'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Scan a leaf, get instant confidence-based diagnosis, and follow clear remedies in seconds.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      fontSize: 14.5,
                                      height: 1.45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  const _FeaturePill(
                                    icon: Icons.camera_alt_outlined,
                                    title: 'Fast camera scan',
                                    subtitle: 'Live image capture and upload',
                                  ),
                                  const SizedBox(height: 12),
                                  const _FeaturePill(
                                    icon: Icons.analytics_outlined,
                                    title: 'Confidence scoring',
                                    subtitle: 'Green, yellow, red clarity indicators',
                                  ),
                                  const SizedBox(height: 12),
                                  const _FeaturePill(
                                    icon: Icons.history_outlined,
                                    title: 'Track your history',
                                    subtitle: 'Review every past diagnosis quickly',
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 32),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF52B788), Color(0xFF2D6A4F)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF52B788).withValues(alpha: 0.4),
                                              blurRadius: 16,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: onSignIn,
                                          child: const Text(
                                            'Sign In',
                                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withValues(alpha: 0.08),
                                              Colors.white.withValues(alpha: 0.02),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            side: BorderSide.none,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: onSignUp,
                                          child: const Text(
                                            'Create Account',
                                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthFormView extends StatefulWidget {
  final bool isSignIn;
  final bool loading;
  final String message;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onBack;
  final VoidCallback onSwitchMode;
  final VoidCallback onSubmit;

  const _AuthFormView({
    super.key,
    required this.isSignIn,
    required this.loading,
    required this.message,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onBack,
    required this.onSwitchMode,
    required this.onSubmit,
  });

  @override
  State<_AuthFormView> createState() => _AuthFormViewState();
}

class _AuthFormViewState extends State<_AuthFormView> {
  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_onPasswordChanged);
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {});
  }

  Widget _buildPasswordStrengthMeter(String val) {
    if (val.isEmpty) return const SizedBox.shrink();

    final hasLen = val.length >= 8;
    final hasDigit = val.contains(RegExp(r'\d'));
    final hasUpper = val.contains(RegExp(r'[A-Z]'));
    final hasSpecial = val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int metCount = 0;
    if (hasLen) metCount++;
    if (hasDigit) metCount++;
    if (hasUpper) metCount++;
    if (hasSpecial) metCount++;

    double progress = metCount / 4.0;
    Color color = const Color(0xFFE53935); // Weak (Red)
    String label = 'Weak Password';
    if (metCount == 2 || metCount == 3) {
      color = const Color(0xFFFFB300); // Fair (Yellow)
      label = 'Fair Password';
    } else if (metCount == 4) {
      color = const Color(0xFF2E7D32); // Strong (Green)
      label = 'Strong Password';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFECEFF1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildCriteriaChip('8+ characters', hasLen),
            _buildCriteriaChip('1+ number', hasDigit),
            _buildCriteriaChip('1+ uppercase', hasUpper),
            _buildCriteriaChip('1+ symbol', hasSpecial),
          ],
        ),
      ],
    );
  }

  Widget _buildCriteriaChip(String text, bool met) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: met ? const Color(0xFFE8F5E9) : const Color(0xFFECEFF1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: met ? const Color(0xFF81C784) : const Color(0xFFCFD8DC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.cancel_outlined,
            size: 11,
            color: met ? const Color(0xFF2E7D32) : const Color(0xFF78909C),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: met ? const Color(0xFF1B5E20) : const Color(0xFF546E7A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF81C784).withValues(alpha: 0.08),
            Color(0xFF42A5F5).withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.92),
                        Colors.white.withValues(alpha: 0.88),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1B5E20).withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.loading ? null : widget.onBack,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.arrow_back_rounded,
                                      color: widget.loading ? Color(0xFFCCCCCC) : Color(0xFF1B5E20),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                widget.isSignIn ? 'Welcome Back' : 'Get Started',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.isSignIn
                                ? 'Sign in to your PlantLens account'
                                : 'Create your smart plant care account',
                            style: TextStyle(
                              color: Color(0xFF558B2F),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 24),
                          if (!widget.isSignIn) ...[
                            _ModernTextField(
                              controller: widget.nameController,
                              hintText: 'Full Name',
                              icon: Icons.person_outline,
                              enabled: !widget.loading,
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(height: 14),
                          ],
                          _ModernTextField(
                            controller: widget.emailController,
                            hintText: 'Email Address',
                            icon: Icons.email_outlined,
                            enabled: !widget.loading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 14),
                          _ModernTextField(
                            controller: widget.passwordController,
                            hintText: 'Password',
                            icon: Icons.lock_outline,
                            enabled: !widget.loading,
                            isPassword: true,
                            onSubmitted: (_) => widget.loading ? null : widget.onSubmit(),
                          ),
                          if (!widget.isSignIn)
                            _buildPasswordStrengthMeter(widget.passwordController.text),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF81C784).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.loading ? null : widget.onSubmit,
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: widget.loading
                                      ? SizedBox(
                                          height: 24,
                                          child: Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          widget.isSignIn ? 'Sign In' : 'Create Account',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 14),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.loading ? null : widget.onSwitchMode,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  widget.isSignIn
                                      ? "Don't have an account? Create one"
                                      : 'Already have an account? Sign in',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF81C784),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: widget.message.toLowerCase().contains('error') ||
                                      widget.message.toLowerCase().contains('failed') ||
                                      widget.message.toLowerCase().contains('invalid') ||
                                      widget.message.toLowerCase().contains('locked')
                                  ? Color(0xFFFFEBEE)
                                  : Color(0xFFF1F8E9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: widget.message.toLowerCase().contains('error') ||
                                        widget.message.toLowerCase().contains('failed') ||
                                        widget.message.toLowerCase().contains('invalid') ||
                                        widget.message.toLowerCase().contains('locked')
                                    ? Color(0xFFEF5350)
                                    : Color(0xFFA5D6A7),
                              ),
                            ),
                            child: Text(
                              widget.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: widget.message.toLowerCase().contains('error') ||
                                        widget.message.toLowerCase().contains('failed') ||
                                        widget.message.toLowerCase().contains('invalid') ||
                                        widget.message.toLowerCase().contains('locked')
                                    ? Color(0xFFD32F2F)
                                    : Color(0xFF558B2F),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool enabled;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String)? onSubmitted;

  const _ModernTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.enabled = true,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  State<_ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<_ModernTextField> {
  late bool _obscureText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF81C784).withValues(alpha: _isFocused ? 0.08 : 0.05),
            Color(0xFF66BB6A).withValues(alpha: _isFocused ? 0.08 : 0.05),
          ],
        ),
        border: Border.all(
          color: _isFocused
              ? Color(0xFF81C784).withValues(alpha: 0.5)
              : Color(0xFF81C784).withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: Color(0xFF81C784).withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (focused) {
          setState(() => _isFocused = focused);
        },
        child: TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Color(0xFF99A399),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              widget.icon,
              color: _isFocused ? Color(0xFF81C784) : Color(0xFF558B2F),
              size: 20,
            ),
            suffixIcon: widget.isPassword
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _obscureText = !_obscureText),
                      child: Icon(
                        _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Color(0xFF558B2F),
                        size: 20,
                      ),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeaturePill({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF52B788).withValues(alpha: 0.12),
                  border: Border.all(
                    color: const Color(0xFF52B788).withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF52B788).withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF74C69D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
