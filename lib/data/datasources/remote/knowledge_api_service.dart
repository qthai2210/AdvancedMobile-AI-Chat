import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:aichatbot/core/network/api_service.dart';
import 'package:aichatbot/core/network/api_service_factory.dart';
import 'package:aichatbot/data/models/knowledge/create_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_list_response.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:aichatbot/data/models/knowledge/get_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/get_knowledge_units_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_unit_list_response.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

/// Service for interacting with Knowledge-related API endpoints
class KnowledgeApiService {
  final ApiService _apiService;
  final Dio _dio;
  late final Dio _uploadDio; // New Dio instance specifically for file uploads

  /// Creates a new instance of [KnowledgeApiService]
  KnowledgeApiService()
      : _apiService = sl.get<ApiService>(),
        _dio = ApiServiceFactory.createKnowledgeDio() {
    // Set the base URL for the Dio instance
    //_apiService.dio.options.baseUrl = ApiConfig.jarvisBaseUrl;
    AppLogger.e(
        "KnowledgeApiService initialized with base URL: ${_apiService.dio.options.headers}");
    AppLogger.e("12312321: ${_dio.options.baseUrl}");

    // Initialize the upload-specific Dio instance with same baseUrl but clean headers
    _uploadDio = Dio(BaseOptions(
      baseUrl: _dio.options.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));
  }

  /// Fetches knowledge items from the API based on the provided parameters
  Future<KnowledgeListResponse> getKnowledges(GetKnowledgeParams params) async {
    try {
      // Prepare headers - including the Authorization token and optional x-jarvis-guid
      //  final headers = <String, dynamic>{};

      // Add authorization token if available
      //final prefs = await sl.getAsync();
      // final token = prefs.getString('token');
      // if (token != null && token.isNotEmpty) {
      //   headers['Authorization'] = 'Bearer $token';
      // }

      // Add x-jarvis-guid if available
      // final guid = prefs.getString('x-jarvis-guid');
      // if (guid != null && guid.isNotEmpty) {
      //   headers['x-jarvis-guid'] = guid;
      // }

      // Log the request with detailed information
      final endpoint = '/kb-core/v1/knowledge';
      final url = '${_dio.options.baseUrl}$endpoint';

      AppLogger.d(
          '┌── KNOWLEDGE API REQUEST ──────────────────────────────────');
      AppLogger.d('│ 🔍 [GET] Knowledge List');
      AppLogger.d('│ URL: $url');
      AppLogger.d('│ Parameters: ${params.toQueryParameters()}');
      AppLogger.d('│ Headers: ${_dio.options.headers}');
      AppLogger.d(
          '└────────────────────────────────────────────────────────────');

      // Make the API call
      final response = await _dio.get(
        endpoint,
        //queryParameters: params.toQueryParameters(),
        // options: Options(headers: headers),
      );

      // Log the response with detailed information
      AppLogger.d(
          '┌── KNOWLEDGE API RESPONSE ─────────────────────────────────');
      AppLogger.d('│ 🔍 [GET] Knowledge List');
      AppLogger.d('│ Status: ${response.statusCode}');
      AppLogger.d(
          '│ Data: Knowledge items count: ${response.data['data']?.length ?? 0}');
      AppLogger.d(
          '└────────────────────────────────────────────────────────────');

      // Parse and return the response
      return KnowledgeListResponse.fromJson(response.data);
    } catch (e) {
      AppLogger.e('Error fetching knowledges: $e');
      rethrow;
    }
  }

  /// Creates a new knowledge base with the provided parameters
  ///
  /// [params] contains the required knowledge name and optional description
  /// Returns the created [KnowledgeModel] on success
  Future<KnowledgeModel> createKnowledge(CreateKnowledgeParams params) async {
    try {
      // Prepare headers for the x-jarvis-guid if provided
      final headers = <String, dynamic>{};
      if (params.xJarvisGuid != null && params.xJarvisGuid!.isNotEmpty) {
        headers['x-jarvis-guid'] = params.xJarvisGuid;
      }

      // Log the request
      AppLogger.d('Creating knowledge base with name: ${params.knowledgeName}');

      // Make the API call
      final response = await _dio.post(
        '/kb-core/v1/knowledge',
        data: params.toJson(),
        options: Options(headers: headers.isNotEmpty ? headers : null),
      );

      // Log the response
      AppLogger.i('Knowledge base created successfully: ${response.data}');

      // Parse and return the created knowledge model
      return KnowledgeModel.fromJson(response.data);
    } catch (e) {
      AppLogger.e('Error creating knowledge base: $e');
      rethrow;
    }
  }

  Future<KnowledgeModel> updateKnowledge(
      String id, CreateKnowledgeParams params) async {
    try {
      // Prepare headers for the x-jarvis-guid if provided
      final headers = <String, dynamic>{};
      if (params.xJarvisGuid != null && params.xJarvisGuid!.isNotEmpty) {
        headers['x-jarvis-guid'] = params.xJarvisGuid;
      }

      // Log the request
      AppLogger.d('Creating knowledge base with name: ${params.knowledgeName}');

      // Make the API call
      final response = await _dio.patch(
        '/kb-core/v1/knowledge/$id',
        data: params.toJson(),
        options: Options(headers: headers.isNotEmpty ? headers : null),
      );

      // Log the response
      AppLogger.i('Knowledge base updated successfully: ${response.data}');

      // Parse and return the created knowledge model
      return KnowledgeModel.fromJson(response.data);
    } catch (e) {
      AppLogger.e('Error updating knowledge base: $e');
      rethrow;
    }
  }

  /// Deletes a knowledge base with the provided ID
  ///
  /// [id] - The ID of the knowledge base to delete
  /// [xJarvisGuid] - Optional GUID for tracking purposes
  /// Returns a boolean indicating success
  Future<bool> deleteKnowledge(String id, {String? xJarvisGuid}) async {
    try {
      // Prepare headers for the x-jarvis-guid if provided
      final headers = <String, dynamic>{};
      if (xJarvisGuid != null && xJarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = xJarvisGuid;
      }

      // Log the request with detailed information
      final endpoint = '/kb-core/v1/knowledge/$id';
      final url = '${_dio.options.baseUrl}$endpoint';

      AppLogger.d(
          '┌── KNOWLEDGE API REQUEST ──────────────────────────────────');
      AppLogger.d('│ 🔍 [DELETE] Knowledge');
      AppLogger.d('│ URL: $url');
      AppLogger.d('│ Knowledge ID: $id');
      AppLogger.d(
          '│ Headers: ${headers.isNotEmpty ? headers : "Default headers"}');
      AppLogger.d(
          '└────────────────────────────────────────────────────────────');

      // Make the API call
      final response = await _dio.delete(
        endpoint,
        options: Options(headers: headers.isNotEmpty ? headers : null),
      );

      // Log the response with detailed information
      AppLogger.d(
          '┌── KNOWLEDGE API RESPONSE ─────────────────────────────────');
      AppLogger.d('│ 🔍 [DELETE] Knowledge');
      AppLogger.d('│ Status: ${response.statusCode}');
      AppLogger.d(
          '└────────────────────────────────────────────────────────────');

      // Return success based on status code (200 is success)
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.e('Error deleting knowledge base: $e');
      rethrow;
    }
  }

  /// Fetches units of a knowledge base with the provided ID
  ///
  /// [params] - Parameters for fetching units including knowledgeId, pagination, etc.
  /// Returns a [KnowledgeUnitListResponse] containing the units and metadata
  Future<KnowledgeUnitListResponse> getKnowledgeUnits(
      GetKnowledgeUnitsParams params) async {
    try {
      // Prepare headers
      final headers = <String, dynamic>{};

      // Add authorization token if available
      if (params.accessToken != null && params.accessToken!.isNotEmpty) {
        headers['Authorization'] = '${params.accessToken}';
      }

      // Add x-jarvis-guid if available
      if (params.xJarvisGuid != null && params.xJarvisGuid!.isNotEmpty) {
        headers['x-jarvis-guid'] = params.xJarvisGuid;
      }

      // Log the request with detailed information
      final endpoint = '/kb-core/v1/knowledge/${params.knowledgeId}/units';
      final url = '${_dio.options.baseUrl}$endpoint';

      AppLogger.d(
          '┌── KNOWLEDGE API REQUEST ──────────────────────────────────');
      AppLogger.d('│ 🔍 [GET] Knowledge Units');
      AppLogger.d('│ URL: $url');
      AppLogger.d('│ Knowledge ID: ${params.knowledgeId}');
      AppLogger.d('│ Parameters: ${params.toQueryParameters()}');
      AppLogger.d(
          '│ Headers: ${headers.isNotEmpty ? headers : "Default headers"}');
      AppLogger.d(
          '└────────────────────────────────────────────────────────────');

      // Make the API call
      final response = await _dio.get(
        endpoint,
        queryParameters: params.toQueryParameters(),
        options: Options(headers: headers.isNotEmpty ? headers : null),
      );

      // Log the response with detailed information
      AppLogger.d(
          '┌── KNOWLEDGE API RESPONSE ─────────────────────────────────');
      AppLogger.d('│ 🔍 [GET] Knowledge Units');
      AppLogger.d('│ Status: ${response.statusCode}');
      AppLogger.d('│ Data: Units count: ${response.data['data']?.length ?? 0}');
      AppLogger.d(
          '└────────────────────────────────────────────────────────────');

      // Parse and return the response
      return KnowledgeUnitListResponse.fromJson(response.data);
    } catch (e) {
      AppLogger.e('Error fetching knowledge units: $e');
      rethrow;
    }
  }

  /// Checks if the given file is of a supported MIME type
  ///
  /// Returns the appropriate MIME type if supported, otherwise returns null
  String? _getSupportedMimeType(File file) {
    final extension = p.extension(file.path).toLowerCase();

    // Mapping of file extensions to supported MIME types
    final mimeTypes = {
      '.c': 'text/x-c',
      '.cpp': 'text/x-c++',
      '.docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      '.html': 'text/html',
      '.java': 'text/x-java',
      '.json': 'application/json',
      '.md': 'text/markdown',
      '.pdf': 'application/pdf',
      '.php': 'text/x-php',
      '.pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      '.py': 'text/x-python',
      '.rb': 'text/x-ruby',
      '.tex': 'text/x-tex',
      '.txt': 'text/plain',
    };

    return mimeTypes[extension];
  }

  /// Uploads a local file to the knowledge base
  ///
  /// [knowledgeId] - The ID of the knowledge base
  /// [file] - The file to upload
  /// [accessToken] - The user's access token for authentication
  Future<FileUploadResponse> uploadLocalFile({
    required String knowledgeId,
    required File file,
    required String accessToken,
    String? guid,
  }) async {
    try {
      // Check if the file type is supported
      final mimeType = _getSupportedMimeType(file);
      if (mimeType == null) {
        // If file type is not supported, throw an exception
        final extension = p.extension(file.path);
        throw Exception(
            'Unsupported file type: $extension. Supported file types include: .c, .cpp, .docx, .html, .java, .json, .md, .pdf, .php, .pptx, .py, .rb, .tex, .txt');
      }

      // Create form data with the file and specify the correct MIME type
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: p.basename(file.path),
          contentType: MediaType.parse(mimeType),
        ),
      });

      // Prepare headers specifically for this upload request
      final headers = <String, dynamic>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      };

      // Add guid header if provided
      if (guid != null && guid.isNotEmpty) {
        headers['x-jarvis-guid'] = guid;
      }

      // Log the request with detailed information
      final endpoint = '/kb-core/v1/knowledge/$knowledgeId/local-file';
      final url = '${_uploadDio.options.baseUrl}$endpoint';
      final fileName = file.path.split('/').last;

      AppLogger.d(
          '┌── KNOWLEDGE API REQUEST ──────────────────────────────────');
      AppLogger.d('│ 🔍 [POST] Upload File');
      AppLogger.d('│ URL: $url');
      AppLogger.d('│ Knowledge ID: $knowledgeId');
      AppLogger.d('│ File: $fileName');
      AppLogger.d('│ Headers: $headers');
      AppLogger.d(
          '└────────────────────────────────────────────────────────────');
      AppLogger.d('FormData: $formData');

      // Make the API call using the upload-specific Dio instance
      final response = await _uploadDio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: headers,
          contentType: 'multipart/form-data',
        ),
      );
      // log formdata

      // Log the response with detailed information
      AppLogger.d(
          '┌── KNOWLEDGE API RESPONSE ─────────────────────────────────');
      AppLogger.d('│ 🔍 [POST] Upload File');
      AppLogger.d('│ Status: ${response.statusCode}');
      AppLogger.d('│ Filename: $fileName');
      AppLogger.d('│ Response data: ${response.data}');
      AppLogger.d(
          '└────────────────────────────────────────────────────────────');

      // Parse and return the response
      return FileUploadResponse.fromJson(response.data);
    } catch (e) {
      // Log the error
      AppLogger.e('Error uploading file: $e');
      AppLogger.e(
          '┌── KNOWLEDGE API ERROR ───────────────────────────────────');
      AppLogger.e('│ 🔴 API Call Failed');
      AppLogger.e('│ Error: $e');
      if (e is DioException) {
        AppLogger.e('│ Status Code: ${e.response?.statusCode}');
        AppLogger.e('│ Response: ${e.response?.data}');
      }
      AppLogger.e(
          '└────────────────────────────────────────────────────────────');
      // Handle specific DioException with more details
      if (e is DioException) {
        throw Exception(
            'Failed to upload file: ${e.response?.data ?? e.message}');
      }

      // Rethrow for general exceptions
      rethrow;
    }
  }

  /// Uploads a Google Drive file to the knowledge base
  ///
  /// [knowledgeId] - The ID of the knowledge base
  /// [accessToken] - The user's access token for authentication
  /// [formData] - multipart/form-data with required fields
  Future<FileUploadResponse> uploadGoogleDriveFile({
    required String knowledgeId,
    required String id,
    required String name,
    required bool status,
    required String userId,
    required String createdAt,
    String? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? accessToken,
  }) async {
    final url = '/kb-core/v1/knowledge/$knowledgeId/google-drive';

    try {
      final formData = FormData.fromMap({
        'id': id,
        'name': name,
        'status': status,
        'userId': userId,
        'knowledgeId': knowledgeId,
        'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
        if (createdBy != null) 'createdBy': createdBy,
        if (updatedBy != null) 'updatedBy': updatedBy,
      });

      final headers = <String, dynamic>{
        if (accessToken != null && accessToken.isNotEmpty)
          'x-jarvis-guid': accessToken,
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      };

      final response = await _uploadDio.post(
        url,
        data: formData,
        options: Options(
          headers: headers,
        ),
      );

      return FileUploadResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to upload Google Drive file: $e');
    }
  }

  /// Uploads a Slack source to the knowledge base
  Future<FileUploadResponse> uploadSlackSource({
    required String knowledgeId,
    required String unitName,
    required String slackWorkspace,
    required String slackBotToken,
    String? accessToken,
  }) async {
    final url = '/kb-core/v1/knowledge/$knowledgeId/slack';

    final body = {
      'unitName': unitName,
      'slackWorkspace': slackWorkspace,
      'slackBotToken': slackBotToken,
    };

    final headers = <String, dynamic>{
      if (accessToken != null && accessToken.isNotEmpty)
        'x-jarvis-guid': accessToken,
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };

    final response = await _uploadDio.post(
      url,
      data: body,
      options: Options(headers: headers),
    );

    return FileUploadResponse.fromJson(response.data);
  }

  /// Uploads a Confluence source to the knowledge base
  Future<FileUploadResponse> uploadConfluenceSource({
    required String knowledgeId,
    required String unitName,
    required String wikiPageUrl,
    required String confluenceUsername,
    required String confluenceAccessToken,
    String? accessToken,
  }) async {
    final url = '/kb-core/v1/knowledge/$knowledgeId/confluence';

    final body = {
      'unitName': unitName,
      'wikiPageUrl': wikiPageUrl,
      'confluenceUsername': confluenceUsername,
      'confluenceAccessToken': confluenceAccessToken,
    };

    final headers = <String, dynamic>{
      if (accessToken != null && accessToken.isNotEmpty)
        'x-jarvis-guid': accessToken,
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };

    final response = await _uploadDio.post(
      url,
      data: body,
      options: Options(headers: headers),
    );
    return FileUploadResponse.fromJson(response.data);
  }

  Future<FileUploadResponse> uploadWebSource({
    required String knowledgeId,
    required String unitName,
    required String webUrl,
    required String accessToken,
  }) async {
    final endpoint = '/kb-core/v1/knowledge/$knowledgeId/web';
    final body = {
      'unitName': unitName,
      'webUrl': webUrl,
    };
    final headers = {
      'x-jarvis-guid': accessToken,
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final response = await _dio.post(
      endpoint,
      data: body,
      options: Options(headers: headers),
    );
    if (response.statusCode == 201) {
      return FileUploadResponse.fromJson(response.data);
    } else {
      throw Exception('Upload website failed: ${response.statusCode}');
    }
  }
}
