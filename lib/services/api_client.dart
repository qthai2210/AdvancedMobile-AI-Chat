import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aichatbot/config/api_config.dart';

class ApiClient {
  final Map<String, String> _headers = ApiConfig.defaultHeaders;

  // Auth API methods
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authBaseUrl}/auth/password/sign-up'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'verification_callback_url': 'aichatbot://verify',
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['access_token'] == null ||
          data['refresh_token'] == null ||
          data['user_id'] == null) {
        throw Exception('Invalid response format');
      }
      return data;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authBaseUrl}/auth/password/sign-in'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['access_token'] == null ||
          data['refresh_token'] == null ||
          data['user_id'] == null) {
        throw Exception('Invalid response format');
      }
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> logout({
    required String accessToken,
    String? refreshToken,
  }) async {
    final headers = {
      ..._headers,
      'Authorization': 'Bearer $accessToken',
    };

    if (refreshToken != null) {
      headers['X-Stack-Refresh-Token'] = refreshToken;
    }

    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.authBaseUrl}/auth/sessions/current'),
            headers: headers,
            body: '{}',
          )
          .timeout(const Duration(seconds: 10)); // Add a reasonable timeout

      // Print response for debugging
      print('Logout response: ${response.statusCode}, ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Logout failed: ${response.body}');
      }
    } catch (e) {
      print('Logout exception: $e');
      // Rethrow to be handled by the bloc
      throw Exception('Logout request failed: $e');
    }
  }

  // Jarvis API methods
  Future<Map<String, dynamic>> jarvisApiCall(
    String endpoint, {
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.jarvisBaseUrl}/$endpoint'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API call failed: ${response.body}');
    }
  }

  // Knowledge base API methods
  Future<Map<String, dynamic>> knowledgeBaseApiCall(
    String endpoint, {
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.knowledgeBaseUrl}/$endpoint'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API call failed: ${response.body}');
    }
  }
}
