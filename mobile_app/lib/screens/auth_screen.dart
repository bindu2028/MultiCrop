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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: loading ? null : onBack,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isSignIn ? 'Sign In' : 'Create Account',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSignIn ? 'Welcome back to PlantLens.' : 'Start your smart plant care journey.',
                    style: const TextStyle(color: Color(0xFF5C7362)),
                  ),
                  const SizedBox(height: 16),
                  if (!isSignIn) ...[
                    TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    onSubmitted: (_) => loading ? null : onSubmit(),
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: loading ? null : onSubmit,
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isSignIn ? 'Sign In' : 'Create Account'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: loading ? null : onSwitchMode,
                    child: Text(
                      isSignIn
                          ? "Don't have an account? Sign up"
                          : 'Already have an account? Sign in',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF5C7362)),
                  ),
                ],
              ),
            ),
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
