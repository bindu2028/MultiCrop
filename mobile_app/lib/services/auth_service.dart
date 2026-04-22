import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';

class AuthService {
  static const _nameKey = 'auth_name';
  static const _emailKey = 'auth_email';
  static AuthSession? _inMemorySession;

  Future<AuthSession?> getSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_nameKey);
      final email = prefs.getString(_emailKey);
      if (name == null || email == null) {
        return _inMemorySession;
      }
      final session = AuthSession(name: name, email: email);
      _inMemorySession = session;
      return session;
    } catch (_) {
      // On some browsers, local storage can be blocked by privacy settings.
      return _inMemorySession;
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Enter a valid email.');
    }
    if (password.trim().length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    final inferredName = email.split('@').first;
    final session = AuthSession(name: inferredName, email: email.trim());
    await _saveSession(session);
    return session;
  }

  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) {
      throw Exception('Name is required.');
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Enter a valid email.');
    }
    if (password.trim().length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    final session = AuthSession(name: name.trim(), email: email.trim());
    await _saveSession(session);
    return session;
  }

  Future<void> logout() async {
    _inMemorySession = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_nameKey);
      await prefs.remove(_emailKey);
    } catch (_) {
      // Ignore persistence errors and continue with in-memory logout.
    }
  }

  Future<void> _saveSession(AuthSession session) async {
    _inMemorySession = session;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nameKey, session.name);
      await prefs.setString(_emailKey, session.email);
    } catch (_) {
      // Continue with in-memory session if persistence is unavailable.
    }
  }
}
