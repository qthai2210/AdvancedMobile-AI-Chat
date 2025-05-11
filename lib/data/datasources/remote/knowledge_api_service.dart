import 'dart:io';
import 'package:aichatbot/data/models/knowledge/uploaded_file_model.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
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

  /// Fetches knowledge bases attached to a specific assistant
  ///
  /// [assistantId] is required to identify the assistant
  /// [params] contains optional query parameters for filtering and pagination
  /// Returns a [KnowledgeListResponse] containing the list of knowledge bases and metadata
  Future<KnowledgeListResponse> getAssistantKnowledges({
    required String assistantId,
    String? q,
    String? order = "DESC",
    String? orderField = "createdAt",
    int offset = 0,
    int limit = 10,
    String? xJarvisGuid,
    String? accessToken,
  }) async {
    try {
      // Prepare headers for authorization and x-jarvis-guid if provided
      final headers = <String, dynamic>{};
      if (xJarvisGuid != null && xJarvisGuid.isNotEmpty) {
        headers['x-jarvis-guid'] = xJarvisGuid;
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      // Prepare query parameters
      final queryParams = <String, dynamic>{};
      if (q != null && q.isNotEmpty) queryParams['q'] = q;
      if (order != null) queryParams['order'] = order;
      if (orderField != null) queryParams['order_field'] = orderField;
      queryParams['offset'] = offset.toString();
      queryParams['limit'] = limit.toString();

      // Log the request with detailed information
      final endpoint = '/kb-core/v1/ai-assistant/$assistantId/knowledges';
      final url = '${_dio.options.baseUrl}$endpoint';

      AppLogger.d(
          '┌── KNOWLEDGE API REQUEST ──────────────────────────────────');
      AppLogger.d('│ 🔍 [GET] Assistant Knowledge Bases');
      AppLogger.d('│ URL: $url');
      AppLogger.d('│ Assistant ID: $assistantId');
      AppLogger.d('│ Parameters: $queryParams');
      AppLogger.d(
          '│ Headers: ${headers.isNotEmpty ? headers : "Default headers"}');
      AppLogger.d(
          '└────────────────────────────────────────────────────────────');

      // Make the API call
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: headers.isNotEmpty ? headers : null),
      );

      // Log the response with detailed information
      AppLogger.d(
          '┌── KNOWLEDGE API RESPONSE ─────────────────────────────────');
      AppLogger.d('│ 🔍 [GET] Assistant Knowledge Bases');
      AppLogger.d('│ Status: ${response.statusCode}');
      AppLogger.d(
          '│ Data: Knowledge items count: ${response.data['data']?.length ?? 0}');
      AppLogger.d(
          '└────────────────────────────────────────────────────────────');

      // Parse and return the response
      return KnowledgeListResponse.fromJson(response.data);
    } catch (e) {
      AppLogger.e('Error fetching assistant knowledges: $e');
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
          '└────────────────────────────────────────────────────────────'); // Return success based on status code (200 or 204 are success)
      // 204 means "No Content" which is a common response for DELETE operations
      AppLogger.i(
          'Delete knowledge response: ${response.statusCode} handle this case');
      return response.statusCode == 200 || response.statusCode == 204;
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
      final endpoint =
          '/kb-core/v1/knowledge/${params.knowledgeId}/datasources';
      final url = '${_dio.options.baseUrl}$endpoint';

      AppLogger.d(
          '┌── KNOWLEDGE API REQUEST ──────────────────────────────────');
      AppLogger.d('│ 🔍 [GET] Knowledge Data Sources');
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
  // Future<FileUploadResponse> uploadSlackSource({
  //   required String knowledgeId,
  //   required String unitName,
  //   required String slackWorkspace,
  //   required String slackBotToken,
  //   String? accessToken,
  // }) async {
  //   final url = '/kb-core/v1/knowledge/$knowledgeId/slack';

  //   final body = {
  //     'unitName': unitName,
  //     'slackWorkspace': slackWorkspace,
  //     'slackBotToken': slackBotToken,
  //   };

  //   final headers = <String, dynamic>{
  //     if (accessToken != null && accessToken.isNotEmpty)
  //       'x-jarvis-guid': accessToken,
  //     if (accessToken != null && accessToken.isNotEmpty)
  //       'Authorization': 'Bearer $accessToken',
  //   };

  //   final response = await _uploadDio.post(
  //     url,
  //     data: body,
  //     options: Options(headers: headers),
  //   );

  //   return FileUploadResponse.fromJson(response.data);
  // }

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
    final endpoint = '/kb-core/v1/knowledge/$knowledgeId/datasources';
    // final endpoint = '/kb-core/v1/knowledge/$knowledgeId/web';
    final url = '${_dio.options.baseUrl}$endpoint';
    final body = {
      'datasources': [
        {
          'unitName': unitName,
          'name': unitName,
          'webUrl': webUrl,
          'url': webUrl,
          'type': 'website',
          'credentials': {
            'url': webUrl,
          }
        }
      ]
    };
    final headers = {
      'x-jarvis-guid': accessToken,
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    // ─── LOG REQUEST ────────────────────────────────
    AppLogger.d('┌── KNOWLEDGE API REQUEST ─────────────────────────');
    AppLogger.d('│ 🔍 [POST] Upload Web Source');
    AppLogger.d('│ URL: $url');
    AppLogger.d('│ Knowledge ID: $knowledgeId');
    AppLogger.d('│ Body: $body');
    AppLogger.d('│ Headers: $headers');
    AppLogger.d('└─────────────────────────────────────────────────');

    final response = await _dio.post(
      endpoint,
      data: body,
      options: Options(headers: headers),
    );

    // ─── LOG RESPONSE ───────────────────────────────
    AppLogger.d('┌── KNOWLEDGE API RESPONSE ────────────────────────');
    AppLogger.d('│ 🔍 [POST] Upload Web Source');
    AppLogger.d('│ Status: ${response.statusCode}');
    AppLogger.d('│ Data: ${response.data}');
    AppLogger.d('└─────────────────────────────────────────────────');

    if (response.statusCode == 201) {
      return FileUploadResponse.fromJson(response.data);
    } else {
      throw Exception('Upload website failed: ${response.statusCode}');
    }
  }

  /// Bước 1: upload raw file → trả về fileId
  Future<UploadedFile> uploadRawFile({
    required File file,
    required String accessToken,
  }) async {
    final endpoint = '/kb-core/v1/knowledge/files';
    final url = '${_uploadDio.options.baseUrl}$endpoint';

    // Use fromMap so Dio knows about your file part
    final form = FormData();
    form.files.add(
      MapEntry(
        'files',
        await MultipartFile.fromFile(
          file.path,
          filename: p.basename(file.path),
          // gán mime type đúng để server nhận file
          contentType: MediaType.parse(_getSupportedMimeType(file)!),
        ),
      ),
    );

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'x-jarvis-guid': accessToken,
      // DO NOT set Content-Type here: Dio will add boundary automatically
    };

    // Log request
    AppLogger.d('┌── Raw File Upload Request ─────────────────');
    AppLogger.d('│ URL: $url');
    AppLogger.d('│ FormData: $form');
    AppLogger.d('│ fileKeys: ${form.files.map((e) => e.key).toList()}');
    // log luôn size & filename để đối chiếu
    form.files.forEach((kv) {
      AppLogger.d('│ → key=${kv.key}, filename=${kv.value.filename}, '
          'length=${kv.value.length}');
    });
    AppLogger.d('└───────────────────────────────────────────');

    final resp = await _uploadDio.post(
      endpoint,
      data: form,
      options: Options(headers: headers),
    );

    // ─── LOG FULL RESPONSE ───────────────────────────
    AppLogger.d('┌── RAW UPLOAD FULL RESPONSE ─────────────────');
    AppLogger.d('│ Status code   : ${resp.statusCode}');
    AppLogger.d('│ Status message: ${resp.statusMessage}');
    AppLogger.d('│ Request URI   : ${resp.requestOptions.uri}');
    AppLogger.d('│ Request headers: ${resp.requestOptions.headers}');
    AppLogger.d('│ Response headers: ${resp.headers.map}');
    AppLogger.d('│ Data          : ${resp.data}');
    AppLogger.d('│ Response toString(): ${resp.toString()}');
    AppLogger.d('└──────────────────────────────────────────────');

    if ((resp.statusCode ?? 0) >= 200 && resp.statusCode! < 300) {
      final files = resp.data['files'] as List<dynamic>?;
      if (files == null || files.isEmpty) {
        throw Exception('Uploaded but server returned empty files list');
      }
      return UploadedFile.fromJson(files.first as Map<String, dynamic>);
    }
    throw Exception('Upload raw file failed: ${resp.statusCode}');
  }

  /// Bước 2: gắn lên knowledge base
  Future<FileUploadResponse> attachFileToKnowledge({
    required String knowledgeId,
    required String fileId,
    required String accessToken,
  }) async {
    final endpoint = '/kb-core/v1/knowledge/$knowledgeId/files';
    final url = '${_dio.options.baseUrl}$endpoint';
    final body = {'fileId': fileId};
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'x-jarvis-guid': accessToken,
      'Content-Type': 'application/json',
    };

    // ─── LOG REQUEST ────────────────────────────────
    AppLogger.d('┌── KNOWLEDGE API REQUEST ─────────────────────────');
    AppLogger.d('│ 🔍 [POST] Attach File to KB');
    AppLogger.d('│ URL: $url');
    AppLogger.d('│ Knowledge ID: $knowledgeId');
    AppLogger.d('│ Body: $body');
    AppLogger.d('│ Headers: $headers');
    AppLogger.d('└─────────────────────────────────────────────────');

    final resp = await _dio.post(
      endpoint,
      data: body,
      options: Options(headers: headers),
    );

    // ─── LOG RESPONSE ───────────────────────────────
    AppLogger.d('┌── KNOWLEDGE API RESPONSE ────────────────────────');
    AppLogger.d('│ 🔍 [POST] Attach File to KB');
    AppLogger.d('│ Status: ${resp.statusCode}');
    AppLogger.d('│ Data: ${resp.data}');
    AppLogger.d('└─────────────────────────────────────────────────');

    if (resp.statusCode == 201) {
      return FileUploadResponse.fromJson(resp.data);
    }
    throw Exception('Attach to KB failed: ${resp.statusCode}');
  }

  /// Bước 2: gắn datasource lên KB
  Future<FileUploadResponse> attachDatasource({
    required String knowledgeId,
    required String fileId,
    required String fileName,
    required String accessToken,
  }) async {
    final endpoint = '/kb-core/v1/knowledge/$knowledgeId/datasources';
    final url = '${_dio.options.baseUrl}$endpoint';
    final body = {
      'datasources': [
        {
          'type': 'local_file',
          'name': fileName,
          'credentials': {'file': fileId},
        }
      ]
    };
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'x-jarvis-guid': accessToken,
      'Content-Type': 'application/json',
    };

    AppLogger.d('┌── KNOWLEDGE API REQUEST ─────────────────────────');
    AppLogger.d('│ 🔍 [POST] Attach DataSource');
    AppLogger.d('│ URL: $url');
    AppLogger.d('│ Body: $body');
    AppLogger.d('│ Headers: $headers');
    AppLogger.d('└─────────────────────────────────────────────────');

    final resp = await _dio.post(endpoint,
        data: body, options: Options(headers: headers));

    AppLogger.d('┌── KNOWLEDGE API RESPONSE ────────────────────────');
    AppLogger.d('│ 🔍 [POST] Attach DataSource');
    AppLogger.d('│ Status: ${resp.statusCode}');
    AppLogger.d('│ Data: ${resp.data}');
    AppLogger.d('└─────────────────────────────────────────────────');

    if (resp.statusCode == 201) {
      // Vì response trả về “datasources”, ta wrap lại thành files để tái sử dụng FileUploadResponse
      return FileUploadResponse.fromJson({'files': resp.data['datasources']});
    }
    throw Exception('Attach datasource failed: ${resp.statusCode}');
  }

  /// Upload Slack datasource
  Future<FileUploadResponse> uploadSlackSource({
    required String knowledgeId,
    required String name,
    required String slackToken,
    required String accessToken,
  }) async {
    final endpoint = '/kb-core/v1/knowledge/$knowledgeId/datasources';
    final url = '${_dio.options.baseUrl}$endpoint';
    final body = {
      'datasources': [
        {
          'type': 'slack',
          'name': name,
          'credentials': {'token': slackToken},
        }
      ]
    };
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'x-jarvis-guid': accessToken,
      'Content-Type': 'application/json',
    };
    AppLogger.d('┌── KNOWLEDGE API REQUEST ─────────────────────────');
    AppLogger.d('│ 🔍 [POST] Slack Import');
    AppLogger.d('│ URL: $url');
    AppLogger.d('│ Body: $body');
    AppLogger.d('│ Headers: $headers');
    AppLogger.d('└─────────────────────────────────────────────────');

    final resp = await _dio.post(endpoint,
        data: body, options: Options(headers: headers));

    AppLogger.d('┌── KNOWLEDGE API RESPONSE ────────────────────────');
    AppLogger.d('│ 🔍 [POST] Slack Import');
    AppLogger.d('│ Status: ${resp.statusCode}');
    AppLogger.d('│ Data: ${resp.data}');
    AppLogger.d('└─────────────────────────────────────────────────');

    if (resp.statusCode == 201) {
      // wrap lại để reuse FileUploadResponse
      return FileUploadResponse.fromJson({'files': resp.data['datasources']});
    }
    throw Exception('Slack import failed: ${resp.statusCode}');
  }

  /// Bước 3: attach nhiều local_file cùng lúc
  Future<FileUploadResponse> attachMultipleLocalFiles({
    required String knowledgeId,
    required List<UploadedFile> uploadedFiles,
    required String accessToken,
  }) async {
    final endpoint = '/kb-core/v1/knowledge/$knowledgeId/datasources';
    final body = {
      'datasources': uploadedFiles
          .map((f) => {
                'type': 'local_file',
                'name': f.name,
                'credentials': {'file': f.id},
              })
          .toList(),
    };
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'x-jarvis-guid': accessToken,
      'Content-Type': 'application/json',
    };
    final resp = await _dio.post(endpoint,
        data: body, options: Options(headers: headers));
    if (resp.statusCode == 201) {
      return FileUploadResponse.fromJson({'files': resp.data['datasources']});
    }
    throw Exception('Attach multiple files failed: ${resp.statusCode}');
  }

  /// Bước 4: Xóa 1 datasource khỏi KB
  Future<void> deleteDatasourceInKnowledge({
    required String knowledgeId,
    required String datasourceId,
    required String accessToken,
  }) async {
    final endpoint =
        '/kb-core/v1/knowledge/$knowledgeId/datasources/$datasourceId';
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'x-jarvis-guid': accessToken,
    };
    AppLogger.d('┌── DELETE Datasource ─────────────────────────────');
    AppLogger.d('│ DELETE $endpoint');
    AppLogger.d('│ Headers: $headers');
    AppLogger.d('└────────────────────────────────────────────────');

    final resp = await _dio.delete(
      endpoint,
      options: Options(headers: headers),
    );
    if (resp.statusCode == 204) return;
    throw Exception('Delete datasource failed: ${resp.statusCode}');
  }
}
