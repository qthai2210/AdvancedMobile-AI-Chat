import 'package:aichatbot/domain/repositories/assistant_repository.dart';

/// Use case for publishing an assistant as a Telegram bot
class PublishTelegramBotUseCase {
  final AssistantRepository repository;

  /// Creates a new instance of [PublishTelegramBotUseCase]
  PublishTelegramBotUseCase(this.repository);

  /// Execute the use case to publish an assistant as a Telegram bot
  ///
  /// [assistantId] is required to identify the assistant
  /// [botToken] is required Telegram bot token from BotFather
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is an optional tracking GUID
  /// Returns the Telegram bot URL on successful publishing
  Future<String> call({
    required String assistantId,
    required String botToken,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    return await repository.publishTelegramBot(
      assistantId: assistantId,
      botToken: botToken,
      accessToken: accessToken,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
