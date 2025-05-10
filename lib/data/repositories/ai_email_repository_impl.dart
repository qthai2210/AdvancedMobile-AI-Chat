import 'package:aichatbot/data/datasources/remote/email_api_service.dart';
import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';
import 'package:aichatbot/domain/repositories/ai_email_repository.dart';
import 'package:aichatbot/utils/logger.dart';

class AiEmailRepositoryImpl implements AiEmailRepository {
  final EmailApiService _emailApiService;

  AiEmailRepositoryImpl(this._emailApiService);

  @override
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
  }) async {
    try {
      // Create metadata object
      final metadata = AiEmailMetadata(
        context: [],
        subject: subject,
        sender: sender,
        receiver: receiver,
        style: style,
        language: language,
      );

      // Create request object
      final request = AiEmailRequest(
        mainIdea: mainIdea,
        action: action,
        email: email,
        metadata: metadata,
      );

      // Call API service method
      return await _emailApiService.generateAiEmail(
        request: request,
        customGuid: guid,
      );
    } catch (e) {
      AppLogger.e('Error in repository generating AI email: $e');
      rethrow;
    }
  }
}
