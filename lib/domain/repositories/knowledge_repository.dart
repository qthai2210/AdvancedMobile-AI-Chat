import 'dart:io';

import 'package:aichatbot/data/models/knowledge/create_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_list_response.dart';
import 'package:aichatbot/data/models/knowledge/get_knowledge_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_units_response.dart';
import 'package:aichatbot/data/models/knowledge/uploaded_file_model.dart';

/// Repository interface for Knowledge-related operations
abstract class KnowledgeRepository {
  /// Fetches knowledge items based on the provided parameters
  ///
  /// [params] - The parameters to filter and paginate the results
  /// Returns a [KnowledgeListResponse] containing the list of knowledges and metadata
  Future<KnowledgeListResponse> getKnowledges(GetKnowledgeParams params);

  /// Creates a new knowledge base with the provided parameters
  ///
  /// [params] - The parameters containing the knowledge name and optional description
  /// Returns the created [KnowledgeModel] on success
  Future<KnowledgeModel> createKnowledge(CreateKnowledgeParams params);

  /// Deletes a knowledge base with the specified ID
  ///
  /// [id] - The ID of the knowledge base to delete
  /// [xJarvisGuid] - Optional GUID for tracking
  /// Returns true if deletion was successful
  Future<bool> deleteKnowledge(String id, {String? xJarvisGuid});

  Future<KnowledgeModel> updateKnowledge(
      String id, CreateKnowledgeParams params);

  Future<KnowledgeUnitsResponse> getKnowledgeUnits({
    required String knowledgeId,
    required String accessToken,
  });

  Future<FileUploadResponse> uploadLocalFile({
    required String knowledgeId,
    required File file,
    required String accessToken,
    String? guid,
  });

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
  });

  // Future<FileUploadResponse> uploadSlackSource({
  //   required String knowledgeId,
  //   required String unitName,
  //   required String slackWorkspace,
  //   required String slackBotToken,
  //   String? accessToken,
  // });

  Future<FileUploadResponse> uploadConfluenceSource({
    required String knowledgeId,
    required String unitName,
    required String wikiPageUrl,
    required String confluenceUsername,
    required String confluenceAccessToken,
    String? accessToken,
  });

  Future<FileUploadResponse> uploadWebsiteSource({
    required String knowledgeId,
    required String unitName,
    required String webUrl,
    required String accessToken,
  });

  Future<UploadedFile> uploadRawFile(
      {required File file, required String accessToken});

  Future<FileUploadResponse> attachFile(
      {required String knowledgeId,
      required String fileId,
      required String accessToken});

  Future<FileUploadResponse> uploadSlackSource({
    required String knowledgeId,
    required String unitName, // ở domain gọi unitName == name
    required String slackWorkspace, // bỏ nếu không cần
    required String slackBotToken,
    required String accessToken,
  });

  /// Attach nhiều file (có thể là 1 file) lên KB
  Future<FileUploadResponse> attachMultipleLocalFiles({
    required String knowledgeId,
    required List<UploadedFile> uploadedFiles,
    required String accessToken,
  });

  /// Xóa 1 datasource đã attach
  Future<void> deleteDatasourceInKnowledge({
    required String knowledgeId,
    required String datasourceId,
    required String accessToken,
  });
}
