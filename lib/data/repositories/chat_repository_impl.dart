import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/data/datasources/remote/chat_api_service.dart';
import 'package:aichatbot/data/models/chat/custom_bot_message_model.dart';
import 'package:aichatbot/data/models/chat/message_request_model.dart';
import 'package:aichatbot/data/models/chat/message_response_model.dart';
import 'package:aichatbot/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatApiService chatApiService;

  ChatRepositoryImpl({required this.chatApiService});

  @override
  Future<MessageResponseModel> sendMessage(
      {required MessageRequestModel request}) async {
    try {
      final response = await chatApiService.sendMessage(
        request: request,
      );
      return response;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<MessageResponseModel> chatWithBot(
      {required CustomBotMessageRequest request}) async {
    try {
      final customBotResponse =
          await chatApiService.chatWithBot(request: request);

      // Convert CustomBotMessageResponse to MessageResponseModel for consistency
      return MessageResponseModel(
          message: customBotResponse.message,
          conversationId: request.metadata.conversation.id,
          remainingUsage: customBotResponse.remainingUsage);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
