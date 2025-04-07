import 'package:aichatbot/data/datasources/remote/prompt_api_service.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/errors/failures.dart';

class PromptRepositoryImpl implements PromptRepository {
  final PromptApiService promptApiService;

  PromptRepositoryImpl({required this.promptApiService});

  @override
  Future<Prompt> createPrompt({
    required String accessToken,
    required String title,
    required String content,
    required String description,
    required List<String> categories,
    required bool isPublic,
    required String language,
  }) async {
    try {
      final String category = categories.isNotEmpty ? categories[0] : 'Writing';
      final promptModel = await promptApiService.createPrompt(
        accessToken: accessToken,
        title: title,
        content: content,
        description: description,
        category: category,
        isPublic: isPublic,
        language: language,
      );
      return promptModel;
    } on ServerException catch (e) {
      throw PromptFailure(e.message);
    } catch (e) {
      throw PromptFailure('Unexpected error: $e');
    }
  }

  @override
  Future<Prompt> updatePrompt({
    required String accessToken,
    required Prompt prompt,
  }) async {
    try {
      final promptModel = await promptApiService.updatePrompt(
        accessToken: accessToken,
        promptId: prompt.id,
        promptData: (prompt as PromptModel).toJson(),
      );
      return promptModel;
    } on ServerException catch (e) {
      throw PromptFailure(e.message);
    } catch (e) {
      throw PromptFailure('Unexpected error: $e');
    }
  }

  @override
  Future<List<Prompt>> getPrompts({
    required String accessToken,
  }) async {
    try {
      final promptModels = await promptApiService.getPrompts(
        accessToken: accessToken,
      );
      return promptModels;
    } on ServerException catch (e) {
      throw PromptFailure(e.message);
    } catch (e) {
      throw PromptFailure('Unexpected error: $e');
    }
  }

  @override
  Future<void> deletePrompt({
    required String accessToken,
    required String promptId,
  }) async {
    try {
      await promptApiService.deletePrompt(
        accessToken: accessToken,
        promptId: promptId,
      );
    } on ServerException catch (e) {
      throw PromptFailure(e.message);
    } catch (e) {
      throw PromptFailure('Unexpected error: $e');
    }
  }
}
