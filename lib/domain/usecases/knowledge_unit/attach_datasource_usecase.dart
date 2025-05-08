import 'package:aichatbot/domain/repositories/knowledge_repository.dart';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';

class AttachDatasourceUseCase {
  final KnowledgeRepository repository;
  AttachDatasourceUseCase(this.repository);
  Future<FileUploadResponse> call({
    required String knowledgeId,
    required String fileId,
    required String fileName,
    required String accessToken,
  }) {
    return repository.attachDatasource(
      knowledgeId: knowledgeId,
      fileId: fileId,
      fileName: fileName,
      accessToken: accessToken,
    );
  }
}