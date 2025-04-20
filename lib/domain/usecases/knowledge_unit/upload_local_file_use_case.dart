import 'dart:io';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

class UploadLocalFileUseCase {
  final KnowledgeRepository _fileRepository;

  UploadLocalFileUseCase({required KnowledgeRepository fileRepository})
      : _fileRepository = fileRepository;

  /// Execute the use case to upload a local file
  ///
  /// [knowledgeId] - The ID of the knowledge base
  /// [file] - The file to upload
  /// [accessToken] - The user's access token for authentication
  Future<FileUploadResponse> execute({
    required String knowledgeId,
    required File file,
    required String accessToken,
    String? guid,
  }) async {
    return await _fileRepository.uploadLocalFile(
      knowledgeId: knowledgeId,
      file: file,
      accessToken: accessToken,
      guid: guid,
    );
  }
}
