import 'package:flutter/foundation.dart';

String resolveApiBaseUrl() {
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  if (apiBaseUrl.isNotEmpty) {
    return _normalizeBaseUrl(apiBaseUrl);
  }

  const apiUrl = String.fromEnvironment('API_URL');
  if (apiUrl.isNotEmpty) {
    return _normalizeBaseUrl(apiUrl);
  }

  if (kIsWeb) {
    final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
    return 'http://$host:5000';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://192.168.29.52:5000';
  }

  return 'http://127.0.0.1:5000';
}

String _normalizeBaseUrl(String value) {
  return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}