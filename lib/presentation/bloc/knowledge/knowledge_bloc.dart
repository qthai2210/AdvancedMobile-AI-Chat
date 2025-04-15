import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/domain/usecases/knowledge/get_knowledges_usecase.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_event.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_state.dart';
import 'package:aichatbot/utils/logger.dart';

/// BLoC for managing knowledge base data
class KnowledgeBloc extends Bloc<KnowledgeEvent, KnowledgeState> {
  final GetKnowledgesUseCase _getKnowledgesUseCase;

  KnowledgeBloc({
    required GetKnowledgesUseCase getKnowledgesUseCase,
  })  : _getKnowledgesUseCase = getKnowledgesUseCase,
        super(KnowledgeInitial()) {
    on<FetchKnowledgesEvent>(_onFetchKnowledges);
    on<FetchMoreKnowledgesEvent>(_onFetchMoreKnowledges);
    on<RefreshKnowledgesEvent>(_onRefreshKnowledges);
  }

  /// Handles the [FetchKnowledgesEvent] to load initial knowledges
  Future<void> _onFetchKnowledges(
    FetchKnowledgesEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    emit(KnowledgeLoading());

    try {
      final response = await _getKnowledgesUseCase.execute(
        query: event.searchQuery,
        order: event.order,
        orderField: event.orderField,
        offset: event.offset,
        limit: event.limit,
      );

      emit(KnowledgeLoaded(
        knowledges: response.data,
        hasReachedMax: !response.meta.hasNext,
        currentOffset: event.offset + response.data.length,
        total: response.meta.total,
      ));

      AppLogger.i('Loaded ${response.data.length} knowledges');
    } catch (e) {
      AppLogger.e('Error fetching knowledges: $e');
      emit(KnowledgeError('Failed to load knowledges: ${e.toString()}'));
    }
  }

  /// Handles the [FetchMoreKnowledgesEvent] to load more knowledges (pagination)
  Future<void> _onFetchMoreKnowledges(
    FetchMoreKnowledgesEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    // Only proceed if we're in a loaded state and haven't reached max
    final currentState = state;
    if (currentState is KnowledgeLoaded && !currentState.hasReachedMax) {
      emit(KnowledgeLoadingMore(
        knowledges: currentState.knowledges,
        hasReachedMax: currentState.hasReachedMax,
        currentOffset: currentState.currentOffset,
        total: currentState.total,
      ));

      try {
        final response = await _getKnowledgesUseCase.execute(
          query: event.searchQuery,
          order: event.order,
          orderField: event.orderField,
          offset: event.offset,
          limit: event.limit,
        );

        // Combine previous and new knowledges
        final allKnowledges = List.of(currentState.knowledges)
          ..addAll(response.data);

        emit(KnowledgeLoaded(
          knowledges: allKnowledges,
          hasReachedMax: !response.meta.hasNext,
          currentOffset: event.offset + response.data.length,
          total: response.meta.total,
        ));

        AppLogger.i(
            'Loaded ${response.data.length} more knowledges, total: ${allKnowledges.length}');
      } catch (e) {
        AppLogger.e('Error fetching more knowledges: $e');
        // Return to the previous state but with an error message
        emit(KnowledgeError('Failed to load more knowledges: ${e.toString()}'));
      }
    }
  }

  /// Handles the [RefreshKnowledgesEvent] to refresh knowledges
  Future<void> _onRefreshKnowledges(
    RefreshKnowledgesEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    // Refresh always starts from offset 0
    try {
      final response = await _getKnowledgesUseCase.execute(
        query: event.searchQuery,
        order: event.order,
        orderField: event.orderField,
        offset: 0,
        limit: event.limit,
      );

      emit(KnowledgeLoaded(
        knowledges: response.data,
        hasReachedMax: !response.meta.hasNext,
        currentOffset: response.data.length,
        total: response.meta.total,
      ));

      AppLogger.i('Refreshed knowledges, loaded ${response.data.length}');
    } catch (e) {
      AppLogger.e('Error refreshing knowledges: $e');
      emit(KnowledgeError('Failed to refresh knowledges: ${e.toString()}'));
    }
  }
}
