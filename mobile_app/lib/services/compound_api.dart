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
    final headers = token == null ? null : {'Authorization': 'Bearer $token'};
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as List<dynamic>;
    }
    return null;
  }

  static Future<List<dynamic>?> searchBySmiles(String smiles) async {
    final uri = Uri.parse('$baseUrl/api/module2/smiles?query=${Uri.encodeComponent(smiles)}');
    final token = await _auth.getValidAccessToken();
    final headers = token == null ? null : {'Authorization': 'Bearer $token'};
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as List<dynamic>;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getDetails(int id) async {
    final uri = Uri.parse('$baseUrl/api/module2/details/$id');
    final token = await _auth.getValidAccessToken();
    final headers = token == null ? null : {'Authorization': 'Bearer $token'};
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> resolveByName(String name) async {
    final uri = Uri.parse('$baseUrl/api/module2/resolve?name=${Uri.encodeComponent(name)}');
    final token = await _auth.getValidAccessToken();
    final headers = token == null ? null : {'Authorization': 'Bearer $token'};
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> saveAlias(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/module2/alias');
    final token = await _auth.getValidAccessToken();
    final headers = token == null ? {'Content-Type': 'application/json'} : {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final resp = await http.post(uri, headers: headers, body: json.encode(payload));
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getCompoundFull(String name) async {
    final uri = Uri.parse('$baseUrl/api/module2/compound/${Uri.encodeComponent(name)}');
    final token = await _auth.getValidAccessToken();
    final headers = token == null ? null : {'Authorization': 'Bearer $token'};
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }
}
