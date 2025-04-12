import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/data/datasources/remote/prompt_api_service.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:flutter/foundation.dart';

class PromptRepositoryImpl implements PromptRepository {
  final PromptApiService promptApiService;

  PromptRepositoryImpl({required this.promptApiService});

  @override
  Future<Map<String, dynamic>> getPrompts({
    required String accessToken,
    String? query,
    int? offset,
    int? limit,
    String? category,
    bool? isFavorite,
    bool? isPublic,
  }) async {
    try {
      return await promptApiService.getPrompts(
        accessToken: accessToken,
        query: query,
        offset: offset,
        limit: limit,
        category: category,
        isFavorite: isFavorite,
        isPublic: isPublic,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }

  @override
  Future<PromptModel> createPrompt({
    required String accessToken,
    required String title,
    required String content,
    required String description,
    String? category,
    bool isPublic = false,
    String? language,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint('PromptRepositoryImpl.createPrompt: Creating prompt "$title"');

      final result = await promptApiService.createPrompt(
        accessToken: accessToken,
        title: title,
        content: content,
        description: description,
        category: category,
        isPublic: isPublic,
        language: language,
        xJarvisGuid: xJarvisGuid,
      );

      debugPrint('PromptRepositoryImpl.createPrompt: Success');
      return result;
    } catch (e) {
      debugPrint('PromptRepositoryImpl.createPrompt error: $e');
      rethrow;
    }
  }

  @override
  Future<PromptModel> updatePrompt({
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
      debugPrint(
          'PromptRepositoryImpl.updatePrompt: Updating prompt $promptId');

      final result = await promptApiService.updatePrompt(
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

      debugPrint('PromptRepositoryImpl.updatePrompt: Success');
      return result;
    } catch (e) {
      debugPrint('PromptRepositoryImpl.updatePrompt error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deletePrompt({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint(
          'PromptRepositoryImpl.deletePrompt: Deleting prompt $promptId');

      final result = await promptApiService.deletePrompt(
        accessToken: accessToken,
        promptId: promptId,
        xJarvisGuid: xJarvisGuid,
      );

      debugPrint('PromptRepositoryImpl.deletePrompt: Success');
      return result;
    } catch (e) {
      debugPrint('PromptRepositoryImpl.deletePrompt error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> addFavorite({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint(
          'PromptRepositoryImpl.addFavorite: Adding prompt $promptId to favorites');

      final result = await promptApiService.addFavorite(
        accessToken: accessToken,
        promptId: promptId,
        xJarvisGuid: xJarvisGuid,
      );

      debugPrint('PromptRepositoryImpl.addFavorite: Success');
      return result;
    } catch (e) {
      debugPrint('PromptRepositoryImpl.addFavorite error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> removeFavorite({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
  }) async {
    try {
      debugPrint(
          'PromptRepositoryImpl.removeFavorite: Removing prompt $promptId from favorites');

      final result = await promptApiService.removeFavorite(
        accessToken: accessToken,
        promptId: promptId,
        xJarvisGuid: xJarvisGuid,
      );

      debugPrint('PromptRepositoryImpl.removeFavorite: Success');
      return result;
    } catch (e) {
      debugPrint('PromptRepositoryImpl.removeFavorite error: $e');
      rethrow;
    }
  }
}
