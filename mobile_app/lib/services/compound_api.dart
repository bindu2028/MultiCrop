import 'dart:convert';
import 'package:http/http.dart' as http;

import 'network_config.dart';
import 'auth_service.dart';

class CompoundApi {
  static final String baseUrl = resolveApiBaseUrl();
  static final AuthService _auth = AuthService();

  static Future<List<dynamic>?> searchByName(String name) async {
    final uri = Uri.parse('$baseUrl/api/module2/search?name=${Uri.encodeComponent(name)}');
    final token = await _auth.getValidAccessToken();
    if (token == null) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    final headers = {'Authorization': 'Bearer $token'};
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as List<dynamic>;
    }
    if (resp.statusCode == 401) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    throw Exception('Server returned error ${resp.statusCode}. Please try again later.');
  }

  static Future<List<dynamic>?> searchBySmiles(String smiles) async {
    final uri = Uri.parse('$baseUrl/api/module2/smiles?query=${Uri.encodeComponent(smiles)}');
    final token = await _auth.getValidAccessToken();
    if (token == null) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    final headers = {'Authorization': 'Bearer $token'};
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as List<dynamic>;
    }
    if (resp.statusCode == 401) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    throw Exception('Server returned error ${resp.statusCode}. Please try again later.');
  }

  static Future<Map<String, dynamic>?> getDetails(int id) async {
    final uri = Uri.parse('$baseUrl/api/module2/details/$id');
    final token = await _auth.getValidAccessToken();
    if (token == null) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    final headers = {'Authorization': 'Bearer $token'};
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    if (resp.statusCode == 401) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    throw Exception('Server returned error ${resp.statusCode}. Please try again later.');
  }

  static Future<Map<String, dynamic>?> resolveByName(String name) async {
    final uri = Uri.parse('$baseUrl/api/module2/resolve?name=${Uri.encodeComponent(name)}');
    final token = await _auth.getValidAccessToken();
    if (token == null) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    final headers = {'Authorization': 'Bearer $token'};
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    if (resp.statusCode == 401) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    throw Exception('Server returned error ${resp.statusCode}. Please try again later.');
  }

  static Future<Map<String, dynamic>?> saveAlias(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/module2/alias');
    final token = await _auth.getValidAccessToken();
    if (token == null) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final resp = await http.post(uri, headers: headers, body: json.encode(payload));
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    if (resp.statusCode == 401) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    throw Exception('Server returned error ${resp.statusCode}. Please try again later.');
  }

  static Future<Map<String, dynamic>?> getCompoundFull(String name) async {
    final uri = Uri.parse('$baseUrl/api/module2/compound/${Uri.encodeComponent(name)}');
    final token = await _auth.getValidAccessToken();
    if (token == null) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    final headers = {'Authorization': 'Bearer $token'};
    final resp = await http.get(uri, headers: headers);
    
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    
    if (resp.statusCode == 401) {
      throw Exception('Session expired. Please sign out and sign in again.');
    }
    
    throw Exception('Server returned error ${resp.statusCode}. Please try again later.');
  }
}
