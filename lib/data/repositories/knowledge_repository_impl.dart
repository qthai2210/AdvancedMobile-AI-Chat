import 'dart:io';

import 'package:aichatbot/data/datasources/remote/knowledge_api_service.dart';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/data/models/knowledge/get_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/get_knowledge_units_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_list_response.dart';
import 'package:aichatbot/data/models/knowledge/create_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_unit_model.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_units_response.dart';
import 'package:aichatbot/data/models/knowledge/uploaded_file_model.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';
import 'package:aichatbot/utils/logger.dart';

class KnowledgeRepositoryImpl implements KnowledgeRepository {
  final KnowledgeApiService knowledgeApiService;

  KnowledgeRepositoryImpl({required this.knowledgeApiService});

  @override
  Future<KnowledgeListResponse> getKnowledges(GetKnowledgeParams params) async {
    try {
      final response = await knowledgeApiService.getKnowledges(params);
      return response;
    } catch (e) {
      AppLogger.e('Repository error fetching knowledges: $e');
      rethrow;
    }
  }

  @override
  Future<KnowledgeModel> createKnowledge(CreateKnowledgeParams params) async {
    try {
      AppLogger.d('Creating knowledge with name: ${params.knowledgeName}');
      final result = await knowledgeApiService.createKnowledge(params);
      AppLogger.i('Knowledge created successfully: ${result.knowledgeName}');
      return result;
    } catch (e) {
      AppLogger.e('Repository error creating knowledge: $e');
      rethrow;
    }
  }

  @override
  Future<KnowledgeModel> updateKnowledge(
      String id, CreateKnowledgeParams params) async {
    try {
      AppLogger.d('Creating knowledge with name: ${params.knowledgeName}');
      final result = await knowledgeApiService.updateKnowledge(id, params);
      return result;
    } catch (e) {
      AppLogger.e('Repository error creating knowledge: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteKnowledge(String id, {String? xJarvisGuid}) async {
    try {
      AppLogger.d('Repository deleting knowledge with ID: $id');
      final result = await knowledgeApiService.deleteKnowledge(id,
          xJarvisGuid: xJarvisGuid);
      AppLogger.i('Knowledge deleted successfully: $result');
      return result;
    } catch (e) {
      AppLogger.e('Repository error deleting knowledge: $e');
      rethrow;
    }
  }

  @override
  Future<KnowledgeUnitsResponse> getKnowledgeUnits({
    required String knowledgeId,
    required String accessToken,
  }) async {
    try {
      final params = GetKnowledgeUnitsParams(
        knowledgeId: knowledgeId,
        accessToken: accessToken,
      );

      final response = await knowledgeApiService.getKnowledgeUnits(params);

      AppLogger.d('Knowledge units API response received');

      // Check if response data is available
      if (response?.data != null) {
        // Ensure data is a List before mapping
        if (response!.data is List) {
          // First log what we're working with
          AppLogger.d(
              'Mapping ${(response.data as List).length} items to KnowledgeUnitModel');

          final knowledgeUnits =
              (response.data as List).map<KnowledgeUnitModel>((item) {
            try {
              // Check if item is already a KnowledgeUnitModel
              if (item is KnowledgeUnitModel) {
                AppLogger.d('Item is already a KnowledgeUnitModel');
                return item;
              } else if (item is Map<String, dynamic>) {
                return KnowledgeUnitModel.fromJson(item);
              } else {
                // Log the unsupported type
                AppLogger.e(
                    'Item is not a Map or KnowledgeUnitModel: ${item.runtimeType}');
                throw Exception(
                    'Invalid data format: unexpected type ${item.runtimeType}');
              }
            } catch (e) {
              AppLogger.e('Error mapping item to KnowledgeUnitModel: $e');
              AppLogger.e('Problematic item: $item');
              rethrow;
            }
          }).toList();

          // Return KnowledgeUnitsResponse instead of just the list
          return KnowledgeUnitsResponse(
            units: knowledgeUnits,
            meta: {},
          );
        } else if (response.data is Map<String, dynamic> &&
            (response.data as Map<String, dynamic>).containsKey('data') &&
            (response.data as Map<String, dynamic>)['data'] is List) {
          // Handle case where response has a nested "data" field that contains the actual list
          final responseMap = response.data as Map<String, dynamic>;
          final dataList = responseMap['data'] as List;
          final metaData = responseMap['meta'] as Map<String, dynamic>? ?? {};

          AppLogger.d('Found nested data list with ${dataList.length} items');
          AppLogger.d('Meta data: $metaData');

          // When processing the nested data:
          final knowledgeUnits = dataList.map<KnowledgeUnitModel>((item) {
            try {
              // Check if item is already a KnowledgeUnitModel
              if (item is KnowledgeUnitModel) {
                AppLogger.d(
                    'Item in nested data is already a KnowledgeUnitModel');
                return item;
              } else if (item is Map<String, dynamic>) {
                return KnowledgeUnitModel.fromJson(item);
              } else {
                AppLogger.e(
                    'Item in nested data is not a Map or KnowledgeUnitModel: ${item.runtimeType}');
                throw Exception(
                    'Invalid data format: unexpected type ${item.runtimeType}');
              }
            } catch (e) {
              AppLogger.e(
                  'Error mapping nested item to KnowledgeUnitModel: $e');
              rethrow;
            }
          }).toList();

          // Return both units and metadata
          return KnowledgeUnitsResponse(
            units: knowledgeUnits,
            meta: metaData,
          );
        } else {
          AppLogger.e(
              'Response data is not a List or a Map with data key: ${response.data.runtimeType}');
          return KnowledgeUnitsResponse(
            units: [],
            meta: {},
          );
        }
      }

      AppLogger.w('No data in response');
      return KnowledgeUnitsResponse(
        units: [],
        meta: {},
      );
    } catch (e) {
      AppLogger.e('Failed to load knowledge units: ${e.toString()}');
      throw Exception('Failed to load knowledge units: ${e.toString()}');
    }
  }

  /// Uploads a local file to the knowledge base
  ///
  /// [knowledgeId] - The ID of the knowledge base
  /// [file] - The file to upload
  /// [accessToken] - The user's access token for authentication
  @override
  Future<FileUploadResponse> uploadLocalFile({
    required String knowledgeId,
    required File file,
    required String accessToken,
    String? guid,
  }) async {
    return await knowledgeApiService.uploadLocalFile(
      knowledgeId: knowledgeId,
      file: file,
      accessToken: accessToken,
      guid: guid,
    );
  }

  @override
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
  }) {
    return knowledgeApiService.uploadGoogleDriveFile(
      knowledgeId: knowledgeId,
      id: id,
      name: name,
      status: status,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
      accessToken: accessToken,
    );
  }

  @override
  Future<FileUploadResponse> uploadSlackSource({
    required String knowledgeId,
    required String unitName,            // ở domain gọi unitName == name
    required String slackWorkspace,      // bỏ nếu không cần
    required String slackBotToken,
    required String accessToken,
  }) {
    return knowledgeApiService.uploadSlackSource(
      knowledgeId: knowledgeId,
      name: unitName,
      slackToken: slackBotToken,
      accessToken: accessToken,
    );
  }

  @override
  Future<FileUploadResponse> uploadConfluenceSource({
    required String knowledgeId,
    required String unitName,
    required String wikiPageUrl,
    required String confluenceUsername,
    required String confluenceAccessToken,
    String? accessToken,
  }) {
    return knowledgeApiService.uploadConfluenceSource(
      knowledgeId: knowledgeId,
      unitName: unitName,
      wikiPageUrl: wikiPageUrl,
      confluenceUsername: confluenceUsername,
      confluenceAccessToken: confluenceAccessToken,
      accessToken: accessToken,
    );
  }

  @override
  Future<FileUploadResponse> uploadWebsiteSource({
    required String knowledgeId,
    required String unitName,
    required String webUrl,
    required String accessToken,
  }) {
    return knowledgeApiService.uploadWebSource(
      knowledgeId: knowledgeId,
      unitName: unitName,
      webUrl: webUrl,
      accessToken: accessToken,
    );
  }

  @override
  Future<UploadedFile> uploadRawFile(
      {required File file, required String accessToken}) {
    return knowledgeApiService.uploadRawFile(
        file: file, accessToken: accessToken);
  }

  @override
  Future<FileUploadResponse> attachDatasource({
    required String knowledgeId,
    required String fileId,
    required String fileName,
    required String accessToken,
  }) {
    return knowledgeApiService.attachDatasource(
      knowledgeId: knowledgeId,
      fileId: fileId,
      fileName: fileName,
      accessToken: accessToken,
    );
  }

  @override
  Future<FileUploadResponse> attachFile({
    required String knowledgeId,
    required String fileId,
    required String accessToken,
  }) async {
    try {
      return await knowledgeApiService.attachFileToKnowledge(
        knowledgeId: knowledgeId,
        fileId: fileId,
        accessToken: accessToken,
      );
    } catch (e) {
      AppLogger.e('Repository error attaching file: $e');
      rethrow;
    }
  }
}
