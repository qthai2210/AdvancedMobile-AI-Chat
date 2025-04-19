import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:aichatbot/data/models/prompt/prompt_list_model.dart';

class GetPromptsUsecase {
  final PromptRepository repository;

  GetPromptsUsecase(this.repository);

  Future<PromptListResponseModel> call({
    required String accessToken,
    String? query,
    int? offset,
    int? limit,
    String? category,
    bool? isFavorite,
    bool? isPublic,
  }) async {
    try {
      final response = await repository.getPrompts(
        accessToken: accessToken,
        query: query,
        offset: offset,
        limit: limit,
        category: category,
        isFavorite: isFavorite,
        isPublic: isPublic,
      );

      print("GetPromptsUsecase received response: ${response.keys}");

      final result = PromptListResponseModel.fromJson(response);
      print("Parsed ${result.items.length} items from response");

      return result;
    } catch (e) {
      print("Error in GetPromptsUsecase: $e");
      rethrow;
    }
  }
}
