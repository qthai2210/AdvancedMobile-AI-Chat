import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/core/network/api_service_factory.dart';
import 'package:dio/dio.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/core/network/api_service.dart';
import 'package:flutter/foundation.dart';

class PromptApiService {
  final ApiService _apiService;
  final Dio _dio;
  PromptApiService()
      : _dio = ApiServiceFactory.createJarvisDio(),
        _apiService = sl.get<ApiService>() {
    // Set the base URL for the Dio instance
    // _apiService.dio.options.baseUrl = ApiConfig.jarvisBaseUrl;
  }

  /// Refreshes the authentication header for this service
  Future<void> refreshAuthHeader() async {
    try {
      final authHeader = await _apiService.createAuthHeader();
      _dio.options.headers.addAll(authHeader);
      debugPrint('PromptApiService auth headers refreshed');
    } catch (e) {
      debugPrint('Error refreshing PromptApiService auth headers: $e');
    }
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
      final response = await _dio.get(
        '/prompts',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': accessToken,
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

  /// Danh sách category hợp lệ cho API
  final List<String> validCategories = [
    'business',
    'career',
    'creative',
    'chatbot',
    'personal',
    'coding',
    'education',
    'fun',
    'marketing',
    'productivity',
    'seo',
    'writing',
    'other',
  ];

  /// Tạo một prompt mới
  Future<PromptModel> createPrompt({
    required String accessToken,
    required String title,
    required String content,
    required String description,
    String? category,
    bool isPublic = false,
    String? language,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint('PromptApiService: Creating new prompt: $title');
      debugPrint('PromptApiService: Input category value: "$category"');

      // Chuẩn bị category - Đảm bảo gửi category hợp lệ hoặc null
      String? validCategory;
      if (category != null && category != 'all') {
        // Chuyển đổi thành chữ thường để khớp với API
        final lowercaseCategory = category.toLowerCase();
        debugPrint(
            'PromptApiService: Lowercase category: "$lowercaseCategory"');

        if (validCategories.contains(lowercaseCategory)) {
          validCategory = lowercaseCategory;
          debugPrint(
              'PromptApiService: Category "$lowercaseCategory" is valid');
        } else {
          validCategory = 'other'; // Sử dụng 'other' nếu không khớp
          debugPrint(
              'PromptApiService: Invalid category, using "other" instead');
        }
      } else {
        debugPrint(
            'PromptApiService: Category is null or "all", not including in request');
      }

      // Cấu hình headers
      final headers = {
        'Authorization': accessToken,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (xJarvisGuid != null) 'x-jarvis-guid': xJarvisGuid,
      };

      // Chuẩn bị request body
      final body = {
        'title': title,
        'content': content,
        'description': description,
        if (validCategory != null) 'category': validCategory,
        'isPublic': isPublic,
        if (language != null) 'language': language,
      };

      debugPrint('Request body: $body');

      // Gọi API
      final response = await _dio.post(
        '/prompts',
        options: Options(headers: headers),
        data: body,
      );

      // Kiểm tra response status
      if (response.statusCode == 201) {
        debugPrint('Successfully created prompt');
        // Chuyển đổi response data thành PromptModel
        return PromptModel.fromJson(response.data);
      } else {
        debugPrint(
            'Failed to create prompt: ${response.statusCode}, ${response.data}');
        throw {
          'code': 'CREATE_PROMPT_ERROR',
          'error': 'Không thể tạo prompt, vui lòng thử lại sau',
        };
      }
    } on DioException catch (e) {
      debugPrint(
          'createPrompt DioException: ${e.message}, ${e.response?.data}');

      // Xử lý lỗi cụ thể từ API
      if (e.response?.data != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          throw {
            'code': 'API_ERROR',
            'error': 'Lỗi: ${errorData['message']}',
          };
        }
      }

      // Xử lý lỗi 401 - Unauthorized
      if (e.response?.statusCode == 401) {
        throw {
          'code': 'UNAUTHORIZED',
          'error': 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại',
        };
      }

      throw {
        'code': 'NETWORK_ERROR',
        'error': 'Lỗi kết nối: ${e.message}',
      };
    } catch (e) {
      debugPrint('createPrompt error: $e');
      throw {
        'code': 'UNKNOWN_ERROR',
        'error': 'Đã xảy ra lỗi không xác định: $e',
      };
    }
  }

  /// Cập nhật một prompt hiện có
  Future<PromptModel> updatePrompt({
    required String accessToken,
    required String promptId,
    String? title,
    String? content,
    String? description,
    String? category,
    bool? isPublic,
    String? language,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint('=================================================');
      debugPrint('PromptApiService: UPDATING PROMPT');
      debugPrint('=================================================');
      debugPrint('PromptApiService: Prompt ID: $promptId');

      // Log input parameters
      debugPrint('PromptApiService: Input parameters:');
      debugPrint('PromptApiService: - Title: $title');
      debugPrint(
          'PromptApiService: - Description: ${description?.length ?? 0} chars');
      debugPrint('PromptApiService: - Content: ${content?.length ?? 0} chars');
      debugPrint('PromptApiService: - Category: $category');
      debugPrint('PromptApiService: - IsPublic: $isPublic');
      debugPrint('PromptApiService: - Language: $language');

      // Chuẩn bị category - Đảm bảo gửi category hợp lệ hoặc null
      String? validCategory;
      if (category != null && category != 'all') {
        // Chuyển đổi thành chữ thường để khớp với API
        final lowercaseCategory = category.toLowerCase();
        debugPrint(
            'PromptApiService: Lowercase category: "$lowercaseCategory"');

        if (validCategories.contains(lowercaseCategory)) {
          validCategory = lowercaseCategory;
          debugPrint(
              'PromptApiService: Category "$lowercaseCategory" is valid');
        } else {
          validCategory = 'other'; // Sử dụng 'other' nếu không khớp
          debugPrint(
              'PromptApiService: Invalid category, using "other" instead');
        }
      } else {
        debugPrint(
            'PromptApiService: Category is null or "all", not including in request');
      }

      // Cấu hình headers
      final headers = {
        'Authorization': accessToken,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (xJarvisGuid != null) 'x-jarvis-guid': xJarvisGuid,
      };

      debugPrint('PromptApiService: Headers:');
      final sanitizedHeaders = _sanitizeHeadersForLog(headers);
      sanitizedHeaders.forEach((key, value) {
        debugPrint('PromptApiService: - $key: $value');
      });

      // Chuẩn bị request body - chỉ gửi các trường có giá trị
      final body = <String, dynamic>{};

      if (title != null) body['title'] = title;
      if (content != null) body['content'] = content;
      if (description != null) body['description'] = description;
      if (validCategory != null) body['category'] = validCategory;
      if (isPublic != null) body['isPublic'] = isPublic;
      if (language != null) body['language'] = language;

      debugPrint('PromptApiService: Request body:');
      body.forEach((key, value) {
        if (key == 'content' && value is String) {
          debugPrint('PromptApiService: - $key: ${value.length} chars');
        } else {
          debugPrint('PromptApiService: - $key: $value');
        }
      });

      final fullUrl = '${_apiService.dio.options.baseUrl}/prompts/$promptId';
      debugPrint('PromptApiService: URL: $fullUrl');
      debugPrint('PromptApiService: HTTP Method: PATCH');

      // Gọi API
      final stopwatch = Stopwatch()..start();

      final response = await _dio.patch(
        '/prompts/$promptId',
        options: Options(headers: headers),
        data: body,
      );

      stopwatch.stop();
      debugPrint(
          'PromptApiService: Request completed in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint(
          'PromptApiService: Response status code: ${response.statusCode}');
      debugPrint(
          'PromptApiService: Response status message: ${response.statusMessage}');

      // Log response data
      if (response.data != null) {
        final responseStr = response.data is String
            ? response.data as String
            : response.data.toString();

        debugPrint('PromptApiService: Response data:');
        if (response.data is Map) {
          (response.data as Map).forEach((key, value) {
            if (key == 'content' && value is String) {
              debugPrint('PromptApiService: - $key: ${value.length} chars');
            } else {
              debugPrint('PromptApiService: - $key: $value');
            }
          });
        } else {
          debugPrint(
              'PromptApiService: ${_truncateResponseForLog(responseStr)}');
        }
      }

      // Kiểm tra response status
      if (response.statusCode == 200) {
        debugPrint('PromptApiService: Successfully updated prompt');
        // Chuyển đổi response data thành PromptModel
        final promptModel = PromptModel.fromJson(response.data);
        debugPrint('PromptApiService: Updated prompt details:');
        debugPrint('PromptApiService: - ID: ${promptModel.id}');
        debugPrint('PromptApiService: - Title: ${promptModel.title}');
        debugPrint('PromptApiService: - Category: ${promptModel.category}');
        debugPrint('PromptApiService: - IsPublic: ${promptModel.isPublic}');
        debugPrint('=================================================');
        return promptModel;
      } else {
        debugPrint(
            'PromptApiService: Failed to update prompt: ${response.statusCode}');
        debugPrint('=================================================');
        throw {
          'code': 'UPDATE_PROMPT_ERROR',
          'error': 'Không thể cập nhật prompt, vui lòng thử lại sau',
        };
      }
    } on DioException catch (e) {
      debugPrint(
          'PromptApiService: DioException occurred during updatePrompt:');
      debugPrint('PromptApiService: - Message: ${e.message}');
      debugPrint('PromptApiService: - URL: ${e.requestOptions.uri}');
      debugPrint('PromptApiService: - Method: ${e.requestOptions.method}');

      if (e.requestOptions.headers.isNotEmpty) {
        debugPrint('PromptApiService: - Request Headers:');
        final sanitizedHeaders =
            _sanitizeHeadersForLog(e.requestOptions.headers);
        sanitizedHeaders.forEach((key, value) {
          debugPrint('PromptApiService:   $key: $value');
        });
      }

      if (e.requestOptions.data != null) {
        debugPrint('PromptApiService: - Request Data:');
        if (e.requestOptions.data is Map) {
          (e.requestOptions.data as Map).forEach((key, value) {
            debugPrint('PromptApiService:   $key: $value');
          });
        } else {
          debugPrint('PromptApiService:   ${e.requestOptions.data}');
        }
      }

      debugPrint('PromptApiService: - Status code: ${e.response?.statusCode}');

      if (e.response?.data != null) {
        debugPrint('PromptApiService: - Response Data:');
        if (e.response?.data is Map) {
          (e.response?.data as Map).forEach((key, value) {
            debugPrint('PromptApiService:   $key: $value');
          });
        } else {
          final errorDataStr = e.response?.data is String
              ? e.response?.data as String
              : e.response?.data.toString();
          debugPrint(
              'PromptApiService:   ${_truncateResponseForLog(errorDataStr ?? "")}');
        }
      }

      // Xử lý lỗi cụ thể từ API
      if (e.response?.data != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          debugPrint(
              'PromptApiService: API error message: ${errorData['message']}');
          debugPrint('=================================================');
          throw {
            'code': 'API_ERROR',
            'error': 'Lỗi: ${errorData['message']}',
          };
        }
      }

      // Xử lý lỗi 401 - Unauthorized
      if (e.response?.statusCode == 401) {
        debugPrint('PromptApiService: Unauthorized error (401)');
        debugPrint('=================================================');
        throw {
          'code': 'UNAUTHORIZED',
          'error': 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại',
        };
      }

      debugPrint('=================================================');
      throw {
        'code': 'NETWORK_ERROR',
        'error': 'Lỗi kết nối: ${e.message}',
      };
    } catch (e) {
      debugPrint('PromptApiService: General error during updatePrompt:');
      debugPrint('PromptApiService: - Error: $e');
      debugPrint('PromptApiService: - Error type: ${e.runtimeType}');
      debugPrint('=================================================');
      throw {
        'code': 'UNKNOWN_ERROR',
        'error': 'Đã xảy ra lỗi không xác định: $e',
      };
    }
  }

  /// Xóa một prompt
  Future<bool> deletePrompt({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint('=================================================');
      debugPrint('PromptApiService: DELETING PROMPT');
      debugPrint('=================================================');
      debugPrint('PromptApiService: Prompt ID: $promptId');

      // Cấu hình headers
      final headers = {
        'Authorization': accessToken,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (xJarvisGuid != null) 'x-jarvis-guid': xJarvisGuid,
      };

      debugPrint('PromptApiService: Headers:');
      final sanitizedHeaders = _sanitizeHeadersForLog(headers);
      sanitizedHeaders.forEach((key, value) {
        debugPrint('PromptApiService: - $key: $value');
      });

      final fullUrl = '${_apiService.dio.options.baseUrl}/prompts/$promptId';
      debugPrint('PromptApiService: URL: $fullUrl');
      debugPrint('PromptApiService: HTTP Method: DELETE');

      // Gọi API
      final stopwatch = Stopwatch()..start();

      final response = await _dio.delete(
        '/prompts/$promptId',
        options: Options(headers: headers),
      );

      stopwatch.stop();
      debugPrint(
          'PromptApiService: Request completed in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint(
          'PromptApiService: Response status code: ${response.statusCode}');
      debugPrint(
          'PromptApiService: Response status message: ${response.statusMessage}');

      // Log response data
      if (response.data != null) {
        final responseStr = response.data is String
            ? response.data as String
            : response.data.toString();

        debugPrint('PromptApiService: Response data:');
        if (response.data is Map) {
          (response.data as Map).forEach((key, value) {
            debugPrint('PromptApiService: - $key: $value');
          });
        } else {
          debugPrint(
              'PromptApiService: ${_truncateResponseForLog(responseStr)}');
        }
      }

      // Kiểm tra response status
      if (response.statusCode == 200) {
        debugPrint('PromptApiService: Successfully deleted prompt');
        debugPrint('=================================================');
        return true;
      } else {
        debugPrint(
            'PromptApiService: Failed to delete prompt: ${response.statusCode}');
        debugPrint('=================================================');
        throw {
          'code': 'DELETE_PROMPT_ERROR',
          'error': 'Không thể xóa prompt, vui lòng thử lại sau',
        };
      }
    } on DioException catch (e) {
      debugPrint(
          'PromptApiService: DioException occurred during deletePrompt:');
      debugPrint('PromptApiService: - Message: ${e.message}');
      debugPrint('PromptApiService: - URL: ${e.requestOptions.uri}');
      debugPrint('PromptApiService: - Method: ${e.requestOptions.method}');

      if (e.requestOptions.headers.isNotEmpty) {
        debugPrint('PromptApiService: - Request Headers:');
        final sanitizedHeaders =
            _sanitizeHeadersForLog(e.requestOptions.headers);
        sanitizedHeaders.forEach((key, value) {
          debugPrint('PromptApiService:   $key: $value');
        });
      }

      if (e.requestOptions.data != null) {
        debugPrint('PromptApiService: - Request Data:');
        if (e.requestOptions.data is Map) {
          (e.requestOptions.data as Map).forEach((key, value) {
            debugPrint('PromptApiService:   $key: $value');
          });
        } else {
          debugPrint('PromptApiService:   ${e.requestOptions.data}');
        }
      }

      debugPrint('PromptApiService: - Status code: ${e.response?.statusCode}');

      if (e.response?.data != null) {
        debugPrint('PromptApiService: - Response Data:');
        if (e.response?.data is Map) {
          (e.response?.data as Map).forEach((key, value) {
            debugPrint('PromptApiService:   $key: $value');
          });
        } else {
          final errorDataStr = e.response?.data is String
              ? e.response?.data as String
              : e.response?.data.toString();
          debugPrint(
              'PromptApiService:   ${_truncateResponseForLog(errorDataStr ?? "")}');
        }
      }

      // Xử lý lỗi cụ thể từ API
      if (e.response?.data != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          debugPrint(
              'PromptApiService: API error message: ${errorData['message']}');
          debugPrint('=================================================');
          throw {
            'code': 'API_ERROR',
            'error': 'Lỗi: ${errorData['message']}',
          };
        }
      }

      // Xử lý lỗi 401 - Unauthorized
      if (e.response?.statusCode == 401) {
        debugPrint('PromptApiService: Unauthorized error (401)');
        debugPrint('=================================================');
        throw {
          'code': 'UNAUTHORIZED',
          'error': 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại',
        };
      }

      debugPrint('=================================================');
      throw {
        'code': 'NETWORK_ERROR',
        'error': 'Lỗi kết nối: ${e.message}',
      };
    } catch (e) {
      debugPrint('PromptApiService: General error during deletePrompt:');
      debugPrint('PromptApiService: - Error: $e');
      debugPrint('PromptApiService: - Error type: ${e.runtimeType}');
      debugPrint('=================================================');
      throw {
        'code': 'UNKNOWN_ERROR',
        'error': 'Đã xảy ra lỗi không xác định: $e',
      };
    }
  }

  /// Thêm prompt vào danh sách yêu thích
  Future<bool> addFavorite({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint('Adding prompt $promptId to favorites');

      // Cấu hình headers theo yêu cầu API
      final headers = {
        'Authorization': accessToken,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (xJarvisGuid != null) 'x-jarvis-guid': xJarvisGuid,
      };

      // Sửa URL - remove the duplicate api/v1
      final response = await _dio.post(
        'https://api.dev.jarvis.cx/api/v1/prompts/$promptId/favorite',
        options: Options(
          headers: headers, // Bỏ qua baseUrl của Dio
        ),
      );

      // Kiểm tra response status
      if (response.statusCode == 201) {
        debugPrint('Successfully added prompt to favorites');
        return true;
      } else {
        debugPrint(
            'Failed to add favorite: ${response.statusCode}, ${response.data}');
        throw {
          'code': 'FAVORITE_ERROR',
          'error': 'Không thể thêm vào yêu thích, vui lòng thử lại sau',
        };
      }
    } on DioException catch (e) {
      debugPrint('addFavorite DioException: ${e.message}, ${e.response?.data}');

      // Xử lý lỗi 401 - Unauthorized
      if (e.response?.statusCode == 401) {
        throw {
          'code': 'UNAUTHORIZED',
          'error': 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại'
        };
      }

      // Xử lý lỗi 404 - Not found
      if (e.response?.statusCode == 404) {
        throw {
          'code': 'NOT_FOUND',
          'error': 'Không tìm thấy prompt này hoặc URL không đúng'
        };
      }

      throw {'code': 'NETWORK_ERROR', 'error': 'Lỗi kết nối: ${e.message}'};
    } catch (e) {
      debugPrint('addFavorite error: $e');
      throw {
        'code': 'UNKNOWN_ERROR',
        'error': 'Đã xảy ra lỗi không xác định: $e'
      };
    }
  }

  /// Xóa prompt khỏi danh sách yêu thích
  Future<bool> removeFavorite({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint('Removing prompt $promptId from favorites');

      // Cấu hình headers theo yêu cầu API
      final headers = {
        'Authorization': accessToken,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (xJarvisGuid != null) 'x-jarvis-guid': xJarvisGuid,
      };

      // Sửa URL - remove the duplicate api/v1
      final response = await _dio.delete(
        'https://api.dev.jarvis.cx/api/v1/prompts/$promptId/favorite', // Đã sửa URL - không lặp lại api/v1
        options: Options(headers: headers),
      );

      // Kiểm tra response status
      if (response.statusCode == 200) {
        debugPrint('Successfully removed prompt from favorites');
        return true;
      } else {
        debugPrint(
            'Failed to remove favorite: ${response.statusCode}, ${response.data}');
        throw {
          'code': 'FAVORITE_ERROR',
          'error': 'Không thể xóa khỏi yêu thích, vui lòng thử lại sau',
        };
      }
    } on DioException catch (e) {
      debugPrint(
          'removeFavorite DioException: ${e.message}, ${e.response?.data}');

      // Xử lý lỗi 401 - Unauthorized
      if (e.response?.statusCode == 401) {
        throw {
          'code': 'UNAUTHORIZED',
          'error': 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại'
        };
      }

      // Xử lý lỗi 404 - Not found
      if (e.response?.statusCode == 404) {
        throw {
          'code': 'NOT_FOUND',
          'error': 'Không tìm thấy prompt này hoặc URL không đúng'
        };
      }

      throw {'code': 'NETWORK_ERROR', 'error': 'Lỗi kết nối: ${e.message}'};
    } catch (e) {
      debugPrint('removeFavorite error: $e');
      throw {
        'code': 'UNKNOWN_ERROR',
        'error': 'Đã xảy ra lỗi không xác định: $e'
      };
    }
  }

  Map<String, dynamic> _sanitizeHeadersForLog(Map<String, dynamic> headers) {
    final sanitizedHeaders = Map<String, dynamic>.from(headers);
    if (sanitizedHeaders.containsKey('Authorization')) {
      final authValue = sanitizedHeaders['Authorization']?.toString() ?? '';
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

class PromptRemoteDataSource {
  final Dio _client;
  PromptRemoteDataSource(this._client);

  Future<PromptModel> updatePrompt({
    required String accessToken,
    required String promptId,
    required String title,
    // ...
  }) async {
    debugPrint('📡 API: updatePrompt → endpoint: /prompts/$promptId');
    debugPrint('📡 API: payload: { title: $title, … }');
    final resp = await _client.patch(
      '/prompts/$promptId',
      data: {
        'title': title,
        // …
      },
      options: Options(headers: {
        'Authorization': 'Bearer $accessToken',
      }),
    );
    debugPrint('📡 API: updatePrompt response status=${resp.statusCode}');
    debugPrint('📡 API: updatePrompt body=${resp.data}');
    return PromptModel.fromJson(resp.data);
  }
}
