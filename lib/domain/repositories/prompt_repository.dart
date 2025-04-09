import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';

abstract class PromptRepository {
  Future<Map<String, dynamic>> getPrompts({
    required String accessToken,
    String? query,
    int? offset,
    int? limit,
    String? category,
    bool? isFavorite,
    bool? isPublic,
  });

  Future<PromptModel> createPrompt({
    required String accessToken,
    required String title,
    required String content,
    required String description,
    required String category,
    required bool isPublic,
    required String language,
    String? xJarvisGuid,
  });

  Future<Prompt> updatePrompt({
    required String accessToken,
    required Prompt prompt,
  });

  Future<void> deletePrompt({
    required String accessToken,
    required String promptId,
  });

  Future<bool> toggleFavorite({
    required String accessToken,
    required String promptId,
  });
}

class PromptListResponse {
  final bool hasNext;
  final int offset;
  final int limit;
  final int total;
  final List<Prompt> items;

  PromptListResponse({
    required this.hasNext,
    required this.offset,
    required this.limit,
    required this.total,
    required this.items,
  });
}
