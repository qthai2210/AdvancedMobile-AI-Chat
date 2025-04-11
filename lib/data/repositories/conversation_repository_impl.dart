import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/data/datasources/remote/conversation_api_service.dart';
import 'package:aichatbot/data/models/chat/conversation_model.dart';
import 'package:aichatbot/data/models/chat/conversation_request_params.dart';
import 'package:aichatbot/domain/repositories/conversation_repository.dart';

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
}
