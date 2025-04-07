import 'package:aichatbot/domain/entities/prompt.dart';

abstract class PromptRepository {
  Future<Prompt> createPrompt({
    required String accessToken,
    required String title,
    required String content,
    required String description,
    required List<String> categories,
    required bool isPublic,
    required String language,
  });

  Future<Prompt> updatePrompt({
    required String accessToken,
    required Prompt prompt,
  });

  Future<List<Prompt>> getPrompts({
    required String accessToken,
  });

  Future<void> deletePrompt({
    required String accessToken,
    required String promptId,
  });
}
