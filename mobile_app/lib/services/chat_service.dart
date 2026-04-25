import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'gemini_protocol_service.dart';
import 'local_expert_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatService {
  ChatSession? _chatSession;
  GeminiProtocolService? _protocolService;
  final String crop;
  final String disease;

  String? _workingModel;
  String? _workingVersion;

  ChatService({required this.crop, required this.disease}) {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isNotEmpty) {
      _protocolService = GeminiProtocolService(apiKey: apiKey);
    }
    _initModel();
  }

  void _initModel() {
    // IMPORTANT: The user must replace this with a real API key via .env
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty || apiKey == 'YOUR_API_KEY_HERE') {
      debugPrint('WARNING: Gemini API Key is missing. Using local fallback rules.');
      return; 
    }

    final maskedKey = apiKey.length > 8 
        ? '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}'
        : 'INVALID_KEY';
    debugPrint('Gemini Initialization: Using key $maskedKey');

    _initSafeModel(apiKey);
  }

  void _initSafeModel(String apiKey) {
    try {
      // We will try gemini-1.5-flash first, then fallback to gemini-pro if needed.
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
      
      _chatSession = model.startChat(history: [
        Content.model([TextPart('I am PlantLens, an elite agricultural AI assistant. I will provide professional, expert advice for $crop plants affected by $disease.')]),
      ]);
      debugPrint('Gemini: Successfully initialized with gemini-1.5-flash');
    } catch (e) {
      debugPrint('Gemini: Primary initialization failed: $e');
    }
  }

  Future<String> sendMessage(String userMessage) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    
    // If we don't have a session, try one more time with a broader fallback name
    if (_chatSession == null && apiKey.isNotEmpty) {
       try {
         final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
         _chatSession = model.startChat(history: [
           Content.model([TextPart('I am PlantLens, an elite agricultural AI assistant.')]),
         ]);
         debugPrint('Gemini: Initialized using fallback name gemini-pro');
       } catch (_) {}
    }

    if (_chatSession != null) {
      try {
        final response = await _chatSession!.sendMessage(Content.text(userMessage));
        return response.text?.trim() ?? 'I could not generate a response.';
      } catch (e) {
        // If it's a model not found error, try to switch models and retry once
        if ((e.toString().contains('not found') || e.toString().contains('demand')) && !userMessage.startsWith('###RETRY###')) {
           debugPrint('Gemini: Model issue detected. Attempting protocol fallback...');
           return _retryWithDifferentModel(userMessage);
        }
        return 'I encountered an error connecting to my AI brain. ($e)';
      }
    }
    
    // Final local fallback
    await Future.delayed(const Duration(milliseconds: 1500));
    return _generateMockResponse(userMessage);
  }

  Future<String> _retryWithDifferentModel(String userMessage) async {
    if (_protocolService == null) return 'No API key configured.';

    // If we already found a working config in a previous send, use it
    if (_workingModel != null && _workingVersion != null) {
      return _protocolService!.getCompletion(
        prompt: userMessage,
        modelName: _workingModel!,
        apiVersion: _workingVersion!,
      );
    }

    String lastError = 'Unknown error';
    final modelNames = [
      'gemini-flash-latest',
      'gemini-2.0-flash',
      'gemini-pro-latest', 
      'gemini-2.0-flash-lite', 
      'gemini-1.5-flash'
    ];
    for (var name in modelNames) {
      try {
        debugPrint('Gemini: Retrying with $name...');
        final config = await _protocolService!.discoverWorkingConfig(
          '###RETRY### Scanned $crop for $disease. User: $userMessage'
        );
        
        _workingModel = config['model'];
        _workingVersion = config['version'];
        return config['response'];
      } catch (e) {
        lastError = e.toString();
        continue;
      }
    }
    
    // FINAL HYBRID FALLBACK: If all AI fail, use LocalExpertService
    return LocalExpertService.getQuickAdvice(crop, disease);
  }

  String _generateMockResponse(String userMessage) {
    final lower = userMessage.toLowerCase();
    
    if (lower.contains('fungicide') || lower.contains('chemical') || lower.contains('buy')) {
      return 'For $disease on $crop, you generally want a specific copper-based or sulfur-based fungicide. Look for active ingredients matching local regulations for $crop. Note: I am running in fallback mode; insert a Gemini API key for deep analysis!';
    }
    
    if (lower.contains('prune') || lower.contains('cut') || lower.contains('leaves')) {
      return 'Pruning is vital! Yes, cut away all foliage showing signs of $disease immediately. Dispose of the leaves far away from the garden—do not compost them.';
    }
    
    if (lower.contains('water') || lower.contains('soil') || lower.contains('rain')) {
      return 'Avoid overhead watering. Moisture on the leaves of your $crop accelerates the spread of $disease. Water the soil directly, preferably in the morning.';
    }

    if (lower.contains('fertilizer') || lower.contains('food') || lower.contains('nutrient') || lower.contains('feed')) {
      return 'Hold off on heavy nitrogen fertilizers right now. Rapid new growth is extremely vulnerable to $disease. Focus on steady, balanced nutrients instead.';
    }

    if (lower.contains('thanks') || lower.contains('thank you')) {
      return 'You are very welcome! Let me know if you need any more tips on managing $disease or protecting your $crop harvest.';
    }

    return 'That is a great question about $disease. To give you the absolute best personalized advice, please configure a real Gemini API Key in the application code. In the meantime, ensure good airflow in your field and monitor the plant daily.';
  }
}
