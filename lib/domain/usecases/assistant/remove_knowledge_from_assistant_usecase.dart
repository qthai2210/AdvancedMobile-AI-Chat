import 'package:aichatbot/domain/repositories/assistant_repository.dart';

/// Use case for removing a knowledge base from an assistant
class RemoveKnowledgeFromAssistantUseCase {
  final AssistantRepository repository;

  /// Creates a new instance of [RemoveKnowledgeFromAssistantUseCase]
  RemoveKnowledgeFromAssistantUseCase(this.repository);

  /// Execute the use case to remove a knowledge base from an assistant
  ///
  /// [assistantId] is required to identify the assistant
  /// [knowledgeId] is required to identify the knowledge base to remove
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is an optional tracking GUID
  /// Returns true if removal was successful
  Future<bool> call({
    required String assistantId,
    required String knowledgeId,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    return await repository.removeKnowledgeFromAssistant(
      assistantId: assistantId,
      knowledgeId: knowledgeId,
      accessToken: accessToken,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
