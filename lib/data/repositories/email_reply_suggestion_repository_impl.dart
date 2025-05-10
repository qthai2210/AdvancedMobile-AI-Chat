import 'package:aichatbot/data/datasources/remote/email_api_service.dart';
import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';
import 'package:aichatbot/domain/repositories/email_reply_suggestion_repository.dart';
import 'package:aichatbot/utils/logger.dart';

class EmailReplySuggestionRepositoryImpl
    implements EmailReplySuggestionRepository {
  final EmailApiService _emailApiService;

  EmailReplySuggestionRepositoryImpl(this._emailApiService);

  @override
  Future<EmailReplySuggestionResponse> getSuggestions({
    required String email,
    required String subject,
    required String sender,
    required String receiver,
    required String language,
    String? guid,
    String? authToken,
    String action = "Suggest 3 ideas for this email",
    String model = "dify",
  }) async {
    try {
      // Create metadata object
      final metadata = AiEmailReplyIdeasMetadata(
        context: [],
        subject: subject,
        sender: sender,
        receiver: receiver,
        language: language,
      );

      // Create request object
      final request = EmailReplySuggestionRequest(
        model: model,
        email: email,
        action: action,
        metadata: metadata,
      ); // Call API service method
      return await _emailApiService.getSuggestionReplies(
        request: request,
        customGuid: guid,
      );
    } catch (e) {
      AppLogger.e('Error in repository getting email reply suggestions: $e');
      rethrow;
    }
  }
}
