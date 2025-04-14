import 'package:aichatbot/core/di/injection_container.dart' as di;
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/domain/repositories/prompt_repository.dart';
import 'package:aichatbot/domain/usecases/prompt/add_favorite_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/delete_prompt_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/remove_favorite_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/update_prompt_usecase.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/domain/usecases/prompt/get_prompts_usecase.dart';
import 'package:aichatbot/domain/usecases/prompt/create_prompt_usecase.dart';
import 'package:aichatbot/data/models/prompt/prompt_list_model.dart';

class PromptBloc extends Bloc<PromptEvent, PromptState> {
  final GetPromptsUsecase getPromptsUsecase;
  final CreatePromptUsecase createPromptUsecase;
  final UpdatePromptUsecase updatePromptUsecase;
  final DeletePromptUsecase deletePromptUsecase;
  final AddFavoriteUsecase addFavoriteUsecase;
  final RemoveFavoriteUsecase removeFavoriteUsecase;

  PromptBloc({
    required this.getPromptsUsecase,
    required this.createPromptUsecase,
    required this.updatePromptUsecase,
    required this.deletePromptUsecase,
    required this.addFavoriteUsecase,
    required this.removeFavoriteUsecase,
  }) : super(const PromptState()) {
    on<FetchPrompts>(_onFetchPrompts);
    on<CreatePrompt>(_onCreatePrompt);
    on<UpdatePrompt>(_onUpdatePrompt);
    on<DeletePrompt>(_onDeletePrompt);
    on<ToggleFavoriteRequested>(_onToggleFavoriteRequested);
    on<ResetPromptState>(_onResetPromptState);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<CategorySelectionChanged>(_onCategorySelectionChanged);
    on<ToggleShowFavorites>(_onToggleShowFavorites);
    // Các events khác...
  }

  // Các handlers hiện tại...
  void _onCategorySelectionChanged(
      CategorySelectionChanged event, Emitter<PromptState> emit) {
    Set<String> updatedCategories = {...state.selectedCategories};

    if (event.isSelected) {
      if (event.category == 'all') {
        // Nếu "all" được chọn, bỏ tất cả các category khác
        updatedCategories = {'all'};
      } else {
        // Nếu một category khác được chọn, bỏ "all" và thêm category đó
        updatedCategories.remove('all');
        updatedCategories.add(event.category);
      }
    } else {
      // Nếu bỏ chọn một category
      updatedCategories.remove(event.category);
      // Nếu không còn category nào được chọn, chọn "all"
      if (updatedCategories.isEmpty) {
        updatedCategories.add('all');
      }
    }

    // Cập nhật state với danh sách categories đã được cập nhật
    emit(state.copyWith(
      selectedCategories: updatedCategories,
      selectedCategory: event.category,
    ));

    // Tải lại danh sách prompt với category mới
    if (state.status != PromptStatus.loading) {
      // Tìm kiếm lại với category mới
      final authState = di.sl<AuthBloc>().state;
      if (authState.user?.accessToken != null) {
        add(FetchPrompts(
          accessToken: authState.user!.accessToken!,
          limit: 20,
          offset: 0,
          category: event.category == 'all' ? null : event.category,
          isFavorite: state.isFavoriteFilter,
          query: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        ));
      }
    }
  }

  Future<void> _onFetchPrompts(
      FetchPrompts event, Emitter<PromptState> emit) async {
    emit(state.copyWith(
      status: PromptStatus.loading,
      currentQuery: event.query,
    ));

    try {
      final promptsResponse = await getPromptsUsecase(
        accessToken: event.accessToken,
        limit: event.limit ?? 20,
        offset: event.offset ?? 0,
        category: event.category,
        isFavorite: event.isFavorite,
        query: event.query,
        isPublic: event.isPublic, // Truyền tham số isPublic
      );

      // Log kiểu dữ liệu thực tế
      debugPrint('PromptBloc: Response type: ${promptsResponse.runtimeType}');

      emit(state.copyWith(
        status: PromptStatus.success,
        prompts: promptsResponse.items,
        promptListResponse: promptsResponse as dynamic,
        errorMessage: null,
        isFavoriteFilter: event.isFavorite, // Lưu trạng thái filter
      ));
    } catch (error) {
      debugPrint('PromptBloc: Error fetching prompts: $error');
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onUpdatePrompt(
      UpdatePrompt event, Emitter<PromptState> emit) async {
    emit(state.copyWith(status: PromptStatus.loading));

    try {
      final updatedPrompt = await updatePromptUsecase(
        accessToken: event.accessToken,
        promptId: event.promptId,
        title: event.title,
        description: event.description,
        content: event.content,
        category: event.category,
        isPublic: event.isPublic,
      );

      debugPrint(
          'PromptBloc: Successfully updated prompt: ${updatedPrompt.id}');

      // Cập nhật trong danh sách hiện tại nếu có
      List<PromptModel> updatedPrompts = List.from(state.prompts ?? []);
      final index = updatedPrompts.indexWhere((p) => p.id == event.promptId);
      if (index >= 0) {
        updatedPrompts[index] = updatedPrompt;
      }

      // LUÔN CẬP NHẬT updatedPrompt TRONG STATE
      emit(state.copyWith(
        status: PromptStatus.success,
        prompts: updatedPrompts,
        updatedPrompt: updatedPrompt, // Đảm bảo thiết lập này
      ));

      debugPrint(
          'PromptBloc: Emitted success state with updatedPrompt: ${updatedPrompt.id}');
    } catch (error) {
      debugPrint('PromptBloc: Update error: $error');
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onDeletePrompt(
    DeletePrompt event,
    Emitter<PromptState> emit,
  ) async {
    try {
      // Cập nhật state loading
      emit(state.copyWith(status: PromptStatus.loading));

      // Gọi usecase delete prompt
      final result = await deletePromptUsecase(
        accessToken: event.accessToken,
        promptId: event.promptId,
        xJarvisGuid: event.xJarvisGuid,
      );

      if (result) {
        // Xóa prompt khỏi state.prompts nếu có
        if (state.prompts != null) {
          final updatedPrompts = List<PromptModel>.from(state.prompts!)
            ..removeWhere((p) => p.id == event.promptId);

          emit(state.copyWith(
            status: PromptStatus.success,
            prompts: updatedPrompts,
            deletedPromptId: event.promptId,
          ));
        } else {
          emit(state.copyWith(
            status: PromptStatus.success,
            deletedPromptId: event.promptId,
          ));
        }
      } else {
        emit(state.copyWith(
          status: PromptStatus.failure,
          errorMessage: 'Failed to delete prompt',
        ));
      }
    } catch (error) {
      debugPrint('Delete prompt error: $error');
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  // Thêm handler cho CreatePrompt
  Future<void> _onCreatePrompt(
    CreatePrompt event,
    Emitter<PromptState> emit,
  ) async {
    try {
      // Đánh dấu trạng thái đang tải
      emit(state.copyWith(status: PromptStatus.loading));

      // Gọi usecase create prompt
      final result = await createPromptUsecase(
        accessToken: event.accessToken,
        title: event.title,
        content: event.content,
        description: event.description,
        category: event.category,
        isPublic: event.isPublic,
        language: event.language,
        xJarvisGuid: event.xJarvisGuid,
      );

      // Cập nhật state với prompt mới
      if (state.prompts != null) {
        // Thêm prompt mới vào đầu danh sách
        final updatedPrompts = [result, ...state.prompts!];

        emit(state.copyWith(
          status: PromptStatus.success,
          newPrompt: result,
          prompts: updatedPrompts,
        ));
      } else {
        emit(state.copyWith(
          status: PromptStatus.success,
          newPrompt: result,
          prompts: [result],
        ));
      }

      debugPrint('Prompt created successfully with ID: ${result.id}');
    } catch (error) {
      debugPrint('Create prompt error: $error');
      // Cập nhật state lỗi
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  // Thêm handler cho ToggleFavoriteRequested
  Future<void> _onToggleFavoriteRequested(
    ToggleFavoriteRequested event,
    Emitter<PromptState> emit,
  ) async {
    try {
      // Optimistic update - cập nhật UI ngay lập tức
      final promptList = List<PromptModel>.from(state.prompts ?? []);
      final index = promptList.indexWhere((p) => p.id == event.promptId);

      if (index != -1) {
        // Tạo bản sao của prompt với trạng thái yêu thích đảo ngược
        final updatedPrompt = promptList[index].copyWith(
          isFavorite: !promptList[index].isFavorite,
        );

        // Cập nhật danh sách prompts
        promptList[index] = updatedPrompt;

        // Cập nhật state với danh sách đã thay đổi - không kích hoạt thông báo thành công ngay
        emit(state.copyWith(
          prompts: promptList,
          status: PromptStatus.loading, // Set loading để chờ kết quả API
        ));

        bool success;
        try {
          // Gọi API phù hợp dựa trên trạng thái hiện tại
          if (event.currentFavoriteStatus) {
            // Nếu đang là yêu thích, gọi API xóa khỏi yêu thích
            success = await removeFavoriteUsecase(
              accessToken: event.accessToken,
              promptId: event.promptId,
              xJarvisGuid: event.xJarvisGuid,
            );
          } else {
            // Nếu chưa yêu thích, gọi API thêm vào yêu thích
            success = await addFavoriteUsecase(
              accessToken: event.accessToken,
              promptId: event.promptId,
              xJarvisGuid: event.xJarvisGuid,
            );
          }

          if (success) {
            // Nếu API thành công, cập nhật state với trạng thái thành công
            emit(state.copyWith(
              status: PromptStatus.success,
              favoriteToggleSuccess: true,
              lastToggledPrompt: promptList[index],
            ));
          } else {
            // Nếu API không thành công, hoàn tác lại thay đổi UI
            _revertFavoriteChangeInUI(
              promptList: promptList,
              index: index,
              emit: emit,
            );
          }
        } catch (apiError) {
          debugPrint('Toggle favorite API error: $apiError');
          // Nếu có lỗi xảy ra, hoàn tác lại thay đổi UI
          _revertFavoriteChangeInUI(
            promptList: promptList,
            index: index,
            emit: emit,
          );
        }
      }
    } catch (error) {
      debugPrint('Toggle favorite error: $error');
      emit(state.copyWith(
        status: PromptStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _revertFavoriteChangeInUI({
    required List<PromptModel> promptList,
    required int index,
    required Emitter<PromptState> emit,
  }) {
    // Hoàn tác lại thay đổi UI bằng cách đảo ngược trạng thái yêu thích
    final revertedPrompt = promptList[index].copyWith(
      isFavorite: !promptList[index].isFavorite,
    );
    promptList[index] = revertedPrompt;

    // Cập nhật lại state với danh sách prompts đã hoàn tác
    emit(state.copyWith(
      prompts: promptList,
      status: PromptStatus
          .success, // Có thể cần thay đổi trạng thái này tùy theo logic của bạn
    ));
  }

  void _onResetPromptState(ResetPromptState event, Emitter<PromptState> emit) {
    debugPrint('PromptBloc: Resetting prompt state');
    // Giữ lại danh sách prompts nhưng reset các trạng thái khác
    emit(state.copyWith(
      status: PromptStatus.initial,
      errorMessage: null,
      updatedPrompt: null,
    ));
  }

  void _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<PromptState> emit) {
    // Cập nhật searchQuery trong state
    emit(state.copyWith(
      searchQuery: event.query,
    ));
  }

  void _onToggleShowFavorites(
      ToggleShowFavorites event, Emitter<PromptState> emit) {
    emit(state.copyWith(
      showOnlyFavorites: event.showOnlyFavorites,
      isFavoriteFilter: event.showOnlyFavorites,
    ));

    // Tải lại danh sách với filter mới
    final authState = di.sl<AuthBloc>().state;
    if (authState.user?.accessToken != null) {
      add(FetchPrompts(
        accessToken: authState.user!.accessToken!,
        limit: 20,
        offset: 0,
        category:
            state.selectedCategory == 'all' ? null : state.selectedCategory,
        isFavorite: event.showOnlyFavorites,
        query: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      ));
    }
  }
}
