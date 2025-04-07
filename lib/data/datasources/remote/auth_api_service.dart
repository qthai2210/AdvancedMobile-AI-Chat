import 'dart:convert';
import 'package:aichatbot/core/config/api_config.dart';
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
    final response = await client.post(
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
        throw InvalidResponseFormatException();
      }
      return UserModel.fromJson(data, email);
    } else {
      throw ServerException('Login failed: ${response.body}');
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await client.post(
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
        throw InvalidResponseFormatException();
      }
      return UserModel.fromJson(data, email, name: name);
    } else {
      throw ServerException('Registration failed: ${response.body}');
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
      final response = await client
          .delete(
            Uri.parse('${ApiConfig.authBaseUrl}/auth/sessions/current'),
            headers: headers,
            body: '{}',
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ServerException('Logout failed: ${response.body}');
      }
    } catch (e) {
      throw ServerException('Logout request failed: $e');
    }
  }
}
