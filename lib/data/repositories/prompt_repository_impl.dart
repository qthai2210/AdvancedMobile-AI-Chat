import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/data/datasources/remote/prompt_api_service.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/domain/repositories/prompt_repository.dart';

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
    required String category,
    required bool isPublic,
    required String language,
    String? xJarvisGuid,
  }) async {
    try {
      final response = await promptApiService.createPrompt(
        accessToken: accessToken,
        title: title,
        content: content,
        description: description,
        category: category,
        isPublic: isPublic,
        language: language,
        xJarvisGuid: xJarvisGuid,
      );

      return PromptModel.fromJson(response);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }

  @override
  Future<Prompt> updatePrompt({
    required String accessToken,
    required Prompt prompt,
  }) async {
    // Implement update method as needed
    throw UnimplementedError();
  }

  @override
  Future<void> deletePrompt({
    required String accessToken,
    required String promptId,
  }) async {
    // Implement delete method as needed
    throw UnimplementedError();
  }

  @override
  Future<bool> toggleFavorite({
    required String accessToken,
    required String promptId,
  }) async {
    // Implement toggle favorite method as needed
    throw UnimplementedError();
  }
}
