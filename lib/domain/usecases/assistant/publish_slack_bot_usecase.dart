import 'package:aichatbot/domain/repositories/assistant_repository.dart';

/// Use case for publishing an assistant as a Slack bot
class PublishSlackBotUseCase {
  final AssistantRepository repository;

  /// Creates a new instance of [PublishSlackBotUseCase]
  PublishSlackBotUseCase(this.repository);

  /// Execute the use case to publish an assistant as a Slack bot
  ///
  /// [assistantId] is required to identify the assistant
  /// [botToken] is required Slack bot token
  /// [clientId] is required Slack client ID
  /// [clientSecret] is required Slack client secret
  /// [signingSecret] is required Slack signing secret
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is optional for tracking
  ///
  /// Returns the Slack bot URL on successful publishing
  Future<String> call({
    required String assistantId,
    required String botToken,
    required String clientId,
    required String clientSecret,
    required String signingSecret,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    return await repository.publishSlackBot(
      assistantId: assistantId,
      botToken: botToken,
      clientId: clientId,
      clientSecret: clientSecret,
      signingSecret: signingSecret,
      accessToken: accessToken,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
