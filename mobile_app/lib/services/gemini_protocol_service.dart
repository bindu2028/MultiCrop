import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiProtocolService {
  final String apiKey;
  
  GeminiProtocolService({required this.apiKey});

  /// Tries to fetch response using the specified API version (v1 or v1beta)
  Future<String> getCompletion({
    required String prompt,
    String modelName = 'gemini-1.5-flash',
    String apiVersion = 'v1beta',
  }) async {
    final url = 'https://generativelanguage.googleapis.com/$apiVersion/models/$modelName:generateContent?key=$apiKey';
    
    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      }
    };

    try {
      debugPrint('Gemini Protocol: Sending request to $apiVersion/$modelName...');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] ?? 'No text generated.';
          }
        }
        return 'Empty response from AI.';
      } else {
        final errorMsg = jsonDecode(response.body)['error']?['message'] ?? 'Status ${response.statusCode}';
        throw Exception('Gemini Protocol Error ($apiVersion): $errorMsg');
      }
    } catch (e) {
      debugPrint('Gemini Protocol: Failed for $apiVersion/$modelName: $e');
      rethrow;
    }
  }

  /// Specialized diagnostic to find which version/model actually works
  Future<Map<String, dynamic>> discoverWorkingConfig(String testMessage) async {
    final versions = ['v1', 'v1beta'];
    final models = [
      'gemini-2.0-flash', 
      'gemini-flash-latest', 
      'gemini-1.5-flash', 
      'gemini-1.5-pro', 
      'gemini-pro'
    ];
    
      String lastInnerError = 'Unknown error';
    for (var version in versions) {
      for (var model in models) {
        try {
          final response = await getCompletion(prompt: testMessage, modelName: model, apiVersion: version);
          return {
            'version': version,
            'model': model,
            'response': response,
          };
        } catch (e) {
          lastInnerError = e.toString();
          continue;
        }
      }
    }
    throw Exception('Bridge Failure: $lastInnerError');
  }
}
