import 'package:flutter/foundation.dart';

/// Production backend URL — update this to your Render service URL before building a release APK.
/// You can also override at build time: flutter build apk --dart-define=API_BASE_URL=https://...
const String _kProductionUrl = 'https://plantlens-backend.onrender.com';

String resolveApiBaseUrl() {
  // 1. Compile-time override (highest priority — use for CI/CD)
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  if (apiBaseUrl.isNotEmpty) {
    return _normalizeBaseUrl(apiBaseUrl);
  }

  const apiUrl = String.fromEnvironment('API_URL');
  if (apiUrl.isNotEmpty) {
    return _normalizeBaseUrl(apiUrl);
  }

  // 2. In debug mode: use local server
  if (kDebugMode) {
    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
      return 'http://$host:5000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000'; // Android emulator loopback
    }
    return 'http://127.0.0.1:5000';
  }

  // 3. Release mode: always use production
  return _kProductionUrl;
}

String _normalizeBaseUrl(String value) {
  return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}