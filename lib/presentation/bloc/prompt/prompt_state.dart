import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/data/models/prompt/prompt_list_model.dart';

enum PromptStatus { initial, loading, loadingMore, success, failure }

class PromptState {
  final PromptStatus status;
  final List<PromptModel> prompts;
  final PromptListResponseModel? promptListResponse;
  final String? currentQuery;
  final String? selectedCategory;
  final String? errorMessage;
  final bool isFavoriteFilter;
  final bool showOnlyFavorites;
  final bool isGridView;
  final List<String> selectedCategories;
  final String sortBy;
  final String? searchQuery;
  final PromptModel? newPrompt; // Thêm trường này

  const PromptState({
    this.status = PromptStatus.initial,
    this.prompts = const [],
    this.promptListResponse,
    this.currentQuery,
    this.selectedCategory,
    this.errorMessage,
    this.isFavoriteFilter = false,
    this.showOnlyFavorites = false,
    this.isGridView = false,
    this.selectedCategories = const ['All'],
    this.sortBy = 'recent',
    this.searchQuery,
    this.newPrompt, // Thêm trường này
  });

  PromptState copyWith({
    PromptStatus? status,
    List<PromptModel>? prompts,
    PromptListResponseModel? promptListResponse,
    String? currentQuery,
    String? selectedCategory,
    String? errorMessage,
    bool? isFavoriteFilter,
    bool? showOnlyFavorites,
    bool? isGridView,
    List<String>? selectedCategories,
    String? sortBy,
    String? searchQuery,
    PromptModel? newPrompt, // Thêm parameter này
  }) {
    return PromptState(
      status: status ?? this.status,
      prompts: prompts ?? this.prompts,
      promptListResponse: promptListResponse ?? this.promptListResponse,
      currentQuery: currentQuery ?? this.currentQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage ?? this.errorMessage,
      isFavoriteFilter: isFavoriteFilter ?? this.isFavoriteFilter,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
      isGridView: isGridView ?? this.isGridView,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
      newPrompt: newPrompt, // Nếu null, sẽ reset trường newPrompt
    );
  }

  List<PromptModel> filteredPrompts() {
    return prompts.where((prompt) {
      // Apply favorites filter
      if (showOnlyFavorites && !prompt.isFavorite) {
        return false;
      }

      // Apply search filter
      final matchesSearch = searchQuery == null ||
          searchQuery!.isEmpty ||
          prompt.title.toLowerCase().contains(searchQuery!.toLowerCase()) ||
          prompt.description.toLowerCase().contains(searchQuery!.toLowerCase());

      // Apply category filter
      final matchesCategory = selectedCategories.contains('All') ||
          prompt.categories.any(
            (category) => selectedCategories.contains(category),
          );

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<PromptModel> sortedPrompts() {
    final filteredList = filteredPrompts();
    print('Filtered prompts: ${filteredList.length}'); // Debugging line
    print('Sort by: $sortBy'); // Debugging line
    switch (sortBy) {
      case 'popular':
        filteredList.sort((a, b) => b.useCount.compareTo(a.useCount));
        break;
      case 'recent':
        filteredList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'alphabetical':
        filteredList.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filteredList;
  }
}
