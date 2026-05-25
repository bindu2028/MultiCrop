import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/prediction_response.dart';
import 'auth_service.dart';
import 'network_config.dart';

class ApiService {
  ApiService({String? baseUrl, AuthService? authService})
      : _baseUrl = baseUrl ?? _defaultBaseUrl(),
        _auth = authService ?? AuthService();

  final String _baseUrl;
  final AuthService _auth;

  static String _defaultBaseUrl() {
    return resolveApiBaseUrl();
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

  // ---------------------------------------------------------------------------
  // History & Diary cloud sync endpoints
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> fetchScanHistory({int limit = 50, int offset = 0}) async {
    final response = await _getWithAuth('/api/history/scans?limit=$limit&offset=$offset');
    if (response.statusCode >= 400) {
      throw Exception('Failed to load scan history');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<void> clearScanHistory() async {
    final response = await _deleteWithAuth('/api/history/scans');
    if (response.statusCode >= 400) {
      throw Exception('Failed to clear scan history');
    }
  }

  Future<List<dynamic>> fetchTrackedPlants() async {
    final response = await _getWithAuth('/api/history/plants');
    if (response.statusCode >= 400) {
      throw Exception('Failed to load tracked plants');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> addOrUpdateTrackedPlant(Map<String, dynamic> plantData) async {
    final response = await _postWithAuth('/api/history/plants', plantData);
    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception((body['error'] ?? 'Failed to save tracked plant').toString());
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> deleteTrackedPlant(int plantId) async {
    final response = await _deleteWithAuth('/api/history/plants/$plantId');
    if (response.statusCode >= 400) {
      throw Exception('Failed to delete tracked plant');
    }
  }

  Future<PredictionResponse> predictDisease(
    Uint8List imageBytes, {
    required String crop,
    required String filename,
  }) async {
    final token = await _validToken();
    final resolvedFilename = _resolveFilename(filename);

    Future<http.StreamedResponse> sendRequest(String authToken) {
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/predict'))
        ..headers['Authorization'] = 'Bearer $authToken'
        ..fields['crop'] = crop
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: resolvedFilename,
            contentType: _mediaTypeForFilename(resolvedFilename),
          ),
        );
      return request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Prediction request timed out. Please check your connection and try again.'),
      );
    }

    http.StreamedResponse streamedResponse = await sendRequest(token);

    // Auto-refresh: if 401 try once more with a fresh token
    if (streamedResponse.statusCode == 401) {
      final newToken = await _auth.getValidAccessToken();
      if (newToken != null) {
        streamedResponse = await sendRequest(newToken);
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

  /// POST request with automatic Bearer token + one 401 retry/refresh.
  Future<http.Response> _postWithAuth(String path, Map<String, dynamic> body) async {
    final token = await _validToken();

    var response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    // Auto-refresh on 401
    if (response.statusCode == 401) {
      final newToken = await _auth.getValidAccessToken();
      if (newToken != null) {
        response = await http.post(
          Uri.parse('$_baseUrl$path'),
          headers: {
            'Authorization': 'Bearer $newToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }

  /// DELETE request with automatic Bearer token + one 401 retry/refresh.
  Future<http.Response> _deleteWithAuth(String path) async {
    final token = await _validToken();

    var response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Auto-refresh on 401
    if (response.statusCode == 401) {
      final newToken = await _auth.getValidAccessToken();
      if (newToken != null) {
        response = await http.delete(
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
