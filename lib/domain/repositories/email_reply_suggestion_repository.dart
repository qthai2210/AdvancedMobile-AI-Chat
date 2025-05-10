import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';

abstract class EmailReplySuggestionRepository {
  /// Get email reply ideas suggestions
  ///
  /// Returns a [EmailReplySuggestionResponse] with suggested reply ideas
  /// Throws an exception if the request fails
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
  });
}
