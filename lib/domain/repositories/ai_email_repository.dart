import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';

abstract class AiEmailRepository {
  /// Generate an AI email based on main idea, action and original email
  ///
  /// Returns an [AiEmailResponse] with the generated email
  /// Throws an exception if the request fails
  Future<AiEmailResponse> generateEmail({
    required String mainIdea,
    required String action,
    required String email,
    required String subject,
    required String sender,
    required String receiver,
    required EmailStyleConfig style,
    required String language,
    String? guid,
  });
}
