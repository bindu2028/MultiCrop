import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/prediction_response.dart';
import 'auth_service.dart';

class ApiService {
  ApiService({String? baseUrl, AuthService? authService})
      : _baseUrl = baseUrl ?? _defaultBaseUrl(),
        _auth = authService ?? AuthService();

  final String _baseUrl;
  final AuthService _auth;

  static String _defaultBaseUrl() {
    const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl.endsWith('/')
          ? configuredBaseUrl.substring(0, configuredBaseUrl.length - 1)
          : configuredBaseUrl;
    }

    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? '127.0.0.1' : Uri.base.host;
      return 'http://$host:5000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Real device: use the PC's Wi-Fi IP
      return 'http://192.168.29.52:5000';
    }

    return 'http://127.0.0.1:5000';
  }

  // ---------------------------------------------------------------------------
  // Public endpoints
  // ---------------------------------------------------------------------------

  Future<bool> checkHealth() async {
    try {
      // /health is unprotected — no token needed
      final response = await http.get(Uri.parse('$_baseUrl/health'));
      if (response.statusCode >= 400) return false;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (body['status'] ?? '').toString().toLowerCase() == 'ok';
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> fetchCrops() async {
    final response = await _getWithAuth('/crops');
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw Exception((body['error'] ?? 'Failed to load crops.').toString());
    }

    return (body['crops'] as List<dynamic>? ?? [])
        .map((crop) => crop.toString())
        .where((crop) => crop.toLowerCase() != 'auto')
        .toList();
  }

  Future<PredictionResponse> predictDisease(
    Uint8List imageBytes, {
    required String crop,
    required String filename,
  }) async {
    final token = await _validToken();
    final resolvedFilename = _resolveFilename(filename);

    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/predict'))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['crop'] = crop
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: resolvedFilename,
          contentType: _mediaTypeForFilename(resolvedFilename),
        ),
      );

    http.StreamedResponse streamedResponse = await request.send();

    // Auto-refresh: if 401 try once more with a fresh token
    if (streamedResponse.statusCode == 401) {
      final newToken = await _auth.getValidAccessToken();
      if (newToken != null) {
        final retryRequest =
            http.MultipartRequest('POST', Uri.parse('$_baseUrl/predict'))
              ..headers['Authorization'] = 'Bearer $newToken'
              ..fields['crop'] = crop
              ..files.add(
                http.MultipartFile.fromBytes(
                  'image',
                  imageBytes,
                  filename: resolvedFilename,
                  contentType: _mediaTypeForFilename(resolvedFilename),
                ),
              );
        streamedResponse = await retryRequest.send();
      }
    }

    final response = await http.Response.fromStream(streamedResponse);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw Exception((body['error'] ?? 'Prediction failed.').toString());
    }

    return PredictionResponse.fromJson(body);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Fetches a valid token, throwing a clear error if unauthenticated.
  Future<String> _validToken() async {
    final token = await _auth.getValidAccessToken();
    if (token == null) {
      throw Exception('Not authenticated. Please sign in again.');
    }
    return token;
  }

  /// GET request with automatic Bearer token + one 401 retry/refresh.
  Future<http.Response> _getWithAuth(String path) async {
    final token = await _validToken();

    var response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Auto-refresh on 401
    if (response.statusCode == 401) {
      final newToken = await _auth.getValidAccessToken();
      if (newToken != null) {
        response = await http.get(
          Uri.parse('$_baseUrl$path'),
          headers: {'Authorization': 'Bearer $newToken'},
        );
      }
    }

    return response;
  }

  String _resolveFilename(String filename) {
    final trimmed = filename.trim();
    if (trimmed.isEmpty) return 'leaf.jpg';

    final lower = trimmed.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp')) {
      return trimmed;
    }

    return '$trimmed.jpg';
  }

  MediaType _mediaTypeForFilename(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.bmp')) return MediaType('image', 'bmp');
    return MediaType('image', 'jpeg');
  }
}
