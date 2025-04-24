import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/data/models/prompt/prompt_list_model.dart';
import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:equatable/equatable.dart';

enum PromptStatus { initial, loading, loadingMore, success, failure }

class PromptState extends Equatable {
  final PromptStatus status;
  final List<PromptModel>? prompts;
  final String? errorMessage;
  final String? selectedCategory;
  final Set<String> selectedCategories;
  final bool showOnlyFavorites;
  final String sortBy;
  final bool? isGridView;
  final String searchQuery;
  final String? currentQuery;
  final dynamic
      promptListResponse; // Thay đổi từ PromptListResponse? thành dynamic
  final PromptModel? newPrompt;
  final PromptModel? updatedPrompt;
  final String? deletedPromptId;
  final bool? isFavoriteFilter;
  final bool favoriteToggleSuccess; // Thêm trường này
  final PromptModel? lastToggledPrompt; // Thêm trường này

  const PromptState({
    this.status = PromptStatus.initial,
    this.prompts,
    this.errorMessage,
    this.selectedCategory = 'All',
    this.selectedCategories = const {'all'},
    this.showOnlyFavorites = false,
    this.sortBy = 'recent',
    this.isGridView = true,
    this.searchQuery = '',
    this.currentQuery,
    this.promptListResponse,
    this.newPrompt,
    this.updatedPrompt,
    this.deletedPromptId,
    this.isFavoriteFilter,
    this.favoriteToggleSuccess = false, // Giá trị mặc định
    this.lastToggledPrompt, // Trường này có thể null
  });

  // Cập nhật copyWith để bao gồm các trường mới
  PromptState copyWith({
    PromptStatus? status,
    List<PromptModel>? prompts,
    String? errorMessage,
    String? selectedCategory,
    Set<String>? selectedCategories,
    bool? showOnlyFavorites,
    String? sortBy,
    bool? isGridView,
    String? searchQuery,
    String? currentQuery,
    dynamic promptListResponse,
    PromptModel? newPrompt,
    PromptModel? updatedPrompt,
    String? deletedPromptId,
    bool? isFavoriteFilter,
    bool? favoriteToggleSuccess, // Thêm tham số này
    PromptModel? lastToggledPrompt, // Thêm tham số này
  }) {
    return PromptState(
      status: status ?? this.status,
      prompts: prompts ?? this.prompts,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
      sortBy: sortBy ?? this.sortBy,
      isGridView: isGridView ?? this.isGridView,
      searchQuery: searchQuery ?? this.searchQuery,
      currentQuery: currentQuery ?? this.currentQuery,
      promptListResponse: promptListResponse ?? this.promptListResponse,
      newPrompt: newPrompt,
      updatedPrompt: updatedPrompt,
      deletedPromptId: deletedPromptId,
      isFavoriteFilter: isFavoriteFilter ?? this.isFavoriteFilter,
      favoriteToggleSuccess:
          favoriteToggleSuccess ?? this.favoriteToggleSuccess, // Thêm dòng này
      lastToggledPrompt: lastToggledPrompt, // Thêm dòng này
    );
  }

  // Cập nhật props để bao gồm các trường mới
  @override
  List<Object?> get props => [
        status,
        prompts,
        errorMessage,
        selectedCategory,
        selectedCategories,
        showOnlyFavorites,
        sortBy,
        isGridView,
        searchQuery,
        currentQuery,
        promptListResponse,
        newPrompt,
        updatedPrompt,
        deletedPromptId,
        isFavoriteFilter,
        favoriteToggleSuccess, // Thêm dòng này
        lastToggledPrompt, // Thêm dòng này
      ];

  bool get hasMore => promptListResponse == null
      ? false
      : (promptListResponse is PromptListResponseModel)
          ? promptListResponse.hasNext
          : (promptListResponse as PromptListResponse).hasNext;
}
