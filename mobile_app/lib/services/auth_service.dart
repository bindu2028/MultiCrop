import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';
import 'network_config.dart';

class AuthService {
  static const _accessTokenKey = 'jwt_access_token';
  static const _refreshTokenKey = 'jwt_refresh_token';
  static const _nameKey = 'auth_name';
  static const _emailKey = 'auth_email';

  // In-memory cache of the current session
  static AuthSession? _inMemorySession;

  // ---------------------------------------------------------------------------
  // Base URL — mirrors api_service.dart logic
  // ---------------------------------------------------------------------------
  static String _baseUrl() {
    return resolveApiBaseUrl();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the currently stored session (from memory or SharedPreferences).
  Future<AuthSession?> getSession() async {
    if (_inMemorySession != null) return _inMemorySession;
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_nameKey);
      final email = prefs.getString(_emailKey);
      final access = prefs.getString(_accessTokenKey);
      final refresh = prefs.getString(_refreshTokenKey);
      if (name == null || email == null || access == null || refresh == null) {
        return null;
      }
      _inMemorySession = AuthSession(
        name: name,
        email: email,
        accessToken: access,
        refreshToken: refresh,
      );
      return _inMemorySession;
    } catch (_) {
      return null;
    }
  }

  /// Returns a valid access token, refreshing if the stored one has expired.
  /// Returns null if the user is not logged in or if refresh fails.
  Future<String?> getValidAccessToken() async {
    final session = await getSession();
    if (session == null) return null;

    // Try a lightweight /auth/me call to check validity
    final testResp = await http.get(
      Uri.parse('${_baseUrl()}/auth/me'),
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );

    if (testResp.statusCode == 200) return session.accessToken;

    // Token expired — try to refresh
    if (testResp.statusCode == 401) {
      final newAccess = await _refreshAccessToken(session.refreshToken);
      return newAccess;
    }

    return null;
  }

  /// Login: calls backend /auth/login with username (derived from email) + password.
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

    // Always use the lowercase email as the username for zero-collision consistency
    final username = email.trim().toLowerCase();

    final response = await http.post(
      Uri.parse('${_baseUrl()}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      if (response.statusCode >= 500) {
        throw Exception('Server is temporarily offline (Error ${response.statusCode}). Please try again in a moment.');
      }
      throw Exception('Failed to connect to server. Please check your internet connection.');
    }

    if (response.statusCode != 200) {
      throw Exception((body['error'] ?? 'Login failed.').toString());
    }

    final access = body['access_token'] as String;
    final refresh = body['refresh_token'] as String;
    
    // Derive a clean, capitalized display name from the email prefix
    String name = username;
    if (name.contains('@')) {
      name = name.split('@').first;
    }
    name = name.replaceAll('_', ' ').replaceAll('.', ' ');
    name = name.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ').trim();
    if (name.isEmpty) name = 'User';

    final session = AuthSession(
      name: name,
      email: email.trim(),
      accessToken: access,
      refreshToken: refresh,
    );
    await _saveSession(session);
    return session;
  }

  /// SignUp: calls backend /auth/register and returns a session with real tokens.
  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) throw Exception('Name is required.');
    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Enter a valid email.');
    }
    if (password.trim().length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    // Always use the lowercase email as the username for zero-collision consistency
    final username = email.trim().toLowerCase();

    final response = await http.post(
      Uri.parse('${_baseUrl()}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      if (response.statusCode >= 500) {
        throw Exception('Server is temporarily offline (Error ${response.statusCode}). Please try again in a moment.');
      }
      throw Exception('Failed to connect to server. Please check your internet connection.');
    }

    if (response.statusCode != 201) {
      throw Exception((body['error'] ?? 'Registration failed.').toString());
    }

    final access = body['access_token'] as String;
    final refresh = body['refresh_token'] as String;

    final session = AuthSession(
      name: name.trim(),
      email: email.trim(),
      accessToken: access,
      refreshToken: refresh,
    );
    await _saveSession(session);
    return session;
  }

  /// Logout: clears all stored tokens and session data.
  Future<void> logout() async {
    _inMemorySession = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_nameKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (_) {
      // Continue even if persistence fails
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl()}/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        // Refresh token is also invalid — force re-login
        await logout();
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final newAccess = body['access_token'] as String;

      // Update stored session with new access token
      final oldSession = _inMemorySession;
      if (oldSession != null) {
        final updated = AuthSession(
          name: oldSession.name,
          email: oldSession.email,
          accessToken: newAccess,
          refreshToken: refreshToken,
        );
        await _saveSession(updated);
      }
      return newAccess;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveSession(AuthSession session) async {
    _inMemorySession = session;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nameKey, session.name);
      await prefs.setString(_emailKey, session.email);
      await prefs.setString(_accessTokenKey, session.accessToken);
      await prefs.setString(_refreshTokenKey, session.refreshToken);
    } catch (_) {
      // Continue with in-memory session if persistence is unavailable
    }
  }
}
