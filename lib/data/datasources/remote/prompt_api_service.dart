import 'package:aichatbot/core/config/api_config.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:dio/dio.dart';

import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/core/network/api_service.dart';

class PromptApiService {
  final ApiService _apiService = sl.get<ApiService>();
  PromptApiService() {
    // Set the base URL for the Dio instance
    _apiService.dio.options.baseUrl = ApiConfig.jarvisBaseUrl;
  }
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
    final queryParams = <String, dynamic>{};
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (offset != null) queryParams['offset'] = offset;
    if (limit != null) queryParams['limit'] = limit;
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all')
      queryParams['category'] = category.toLowerCase();
    if (isFavorite != null) queryParams['isFavorite'] = isFavorite;
    if (isPublic != null) queryParams['isPublic'] = isPublic;

    try {
      final response = await _apiService.dio.get(
        '/prompts',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        ),
      );

      return _apiService.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      final exception = _apiService.handleError(e);
      throw exception;
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
    final headers = {
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

    try {
      final response = await _apiService.dio.post(
        '/prompts',
        data: body,
        options: Options(headers: headers),
      );

      return _apiService.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      final exception = _apiService.handleError(e);
      throw exception;
    }
  }

  Future<PromptModel> updatePrompt({
    required String accessToken,
    required String promptId,
    required Map<String, dynamic> promptData,
  }) async {
    try {
      final response = await _apiService.dio.put(
        '/prompts/$promptId',
        data: promptData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      return _apiService.handleResponse<PromptModel>(
        response,
        (data) => PromptModel.fromJson(data),
      );
    } catch (e) {
      final exception = _apiService.handleError(e);
      throw exception;
    }
  }

  Future<void> deletePrompt({
    required String accessToken,
    required String promptId,
  }) async {
    try {
      final response = await _apiService.dio.delete(
        '/prompts/$promptId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      _apiService.handleResponse<void>(
        response,
        (_) {}, // No data to return for successful delete
      );
    } catch (e) {
      final exception = _apiService.handleError(e);
      throw exception;
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
