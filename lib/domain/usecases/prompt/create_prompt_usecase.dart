import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:flutter/material.dart';

class CreatePromptUsecase {
  final PromptRepository repository;

  CreatePromptUsecase(this.repository);

  Future<PromptModel> call({
    required String accessToken,
    required String title,
    required String content,
    required String description,
    String? category,
    bool? isPublic,
    String? language,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint('CreatePromptUsecase: Creating new prompt "$title"');

      final result = await repository.createPrompt(
        accessToken: accessToken,
        title: title,
        content: content,
        description: description,
        category: category,
        isPublic: isPublic ?? false,
        language: language,
        xJarvisGuid: xJarvisGuid,
      );

      return result;
    } catch (e) {
      debugPrint('CreatePromptUsecase error: $e');
      rethrow;
    }
  }
}
