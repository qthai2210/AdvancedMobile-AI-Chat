import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:flutter/material.dart';

class UpdatePromptUsecase {
  final PromptRepository repository;

  UpdatePromptUsecase(this.repository);

  Future<PromptModel> call({
    required String accessToken,
    required String promptId,
    String? title,
    String? content,
    String? description,
    String? category,
    bool? isPublic,
    String? language,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint('UpdatePromptUsecase: Updating prompt $promptId');

      final result = await repository.updatePrompt(
        accessToken: accessToken,
        promptId: promptId,
        title: title,
        content: content,
        description: description,
        category: category,
        isPublic: isPublic,
        language: language,
        xJarvisGuid: xJarvisGuid,
      );

      return result;
    } catch (e) {
      debugPrint('UpdatePromptUsecase error: $e');
      rethrow;
    }
  }
}
