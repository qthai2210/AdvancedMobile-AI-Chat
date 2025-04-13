import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/data/models/prompt/prompt_list_model.dart';
import 'package:aichatbot/domain/entities/prompt.dart';

enum PromptStatus { initial, loading, loadingMore, success, failure }

class PromptState {
  final PromptStatus status;
  final List<PromptModel>? prompts;
  final String? errorMessage;
  final PromptListResponseModel? promptListResponse;
  final String? currentQuery;
  final bool? isFavoriteFilter;
  final String? selectedCategory;
  final bool? isGridView;
  final String? sortBy;
  final PromptModel? newPrompt;
  final String? searchQuery;
  final List<String> selectedCategories;
  final bool showOnlyFavorites;
  final PromptModel? updatedPrompt;
  final String? deletedPromptId;

  // Thêm các thuộc tính đang thiếu
  final bool favoriteToggleSuccess;
  final PromptModel? lastToggledPrompt;

  const PromptState({
    this.status = PromptStatus.initial,
    this.prompts,
    this.errorMessage,
    this.promptListResponse,
    this.currentQuery,
    this.isFavoriteFilter = false,
    this.selectedCategory,
    this.isGridView = false,
    this.sortBy = 'recent',
    this.newPrompt,
    this.searchQuery,
    this.selectedCategories = const ['All'],
    this.showOnlyFavorites = false,
    this.updatedPrompt,
    this.deletedPromptId,
    // Thêm các tham số mới với giá trị mặc định
    this.favoriteToggleSuccess = false,
    this.lastToggledPrompt,
  });

  PromptState copyWith({
    PromptStatus? status,
    List<PromptModel>? prompts,
    String? errorMessage,
    PromptListResponseModel? promptListResponse,
    String? currentQuery,
    bool? isFavoriteFilter,
    String? selectedCategory,
    bool? isGridView,
    String? sortBy,
    PromptModel? newPrompt,
    String? searchQuery,
    List<String>? selectedCategories,
    bool? showOnlyFavorites,
    PromptModel? updatedPrompt,
    String? deletedPromptId,
    // Thêm các tham số mới
    bool? favoriteToggleSuccess,
    PromptModel? lastToggledPrompt,
  }) {
    return PromptState(
      status: status ?? this.status,
      prompts: prompts ?? this.prompts,
      errorMessage: errorMessage ?? this.errorMessage,
      promptListResponse: promptListResponse ?? this.promptListResponse,
      currentQuery: currentQuery ?? this.currentQuery,
      isFavoriteFilter: isFavoriteFilter ?? this.isFavoriteFilter,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isGridView: isGridView ?? this.isGridView,
      sortBy: sortBy ?? this.sortBy,
      newPrompt: newPrompt ?? this.newPrompt,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
      updatedPrompt: updatedPrompt ?? this.updatedPrompt,
      deletedPromptId: deletedPromptId ?? this.deletedPromptId,
      // Thêm các thuộc tính mới
      favoriteToggleSuccess:
          favoriteToggleSuccess ?? this.favoriteToggleSuccess,
      lastToggledPrompt: lastToggledPrompt ?? this.lastToggledPrompt,
    );
  }

  // Thêm phương thức để lấy danh sách đã sắp xếp
  List<Prompt> sortedPrompts() {
    if (prompts == null || prompts!.isEmpty) {
      return [];
    }

    final filteredPrompts = List<PromptModel>.from(prompts!);

    // Lọc theo yêu thích nếu cần
    if (showOnlyFavorites) {
      filteredPrompts.removeWhere((prompt) => !prompt.isFavorite);
    }

    // Lọc theo danh mục nếu cần
    if (selectedCategories.isNotEmpty && !selectedCategories.contains('All')) {
      filteredPrompts.removeWhere((prompt) =>
          prompt.category == null ||
          !selectedCategories.contains(prompt.category));
    }

    // Sắp xếp
    if (sortBy == 'popular') {
      filteredPrompts.sort((a, b) => b.useCount.compareTo(a.useCount));
    } else if (sortBy == 'alphabetical') {
      filteredPrompts.sort((a, b) => a.title.compareTo(b.title));
    } else {
      // Default: sort by recent
      filteredPrompts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    // Chuyển đổi PromptModel sang Prompt
    return filteredPrompts
        .map((model) => Prompt.fromPromptModel(model))
        .toList();
  }
}
