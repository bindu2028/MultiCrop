import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/prediction_response.dart';

class ApiService {
  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl();

  final String _baseUrl;

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
      // Real device: use the PC's Wi-Fi IP since ADB reverse might disconnect natively
      return 'http://10.77.248.173:5000';
    }

    return 'http://127.0.0.1:5000';
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/health'));
      if (response.statusCode >= 400) {
        return false;
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (body['status'] ?? '').toString().toLowerCase() == 'ok';
    } catch (_) {
      return false;
    }
  }

  Future<List<String>> fetchCrops() async {
    final response = await http.get(Uri.parse('$_baseUrl/crops'));
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
    final resolvedFilename = _resolveFilename(filename);
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/predict'))
      ..fields['crop'] = crop
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: resolvedFilename,
          contentType: _mediaTypeForFilename(resolvedFilename),
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw Exception((body['error'] ?? 'Prediction failed.').toString());
    }

    return PredictionResponse.fromJson(body);
  }

  String _resolveFilename(String filename) {
    final trimmed = filename.trim();
    if (trimmed.isEmpty) {
      return 'leaf.jpg';
    }

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
    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (lower.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (lower.endsWith('.bmp')) {
      return MediaType('image', 'bmp');
    }
    return MediaType('image', 'jpeg');
  }
}
