import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

/// Simple API client to communicate with the Express backend.
class ApiClient {
  final http.Client _client;
  String? _token;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setToken(String? token) {
    _token = token;
  }

  Future<String> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _token = data['token'] as String;
      return _token!;
    } else {
      throw Exception(data['error'] ?? 'Failed to login');
    }
  }

  Future<String> register(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      _token = data['token'] as String;
      return _token!;
    } else {
      throw Exception(data['error'] ?? 'Failed to register');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/transactions'),
      headers: _authHeaders(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['transactions'] as List<dynamic>;
      return List<Map<String, dynamic>>.from(list);
    } else {
      throw Exception('Failed to fetch transactions');
    }
  }

  Future<void> sendTransaction(Map<String, dynamic> payload) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/transactions'),
      headers: _authHeaders(),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save transaction');
    }
  }

  Map<String, String> _authHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}