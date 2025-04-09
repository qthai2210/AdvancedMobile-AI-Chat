import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/domain/repositories/prompt_repository.dart';

class CreatePromptUsecase {
  final PromptRepository repository;

  CreatePromptUsecase(this.repository);

  Future<PromptModel> call({
    required String accessToken,
    required String title,
    required String content,
    required String description,
    required String category,
    required bool isPublic,
    required String language,
    String? xJarvisGuid,
  }) async {
    return await repository.createPrompt(
      accessToken: accessToken,
      title: title,
      content: content,
      description: description,
      category: category,
      isPublic: isPublic,
      language: language,
      xJarvisGuid: xJarvisGuid,
    );
  }
}
