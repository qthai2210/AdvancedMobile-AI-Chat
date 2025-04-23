import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

class UploadConfluenceFileUseCase {
  final KnowledgeRepository repository;
  UploadConfluenceFileUseCase(this.repository);

  Future<FileUploadResponse> execute({
    required String knowledgeId,
    required String unitName,
    required String wikiPageUrl,
    required String confluenceUsername,
    required String confluenceAccessToken,
    String? accessToken,
  }) {
    return repository.uploadConfluenceSource(
      knowledgeId: knowledgeId,
      unitName: unitName,
      wikiPageUrl: wikiPageUrl,
      confluenceUsername: confluenceUsername,
      confluenceAccessToken: confluenceAccessToken,
      accessToken: accessToken,
    );
  }
}
