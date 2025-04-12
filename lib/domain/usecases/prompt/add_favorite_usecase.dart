import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:flutter/material.dart';

class AddFavoriteUsecase {
  final PromptRepository repository;

  AddFavoriteUsecase(this.repository);

  Future<bool> call({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint('AddFavoriteUsecase for promptId: $promptId');
      final result = await repository.addFavorite(
        accessToken: accessToken,
        promptId: promptId,
        xJarvisGuid: xJarvisGuid,
      );
      return result;
    } catch (e) {
      debugPrint('AddFavoriteUsecase error: $e');
      rethrow;
    }
  }
}
