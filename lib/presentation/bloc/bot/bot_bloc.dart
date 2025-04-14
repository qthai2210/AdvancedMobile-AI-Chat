import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/domain/usecases/assistant/get_assistants_usecase.dart';
import 'package:aichatbot/data/models/assistant/get_assistants_params.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_event.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_state.dart';

/// BLoC for managing bot/assistant data
class BotBloc extends Bloc<BotEvent, BotState> {
  final GetAssistantsUseCase _getAssistantsUseCase;

  BotBloc({
    required GetAssistantsUseCase getAssistantsUseCase,
  })  : _getAssistantsUseCase = getAssistantsUseCase,
        super(BotInitial()) {
    on<FetchBotsEvent>(_onFetchBots);
    on<FetchMoreBotsEvent>(_onFetchMoreBots);
    on<RefreshBotsEvent>(_onRefreshBots);
  }

  /// Handler for FetchBotsEvent
  Future<void> _onFetchBots(
    FetchBotsEvent event,
    Emitter<BotState> emit,
  ) async {
    emit(BotsLoading());

    try {
      final result = await _getAssistantsUseCase.call(
        query: event.searchQuery,
        order: SortOrder.DESC,
        orderField: 'updatedAt',
        offset: event.offset,
        limit: event.limit,
        isFavorite: event.isFavorite,
      );

      emit(BotsLoaded(
        bots: result.data,
        hasMore: result.meta.hasNext,
        offset: result.meta.offset,
        total: result.meta.total,
      ));
    } catch (e) {
      emit(BotsError(message: e.toString()));
    }
  }

  /// Handler for FetchMoreBotsEvent
  Future<void> _onFetchMoreBots(
    FetchMoreBotsEvent event,
    Emitter<BotState> emit,
  ) async {
    if (state is BotsLoaded) {
      final currentState = state as BotsLoaded;

      emit(BotsLoadingMore(
        bots: currentState.bots,
        hasMore: currentState.hasMore,
      ));

      try {
        final result = await _getAssistantsUseCase.call(
          query: event.searchQuery,
          order: SortOrder.DESC,
          orderField: 'updatedAt',
          offset: event.offset,
          limit: event.limit,
          isFavorite: event.isFavorite,
        );

        final updatedBots = [...currentState.bots, ...result.data];

        emit(BotsLoaded(
          bots: updatedBots,
          hasMore: result.meta.hasNext,
          offset: result.meta.offset + result.data.length,
          total: result.meta.total,
        ));
      } catch (e) {
        emit(BotsError(message: e.toString()));
      }
    }
  }

  /// Handler for RefreshBotsEvent
  Future<void> _onRefreshBots(
    RefreshBotsEvent event,
    Emitter<BotState> emit,
  ) async {
    // Reuse the fetch bots logic but always start from offset 0
    add(FetchBotsEvent(
      searchQuery: event.searchQuery,
      offset: 0,
      limit: 20,
      isFavorite: event.isFavorite,
    ));
  }
}
