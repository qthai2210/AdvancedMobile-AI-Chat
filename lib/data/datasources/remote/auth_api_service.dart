import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/data/models/auth/user_model.dart';

class AuthApiService {
  final http.Client client;
  final Map<String, String> _headers = ApiConfig.defaultHeaders;

  AuthApiService({required this.client});

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.authBaseUrl}/auth/password/sign-in');

    final body = {
      'email': email,
      'password': password,
    };

    final encodedBody = jsonEncode(body);

    try {
      // Log request details
      print('--------- API REQUEST: LOGIN ---------');
      print('URL: $uri');
      print('Headers: $_headers');
      print('Body: ${_sanitizeLoginBodyForLog(body)}');

      final response = await client
          .post(
            uri,
            headers: _headers,
            body: encodedBody,
          )
          .timeout(const Duration(seconds: 30));

      // Log response
      print('--------- API RESPONSE: LOGIN ---------');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${_truncateResponseForLog(response.body)}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['access_token'] == null ||
            data['refresh_token'] == null ||
            data['user_id'] == null) {
          throw InvalidResponseFormatException();
        }
        return UserModel.fromJson(data, email);
      } else {
        throw ServerException('Login failed: ${response.body}');
      }
    } catch (e) {
      print('--------- API ERROR: LOGIN ---------');
      print('Error: $e');
      if (e is InvalidResponseFormatException) {
        rethrow;
      }
      throw ServerException('Login request failed: $e');
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.authBaseUrl}/auth/password/sign-up');

    final body = {
      'email': email,
      'password': password,
      'verification_callback_url': 'aichatbot://verify',
    };

    final encodedBody = jsonEncode(body);

    try {
      // Log request details
      print('--------- API REQUEST: REGISTER ---------');
      print('URL: $uri');
      print('Headers: $_headers');
      print('Body: ${_sanitizeLoginBodyForLog(body)}');

      final response = await client
          .post(
            uri,
            headers: _headers,
            body: encodedBody,
          )
          .timeout(const Duration(seconds: 30));

      // Log response
      print('--------- API RESPONSE: REGISTER ---------');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${_truncateResponseForLog(response.body)}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['access_token'] == null ||
            data['refresh_token'] == null ||
            data['user_id'] == null) {
          throw InvalidResponseFormatException();
        }
        return UserModel.fromJson(data, email, name: name);
      } else {
        throw ServerException('Registration failed: ${response.body}');
      }
    } catch (e) {
      print('--------- API ERROR: REGISTER ---------');
      print('Error: $e');
      if (e is InvalidResponseFormatException) {
        rethrow;
      }
      throw ServerException('Registration request failed: $e');
    }
  }

  Future<void> logout({
    required String accessToken,
    String? refreshToken,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.authBaseUrl}/auth/sessions/current');

    final headers = {
      ..._headers,
      'Authorization': 'Bearer $accessToken',
    };

    if (refreshToken != null) {
      headers['X-Stack-Refresh-Token'] = refreshToken;
    }

    try {
      // Log request details
      print('--------- API REQUEST: LOGOUT ---------');
      print('URL: $uri');
      print('Headers: ${_sanitizeHeadersForLog(headers)}');
      print('Body: {}');

      final response = await client
          .delete(
            uri,
            headers: headers,
            body: '{}',
          )
          .timeout(const Duration(seconds: 10));

      // Log response
      print('--------- API RESPONSE: LOGOUT ---------');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw ServerException('Logout failed: ${response.body}');
      }
    } catch (e) {
      print('--------- API ERROR: LOGOUT ---------');
      print('Error: $e');
      throw ServerException('Logout request failed: $e');
    }
  }

  // Helper methods for logging
  Map<String, dynamic> _sanitizeLoginBodyForLog(Map<String, dynamic> body) {
    final sanitizedBody = Map<String, dynamic>.from(body);
    if (sanitizedBody.containsKey('password')) {
      sanitizedBody['password'] = '********';
    }
    return sanitizedBody;
  }

  Map<String, String> _sanitizeHeadersForLog(Map<String, String> headers) {
    final sanitizedHeaders = Map<String, String>.from(headers);
    if (sanitizedHeaders.containsKey('Authorization')) {
      final authValue = sanitizedHeaders['Authorization'] ?? '';
      if (authValue.length > 15) {
        sanitizedHeaders['Authorization'] = '${authValue.substring(0, 15)}...';
      }
    }
    return sanitizedHeaders;
  }

  String _truncateResponseForLog(String response) {
    const maxLength = 1000;
    if (response.length > maxLength) {
      return '${response.substring(0, maxLength)}...';
    }
    return response;
  }
}
