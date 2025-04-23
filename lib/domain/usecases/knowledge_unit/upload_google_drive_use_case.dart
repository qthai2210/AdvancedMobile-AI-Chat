import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

class UploadGoogleDriveFileUseCase {
  final KnowledgeRepository repository;
  UploadGoogleDriveFileUseCase(this.repository);

  Future<FileUploadResponse> call({
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
    return repository.uploadGoogleDriveFile(
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
}
