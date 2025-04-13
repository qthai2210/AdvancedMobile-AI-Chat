import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:flutter/material.dart';

class RemoveFavoriteUsecase {
  final PromptRepository repository;

  RemoveFavoriteUsecase(this.repository);

  Future<bool> call({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint('RemoveFavoriteUsecase for promptId: $promptId');
      final result = await repository.removeFavorite(
        accessToken: accessToken,
        promptId: promptId,
        xJarvisGuid: xJarvisGuid,
      );
      return result;
    } catch (e) {
      debugPrint('RemoveFavoriteUsecase error: $e');
      rethrow;
    }
  }
}
