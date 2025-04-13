import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:flutter/material.dart';

class DeletePromptUsecase {
  final PromptRepository repository;

  DeletePromptUsecase(this.repository);

  Future<bool> call({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint('DeletePromptUsecase: Deleting prompt $promptId');

      final result = await repository.deletePrompt(
        accessToken: accessToken,
        promptId: promptId,
        xJarvisGuid: xJarvisGuid,
      );

      return result;
    } catch (e) {
      debugPrint('DeletePromptUsecase error: $e');
      rethrow;
    }
  }
}
