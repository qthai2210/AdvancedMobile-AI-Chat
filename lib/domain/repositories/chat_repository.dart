import 'package:aichatbot/data/models/chat/message_request_model.dart';
import 'package:aichatbot/data/models/chat/message_response_model.dart';

abstract class ChatRepository {
  /// Sends a message to the AI chat service
  ///
  /// [accessToken] The user's access token for authentication
  /// [request] The message request containing content and metadata
  /// Returns a [Future] that completes with the AI's response message
  Future<MessageResponseModel> sendMessage({
    required MessageRequestModel request,
  });
}
