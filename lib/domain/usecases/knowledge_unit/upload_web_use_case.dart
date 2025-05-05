import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

class UploadWebUseCase {
  final KnowledgeRepository repository;
  UploadWebUseCase(this.repository);

  Future<FileUploadResponse> execute({
    required String knowledgeId,
    required String unitName,
    required String webUrl,
    required String accessToken,
  }) {
    return repository.uploadWebsiteSource(
      knowledgeId: knowledgeId,
      unitName: unitName,
      webUrl: webUrl,
      accessToken: accessToken,
    );
  }
}
