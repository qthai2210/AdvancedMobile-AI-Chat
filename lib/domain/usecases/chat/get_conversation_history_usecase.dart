import 'package:aichatbot/data/models/chat/conversation_history_model.dart';
import 'package:aichatbot/data/models/chat/conversation_history_params.dart';
import 'package:aichatbot/data/models/chat/conversation_request_params.dart';
import 'package:aichatbot/domain/repositories/conversation_repository.dart';

class GetConversationHistoryUsecase {
  final ConversationRepository repository;

  GetConversationHistoryUsecase(this.repository);

  /// Fetches conversation history for a specific conversation
  ///
  /// [conversationId] Required ID of the conversation to fetch history for
  /// [assistantModel] Required model type (always "dify" as per API)
  /// [assistantId] Optional ID of specific assistant model
  /// [cursor] Optional cursor for pagination
  /// [limit] Optional limit for number of results (default: 100)
  /// [xJarvisGuid] Optional GUID parameter for the Jarvis API
  Future<ConversationHistoryResponse> call({
    required String conversationId,
    required AssistantModel assistantModel,
    AssistantId? assistantId,
    String? cursor,
    int? limit,
    String? xJarvisGuid,
  }) async {
    final params = ConversationHistoryParams(
      conversationId: conversationId,
      assistantModel: assistantModel,
      assistantId: assistantId,
      cursor: cursor,
      limit: limit,
    );

    return repository.getConversationHistory(
      params: params,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
