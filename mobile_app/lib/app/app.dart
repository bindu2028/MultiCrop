import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../screens/auth_screen.dart';
import '../screens/app_shell.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class PlantLensApp extends StatelessWidget {
  const PlantLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();

  AuthSession? _session;
  bool _loading = true;
  String? _bootstrapError;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final session = await _authService.getSession().timeout(const Duration(seconds: 5));
      if (!mounted) {
        return;
      }

      setState(() {
        _session = session;
        _loading = false;
        _bootstrapError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _session = null;
        _bootstrapError = 'We could not restore your session. You can continue and sign in again.';
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }
    setState(() => _session = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _BootstrapScreen(
        title: 'Starting PlantLens',
        subtitle: 'Preparing your dashboard...',
        showLoader: true,
      );
    }

    if (_bootstrapError != null) {
      return _BootstrapScreen(
        title: 'Startup issue',
        subtitle: _bootstrapError!,
        actionLabel: 'Continue to Sign In',
        onAction: () => setState(() => _bootstrapError = null),
      );
    }

    if (_session == null) {
      return AuthScreen(
        onAuthenticated: (session) {
          setState(() => _session = session);
        },
      );
    }

    return AppShell(
      userName: _session!.name,
      userEmail: _session!.email,
      onLogout: _logout,
    );
  }
}

class _BootstrapScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLoader;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _BootstrapScreen({
    required this.title,
    required this.subtitle,
    this.showLoader = false,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF647265)),
                      ),
                      if (showLoader) ...[
                        const SizedBox(height: 20),
                        const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ),
                      ],
                      if (actionLabel != null && onAction != null) ...[
                        const SizedBox(height: 18),
                        FilledButton(onPressed: onAction, child: Text(actionLabel!)),
                      ],
                    ],
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
