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

  /// Tạo một prompt mới
  Future<PromptModel> createPrompt({
    required String accessToken,
    required String title,
    required String content,
    required String description,
    String? category,
    bool isPublic,
    String? language,
    String? xJarvisGuid,
  });

  /// Cập nhật một prompt
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
  });

  /// Xóa một prompt
  Future<bool> deletePrompt({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
  });

  /// Thêm prompt vào danh sách yêu thích
  Future<bool> addFavorite({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
  });

  /// Xóa prompt khỏi danh sách yêu thích
  Future<bool> removeFavorite({
    required String accessToken,
    required String promptId,
    String? xJarvisGuid,
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
