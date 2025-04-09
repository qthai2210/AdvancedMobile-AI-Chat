import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/domain/usecases/prompt/get_prompts_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/create_prompt_usecase.dart';
import 'package:aichatbot/data/models/prompt/prompt_list_model.dart'
    as prompt_list;
import 'package:aichatbot/core/errors/failures.dart';

class PromptBloc extends Bloc<PromptEvent, PromptState> {
  final GetPromptsUsecase getPromptsUsecase;
  final CreatePromptUsecase createPromptUsecase;

  PromptBloc({
    required this.getPromptsUsecase,
    required this.createPromptUsecase,
  }) : super(const PromptState()) {
    on<FetchPrompts>(_onFetchPrompts);
    on<LoadMorePrompts>(_onLoadMorePrompts);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<CategorySelected>(_onCategorySelected);
    on<CategorySelectionChanged>(_onCategorySelectionChanged);
    on<SortMethodChanged>(_onSortMethodChanged);
    on<ToggleShowFavorites>(_onToggleShowFavorites);
    on<ToggleViewMode>(_onToggleViewMode);
    on<ToggleFavoriteRequested>(_onToggleFavoriteRequested);
    on<CreatePrompt>(_onCreatePrompt);
  }

  void _onFetchPrompts(
    FetchPrompts event,
    Emitter<PromptState> emit,
  ) async {
    emit(state.copyWith(status: PromptStatus.loading));

    try {
      // Thêm log để kiểm tra
      print(
          "Fetching prompts with parameters: ${event.accessToken.substring(0, 10)}..., query: ${event.query}, offset: ${event.offset}, limit: ${event.limit}, category: ${event.category}, isFavorite: ${event.isFavorite}, isPublic: ${event.isPublic}");

      final result = await getPromptsUsecase(
        accessToken: event.accessToken,
        query: event.query ?? state.currentQuery,
        offset: event.offset ?? 0,
        limit: event.limit ?? 20,
        category: event.category ?? state.selectedCategory,
        isFavorite: event.isFavorite ?? state.isFavoriteFilter,
        isPublic: event.isPublic,
      );

      // Log để kiểm tra kết quả trả về
      print(
          "Prompts fetched successfully. Items count: ${result.items.length}");

      emit(state.copyWith(
        status: PromptStatus.success,
        prompts: result.items,
        promptListResponse: result,
        currentQuery: event.query ?? state.currentQuery,
        selectedCategory: event.category ?? state.selectedCategory,
        searchQuery: event.query ?? state.searchQuery,
      ));

      // Log state sau khi cập nhật
      print("Updated state with ${state.prompts.length} prompts");
    } catch (error) {
      print("Error fetching prompts: $error");
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onLoadMorePrompts(
    LoadMorePrompts event,
    Emitter<PromptState> emit,
  ) async {
    if (state.status == PromptStatus.loading ||
        state.status == PromptStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: PromptStatus.loadingMore));

    try {
      final result = await getPromptsUsecase(
        accessToken: event.accessToken,
        query: event.query ?? state.currentQuery,
        offset: event.offset,
        limit: event.limit,
        category: event.category ?? state.selectedCategory,
        isFavorite: event.isFavorite ?? state.isFavoriteFilter,
        isPublic: event.isPublic,
      );

      // Đã được sửa: result đã là PromptListResponseModel, không cần fromJson nữa
      // Kết hợp danh sách hiện tại với các item mới
      final updatedPrompts = [...state.prompts, ...result.items];

      emit(state.copyWith(
        status: PromptStatus.success,
        prompts: updatedPrompts,
        promptListResponse: result,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<PromptState> emit,
  ) {
    emit(state.copyWith(
      currentQuery: event.query,
      searchQuery: event.query,
    ));
  }

  void _onCategorySelected(
    CategorySelected event,
    Emitter<PromptState> emit,
  ) {
    emit(state.copyWith(
      selectedCategory: event.category,
      selectedCategories: event.category != null ? [event.category!] : ['All'],
    ));
  }

  void _onCategorySelectionChanged(
    CategorySelectionChanged event,
    Emitter<PromptState> emit,
  ) {
    List<String> updatedCategories = [...state.selectedCategories];

    if (event.isSelected) {
      if (event.category == 'All') {
        updatedCategories = ['All'];
      } else {
        if (updatedCategories.contains('All')) {
          updatedCategories.remove('All');
        }
        if (!updatedCategories.contains(event.category)) {
          updatedCategories.add(event.category);
        }
      }
    } else {
      if (event.category != 'All') {
        updatedCategories.remove(event.category);
        if (updatedCategories.isEmpty) {
          updatedCategories = ['All'];
        }
      }
    }

    emit(state.copyWith(
      selectedCategories: updatedCategories,
      selectedCategory: updatedCategories.contains('All')
          ? null
          : updatedCategories.isNotEmpty
              ? updatedCategories[0]
              : null,
    ));
  }

  void _onSortMethodChanged(
    SortMethodChanged event,
    Emitter<PromptState> emit,
  ) {
    emit(state.copyWith(sortBy: event.sortBy));

    // Trong triển khai thực tế, bạn có thể muốn sắp xếp lại danh sách prompts
    // dựa trên thuộc tính sortBy
    if (state.prompts.isNotEmpty) {
      List<PromptModel> sortedPrompts = [...state.prompts];
      switch (event.sortBy) {
        case 'popular':
          sortedPrompts.sort((a, b) => b.useCount.compareTo(a.useCount));
          break;
        case 'recent':
          sortedPrompts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'alphabetical':
          sortedPrompts.sort((a, b) => a.title.compareTo(b.title));
          break;
      }
      emit(state.copyWith(prompts: sortedPrompts));
    }
  }

  void _onToggleShowFavorites(
    ToggleShowFavorites event,
    Emitter<PromptState> emit,
  ) {
    emit(state.copyWith(
      showOnlyFavorites: event.showOnlyFavorites,
      isFavoriteFilter: event.showOnlyFavorites,
    ));
  }

  void _onToggleViewMode(
    ToggleViewMode event,
    Emitter<PromptState> emit,
  ) {
    emit(state.copyWith(isGridView: event.isGridView));
  }

  void _onToggleFavoriteRequested(
    ToggleFavoriteRequested event,
    Emitter<PromptState> emit,
  ) async {
    // Trong triển khai thực tế, bạn sẽ gọi API để thay đổi trạng thái yêu thích
    // và sau đó cập nhật state với kết quả từ API

    // Triển khai tạm thời: Cập nhật trạng thái yêu thích cục bộ
    final updatedPrompts = state.prompts.map((prompt) {
      if (prompt.id == event.promptId) {
        return prompt.copyWith(isFavorite: !prompt.isFavorite);
      }
      return prompt;
    }).toList();

    emit(state.copyWith(prompts: updatedPrompts));
  }

  void _onCreatePrompt(
    CreatePrompt event,
    Emitter<PromptState> emit,
  ) async {
    emit(state.copyWith(status: PromptStatus.loading));

    try {
      final prompt = await createPromptUsecase(
        accessToken: event.accessToken,
        title: event.title,
        content: event.content,
        description: event.description,
        category: event.category,
        isPublic: event.isPublic,
        language: event.language,
        xJarvisGuid: event.xJarvisGuid,
      );

      // Thêm prompt mới vào đầu danh sách
      final updatedPrompts = [prompt, ...state.prompts];

      // Cập nhật danh sách prompt và trạng thái
      emit(state.copyWith(
        status: PromptStatus.success,
        prompts: updatedPrompts,
        // Giữ lại promptListResponse hiện tại để duy trì thông tin phân trang
        newPrompt: prompt,
      ));
    } on AuthFailure catch (failure) {
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: failure.message,
      ));
    } on ServerFailure catch (failure) {
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: failure.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }
}
