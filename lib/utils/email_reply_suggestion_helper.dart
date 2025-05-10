import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';

/// Utility class to help create email reply suggestion requests
class EmailReplySuggestionHelper {
  /// Create an email reply suggestion request from raw data
  ///
  /// This is useful for creating requests directly from user input or other data sources
  static EmailReplySuggestionRequest createRequest({
    required String emailContent,
    required String subject,
    required String sender,
    required String receiver,
    required String language,
    String action = "Suggest 3 ideas for this email",
    String model = "dify",
    String? assistantId,
    String? assistantModel,
  }) {
    // Create metadata object
    final metadata = AiEmailReplyIdeasMetadata(
      context: [],
      subject: subject,
      sender: sender,
      receiver: receiver,
      language: language,
    );

    // Create assistant object if needed
    final assistant = (assistantId != null || assistantModel != null)
        ? AssistantDto(
            id: assistantId,
            model: assistantModel ?? "dify",
          )
        : null;

    // Create and return request object
    return EmailReplySuggestionRequest(
      assistant: assistant,
      model: model,
      email: emailContent,
      action: action,
      metadata: metadata,
    );
  }

  /// Example of how to use the createRequest method with the provided example
  ///
  /// ```dart
  /// final request = EmailReplySuggestionHelper.createExampleRequest();
  /// final response = await emailApiService.getSuggestionReplies(request: request);
  /// ```
}
