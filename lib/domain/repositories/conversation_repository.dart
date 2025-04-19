import 'package:aichatbot/data/models/chat/conversation_model.dart';
import 'package:aichatbot/data/models/chat/conversation_request_params.dart';
import 'package:aichatbot/data/models/chat/conversation_history_model.dart';
import 'package:aichatbot/data/models/chat/conversation_history_params.dart';

abstract class ConversationRepository {
  /// Fetches conversations from the API
  ///
  /// [accessToken] The user's access token for authentication
  /// [params] Parameters for filtering conversations
  /// [xJarvisGuid] Optional GUID parameter for the Jarvis API
  Future<ConversationListResponseModel> getConversations({
    required ConversationRequestParams params,
    String? xJarvisGuid,
  });

  /// Fetches conversation history for a specific conversation
  ///
  /// [params] Parameters for fetching conversation history
  /// [xJarvisGuid] Optional GUID parameter for the Jarvis API
  Future<ConversationHistoryResponse> getConversationHistory({
    required ConversationHistoryParams params,
    String? xJarvisGuid,
  });
}
