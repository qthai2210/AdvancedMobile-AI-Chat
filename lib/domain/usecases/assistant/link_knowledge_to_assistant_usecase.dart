import 'package:aichatbot/domain/repositories/assistant_repository.dart';

/// Use case for linking a knowledge base to an assistant
class LinkKnowledgeToAssistantUseCase {
  final AssistantRepository repository;

  /// Creates a new instance of [LinkKnowledgeToAssistantUseCase]
  LinkKnowledgeToAssistantUseCase(this.repository);

  /// Execute the use case to link a knowledge base to an assistant
  ///
  /// [assistantId] is required to identify the assistant
  /// [knowledgeId] is required to identify the knowledge base
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is an optional tracking GUID
  /// Returns true if linking was successful
  Future<bool> call({
    required String assistantId,
    required String knowledgeId,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    return await repository.linkKnowledgeToAssistant(
      assistantId: assistantId,
      knowledgeId: knowledgeId,
      accessToken: accessToken,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
