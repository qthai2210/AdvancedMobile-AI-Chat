import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/data/datasources/remote/conversation_api_service.dart';
import 'package:aichatbot/data/models/chat/conversation_model.dart';
import 'package:aichatbot/data/models/chat/conversation_request_params.dart';
import 'package:aichatbot/data/models/chat/conversation_history_model.dart';
import 'package:aichatbot/data/models/chat/conversation_history_params.dart';
import 'package:aichatbot/domain/repositories/conversation_repository.dart';
import 'package:aichatbot/utils/logger.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationApiService conversationApiService;

  ConversationRepositoryImpl({required this.conversationApiService});

  @override
  Future<ConversationListResponseModel> getConversations({
    required ConversationRequestParams params,
    String? xJarvisGuid,
  }) async {
    try {
      final response = await conversationApiService.getConversations(
        params: params,
        xJarvisGuid: xJarvisGuid,
      );
      print("response from getConversations: $response");
      if (response.isEmpty) {
        throw ServerException("No conversations found.");
      }
      return ConversationListResponseModel.fromJson(response);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ConversationHistoryResponse> getConversationHistory({
    required ConversationHistoryParams params,
    String? xJarvisGuid,
  }) async {
    try {
      final response = await conversationApiService.getConversationHistory(
        conversationId: params.conversationId,
        cursor: params.cursor,
        limit: params.limit,
        assistantId: params.assistantId,
        assistantModel: params.assistantModel,
        xJarvisGuid: xJarvisGuid,
      );

      AppLogger.i("Response from getConversationHistory: $response");

      if (response.isEmpty) {
        throw ServerException("No conversation history found.");
      }

      return ConversationHistoryResponse.fromJson(response);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
