import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/domain/repositories/prompt_repository.dart';

class CreatePromptUsecase {
  final PromptRepository repository;

  CreatePromptUsecase(this.repository);

  Future<Prompt> call({
    required String accessToken,
    required String title,
    required String content,
    required String description,
    required List<String> categories,
    required bool isPublic,
    required String language,
  }) async {
    return await repository.createPrompt(
      accessToken: accessToken,
      title: title,
      content: content,
      description: description,
      categories: categories,
      isPublic: isPublic,
      language: language,
    );
  }
}
