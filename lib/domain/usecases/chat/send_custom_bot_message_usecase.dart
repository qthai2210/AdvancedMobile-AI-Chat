import 'package:aichatbot/data/models/chat/custom_bot_message_model.dart';
import 'package:aichatbot/data/models/chat/message_response_model.dart';
import 'package:aichatbot/domain/repositories/chat_repository.dart';

/// Use case for sending messages to custom bots
///
/// This use case will handle sending messages to custom bots and will replace
/// the standard SendMessageUseCase when user chooses a custom bot to chat with
class SendCustomBotMessageUseCase {
  final ChatRepository repository;

  SendCustomBotMessageUseCase(this.repository);

  /// Sends a message to a custom bot

  Future<MessageResponseModel> call({
    required CustomBotMessageRequest request,
  }) async {
    return repository.chatWithBot(
      request: request,
    );
  }
}
