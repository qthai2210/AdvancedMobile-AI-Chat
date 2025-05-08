import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

class AttachFileToKBUseCase {
  final KnowledgeRepository repo;
  AttachFileToKBUseCase(this.repo);

  Future<FileUploadResponse> execute({
    required String knowledgeId,
    required String fileId,
    required String accessToken,
  }) {
    return repo.attachFile(
      knowledgeId: knowledgeId,
      fileId: fileId,
      accessToken: accessToken,
    );
  }
}