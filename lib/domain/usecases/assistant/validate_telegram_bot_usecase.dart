import 'package:aichatbot/domain/repositories/assistant_repository.dart';

/// Use case for validating a Telegram bot token before publishing
class ValidateTelegramBotUseCase {
  final AssistantRepository repository;

  /// Creates a new instance of [ValidateTelegramBotUseCase]
  ValidateTelegramBotUseCase(this.repository);

  /// Execute the use case to validate a Telegram bot token
  ///
  /// [botToken] is required Telegram bot token from BotFather
  /// [accessToken] is optional for authorization
  /// [xJarvisGuid] is an optional tracking GUID
  /// Returns a map with bot information on successful validation
  Future<Map<String, dynamic>> call({
    required String botToken,
    String? accessToken,
    String? xJarvisGuid,
  }) async {
    return await repository.validateTelegramBot(
      botToken: botToken,
      accessToken: accessToken,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
