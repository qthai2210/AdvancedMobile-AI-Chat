import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/domain/repositories/knowledge_repository.dart';

class UploadSlackFileUseCase {
  final KnowledgeRepository repository;
  UploadSlackFileUseCase(this.repository);

  Future<FileUploadResponse> execute({
    required String knowledgeId,
    required String unitName,
    required String slackWorkspace,
    required String slackBotToken,
    required String accessToken,
  }) {
    return repository.uploadSlackSource(
      knowledgeId: knowledgeId,
      unitName: unitName,
      slackWorkspace: slackWorkspace,
      slackBotToken: slackBotToken,
      accessToken: accessToken,
    );
  }
}
