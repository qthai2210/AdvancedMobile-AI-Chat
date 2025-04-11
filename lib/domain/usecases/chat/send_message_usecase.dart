import 'package:aichatbot/data/models/chat/message_request_model.dart';
import 'package:aichatbot/data/models/chat/message_response_model.dart';
import 'package:aichatbot/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  /// Sends a message to the AI chat service
  ///
  /// [accessToken] The user's access token for authentication
  /// [request] The message request containing content and metadata
  /// Returns a [Future] that completes with the AI's response message
  Future<MessageResponseModel> call({
    required String accessToken,
    required MessageRequestModel request,
  }) async {
    return repository.sendMessage(
      accessToken: accessToken,
      request: request,
    );
  }
}
