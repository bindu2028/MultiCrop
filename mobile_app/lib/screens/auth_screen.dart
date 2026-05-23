import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../services/auth_service.dart';

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
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _view == _AuthView.landing
              ? _LandingView(
                  key: const ValueKey('landing'),
                  onSignIn: _goToSignIn,
                  onSignUp: _goToSignUp,
                )
              : _AuthFormView(
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F4D2D), Color(0xFF2B9E59)],
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -24,
                        right: -18,
                        child: _Glow(size: 130, color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      Positioned(
                        bottom: 24,
                        right: 34,
                        child: _Glow(size: 62, color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.eco_rounded, color: Colors.white, size: 18),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'PlantLens',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            const Text(
                              'Detect plant diseases before they spread.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Scan a leaf, get instant confidence-based diagnosis, and follow clear remedies in seconds.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 22),
                            const _FeaturePill(
                              icon: Icons.camera_alt_outlined,
                              title: 'Fast camera scan',
                              subtitle: 'Live image capture and upload',
                            ),
                            const SizedBox(height: 10),
                            const _FeaturePill(
                              icon: Icons.analytics_outlined,
                              title: 'Confidence scoring',
                              subtitle: 'Green, yellow, red clarity indicators',
                            ),
                            const SizedBox(height: 10),
                            const _FeaturePill(
                              icon: Icons.history_outlined,
                              title: 'Track your history',
                              subtitle: 'Review every past diagnosis quickly',
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF135F35),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    onPressed: onSignIn,
                                    child: const Text('Sign In'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.white70),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    onPressed: onSignUp,
                                    child: const Text('Create Account'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthFormView extends StatelessWidget {
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: loading ? null : onBack,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    color: loading ? Color(0xFFCCC) : Color(0xFF1B5E20),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              isSignIn ? 'Welcome Back' : 'Get Started',
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
                          isSignIn
                              ? 'Sign in to your PlantLens account'
                              : 'Create your smart plant care account',
                          style: TextStyle(
                            color: Color(0xFF558B2F),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 24),
                        if (!isSignIn) ...[
                          _ModernTextField(
                            controller: nameController,
                            hintText: 'Full Name',
                            icon: Icons.person_outline,
                            enabled: !loading,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 14),
                        ],
                        _ModernTextField(
                          controller: emailController,
                          hintText: 'Email Address',
                          icon: Icons.email_outlined,
                          enabled: !loading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 14),
                        _ModernTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline,
                          enabled: !loading,
                          isPassword: true,
                          onSubmitted: (_) => loading ? null : onSubmit(),
                        ),
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
                              onTap: loading ? null : onSubmit,
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: loading
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
                                        isSignIn ? 'Sign In' : 'Create Account',
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
                            onTap: loading ? null : onSwitchMode,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                isSignIn
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
                            color: message.toLowerCase().contains('error') ||
                                    message.toLowerCase().contains('failed')
                                ? Color(0xFFFFEBEE)
                                : Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: message.toLowerCase().contains('error') ||
                                      message.toLowerCase().contains('failed')
                                  ? Color(0xFFEF5350)
                                  : Color(0xFFA5D6A7),
                            ),
                          ),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: message.toLowerCase().contains('error') ||
                                      message.toLowerCase().contains('failed')
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
