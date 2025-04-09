import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';

class PromptApiService {
  final http.Client client;
  final Map<String, String> _headers = ApiConfig.defaultHeaders;

  PromptApiService({required this.client});

  // Phương thức lấy danh sách prompts
  Future<Map<String, dynamic>> getPrompts({
    required String accessToken,
    String? query,
    int? offset,
    int? limit,
    String? category,
    bool? isFavorite,
    bool? isPublic,
  }) async {
    // Build query parameters
    final queryParams = <String, String>{};
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (offset != null) queryParams['offset'] = offset.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all')
      queryParams['category'] = category.toLowerCase();
    if (isFavorite != null) queryParams['isFavorite'] = isFavorite.toString();
    if (isPublic != null) queryParams['isPublic'] = isPublic.toString();

    final Uri uri = Uri.parse('${ApiConfig.jarvisBaseUrl}/prompts')
        .replace(queryParameters: queryParams);

    final headers = {
      ..._headers,
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };

    try {
      // Logging API details for debugging
      print('--------- API REQUEST: GET PROMPTS ---------');
      print('URL: $uri');
      print('Headers: ${_sanitizeHeadersForLog(headers)}');
      print('Query Parameters: $queryParams');

      final response = await client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      // Log response
      print('--------- API RESPONSE: GET PROMPTS ---------');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${_truncateResponseForLog(response.body)}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Sửa lỗi ở đây - tạo đối tượng mới của UnauthorizedException
        throw UnauthorizedException('Unauthorized: ${response.body}');
      } else {
        throw ServerException('Failed to get prompts: ${response.body}');
      }
    } catch (e) {
      print('--------- API ERROR: GET PROMPTS ---------');
      print('Error: $e');

      if (e is UnauthorizedException || e is ServerException) {
        rethrow;
      }
      throw ServerException('Failed to get prompts: $e');
    }
  }

  // Phương thức để tạo một prompt mới
  Future<Map<String, dynamic>> createPrompt({
    required String accessToken,
    required String title,
    required String content,
    required String description,
    required String category,
    required bool isPublic,
    required String language,
    String? xJarvisGuid,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.jarvisBaseUrl}/prompts');

    final headers = {
      ..._headers,
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Thêm x-jarvis-guid header nếu được cung cấp
    if (xJarvisGuid != null) {
      headers['x-jarvis-guid'] = xJarvisGuid;
    }

    final body = {
      'title': title,
      'content': content,
      'description': description,
      'category': category.toLowerCase(),
      'isPublic': isPublic,
      'language': language,
    };

    final encodedBody = jsonEncode(body);

    try {
      // Log request details
      print('--------- API REQUEST: CREATE PROMPT ---------');
      print('URL: $uri');
      print('Headers: ${_sanitizeHeadersForLog(headers)}');
      print('Body: $body');

      final response = await client
          .post(
            uri,
            headers: headers,
            body: encodedBody,
          )
          .timeout(const Duration(seconds: 30));

      // Log response
      print('--------- API RESPONSE: CREATE PROMPT ---------');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${_truncateResponseForLog(response.body)}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Unauthorized: ${response.body}');
      } else {
        throw ServerException(
            'Failed to create prompt (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('--------- API ERROR: CREATE PROMPT ---------');
      print('Error: $e');

      if (e is UnauthorizedException || e is ServerException) {
        rethrow;
      }
      throw ServerException('Failed to create prompt: $e');
    }
  }

  Future<PromptModel> updatePrompt({
    required String accessToken,
    required String promptId,
    required Map<String, dynamic> promptData,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.jarvisBaseUrl}/prompts/$promptId');

    final headers = {
      ..._headers,
      'Authorization': 'Bearer $accessToken',
    };

    final encodedBody = jsonEncode(promptData);

    try {
      // Log request details
      print('--------- API REQUEST: UPDATE PROMPT ---------');
      print('URL: $uri');
      print('Headers: ${_sanitizeHeadersForLog(headers)}');
      print('Body: $promptData');

      final response = await client
          .put(
            uri,
            headers: headers,
            body: encodedBody,
          )
          .timeout(const Duration(seconds: 30));

      // Log response
      print('--------- API RESPONSE: UPDATE PROMPT ---------');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${_truncateResponseForLog(response.body)}');

      if (response.statusCode == 200) {
        return PromptModel.fromJson(jsonDecode(response.body));
      } else {
        throw ServerException('Failed to update prompt: ${response.body}');
      }
    } catch (e) {
      print('--------- API ERROR: UPDATE PROMPT ---------');
      print('Error: $e');
      throw ServerException('Failed to update prompt: $e');
    }
  }

  Future<void> deletePrompt({
    required String accessToken,
    required String promptId,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.jarvisBaseUrl}/prompts/$promptId');

    final headers = {
      ..._headers,
      'Authorization': 'Bearer $accessToken',
    };

    try {
      // Log request details
      print('--------- API REQUEST: DELETE PROMPT ---------');
      print('URL: $uri');
      print('Headers: ${_sanitizeHeadersForLog(headers)}');

      final response = await client
          .delete(
            uri,
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      // Log response
      print('--------- API RESPONSE: DELETE PROMPT ---------');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${_truncateResponseForLog(response.body)}');

      if (response.statusCode != 204) {
        throw ServerException('Failed to delete prompt: ${response.body}');
      }
    } catch (e) {
      print('--------- API ERROR: DELETE PROMPT ---------');
      print('Error: $e');
      throw ServerException('Failed to delete prompt: $e');
    }
  }

  // Helper methods for logging
  Map<String, String> _sanitizeHeadersForLog(Map<String, String> headers) {
    final sanitizedHeaders = Map<String, String>.from(headers);
    if (sanitizedHeaders.containsKey('Authorization')) {
      final authValue = sanitizedHeaders['Authorization'] ?? '';
      if (authValue.length > 15) {
        sanitizedHeaders['Authorization'] = '${authValue.substring(0, 15)}***';
      }
    }
    return sanitizedHeaders;
  }

  String _truncateResponseForLog(String response) {
    if (response.length > 500) {
      return '${response.substring(0, 500)}... (truncated, total length: ${response.length})';
    }
    return response;
  }
}
