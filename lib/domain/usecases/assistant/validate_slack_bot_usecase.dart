import 'package:aichatbot/domain/repositories/assistant_repository.dart';

/// Use case for validating a Slack bot configuration before publishing
class ValidateSlackBotUseCase {
  final AssistantRepository repository;

  /// Creates a new instance of [ValidateSlackBotUseCase]
  ValidateSlackBotUseCase(this.repository);

  /// Execute the use case to validate Slack bot configuration
  ///
  /// [botToken] is required Slack bot token
  /// [clientId] is required Slack client ID
  /// [clientSecret] is required Slack client secret
  /// [signingSecret] is required Slack signing secret
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is optional for tracking
  ///
  /// Returns a map with bot information on successful validation
  Future<Map<String, dynamic>> call({
    required String botToken,
    required String clientId,
    required String clientSecret,
    required String signingSecret,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    return await repository.validateSlackBot(
      botToken: botToken,
      clientId: clientId,
      clientSecret: clientSecret,
      signingSecret: signingSecret,
      accessToken: accessToken,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
