import 'package:aichatbot/data/models/chat/conversation_model.dart';
import 'package:aichatbot/data/models/chat/conversation_request_params.dart';
import 'package:aichatbot/domain/repositories/conversation_repository.dart';

class GetConversationsUsecase {
  final ConversationRepository repository;

  GetConversationsUsecase(this.repository);

  /// Fetches conversations from the API
  ///
  /// [accessToken] The user's access token for authentication
  /// [assistantModel] The assistant model to use (typically DIFY)
  /// [assistantId] Optional ID of the specific assistant model
  /// [cursor] Optional cursor for pagination
  /// [limit] Optional limit for number of results
  /// [xJarvisGuid] Optional GUID parameter for the Jarvis API
  Future<ConversationListResponseModel> call({
    required AssistantModel assistantModel,
    AssistantId? assistantId,
    String? cursor,
    int? limit,
    String? xJarvisGuid,
  }) async {
    final params = ConversationRequestParams(
      assistantModel: assistantModel,
      assistantId: assistantId,
      cursor: cursor,
      limit: limit,
    );

    return repository.getConversations(
      params: params,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
