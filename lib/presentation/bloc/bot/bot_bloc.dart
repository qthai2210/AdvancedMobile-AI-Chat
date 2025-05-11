import 'package:aichatbot/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/domain/usecases/assistant/get_assistants_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/create_assistant_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/update_assistant_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/delete_assistant_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/link_knowledge_to_assistant_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/remove_knowledge_from_assistant_usecase.dart';
import 'package:aichatbot/data/models/assistant/get_assistants_params.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_event.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_state.dart';

/// BLoC for managing bot/assistant data
class BotBloc extends Bloc<BotEvent, BotState> {
  final GetAssistantsUseCase _getAssistantsUseCase;
  final CreateAssistantUseCase _createAssistantUseCase;
  final UpdateAssistantUseCase _updateAssistantUseCase;
  final DeleteAssistantUseCase _deleteAssistantUseCase;
  final LinkKnowledgeToAssistantUseCase _linkKnowledgeToAssistantUseCase;
  final RemoveKnowledgeFromAssistantUseCase
      _removeKnowledgeFromAssistantUseCase;

  BotBloc({
    required GetAssistantsUseCase getAssistantsUseCase,
    required CreateAssistantUseCase createAssistantUseCase,
    required UpdateAssistantUseCase updateAssistantUseCase,
    required DeleteAssistantUseCase deleteAssistantUseCase,
    required LinkKnowledgeToAssistantUseCase linkKnowledgeToAssistantUseCase,
    required RemoveKnowledgeFromAssistantUseCase
        removeKnowledgeFromAssistantUseCase,
  })  : _getAssistantsUseCase = getAssistantsUseCase,
        _createAssistantUseCase = createAssistantUseCase,
        _updateAssistantUseCase = updateAssistantUseCase,
        _deleteAssistantUseCase = deleteAssistantUseCase,
        _linkKnowledgeToAssistantUseCase = linkKnowledgeToAssistantUseCase,
        _removeKnowledgeFromAssistantUseCase =
            removeKnowledgeFromAssistantUseCase,
        super(BotInitial()) {
    on<FetchBotsEvent>(_onFetchBots);
    on<FetchMoreBotsEvent>(_onFetchMoreBots);
    on<RefreshBotsEvent>(_onRefreshBots);
    on<CreateAssistantEvent>(_onCreateAssistant);
    on<UpdateAssistantEvent>(_onUpdateAssistant);
    on<DeleteAssistantEvent>(_onDeleteAssistant);
    on<LinkKnowledgeToAssistantEvent>(_onLinkKnowledgeToAssistant);
    on<RemoveKnowledgeFromAssistantEvent>(_onRemoveKnowledgeFromAssistant);
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
    // add(FetchBotsEvent(
    //   searchQuery: event.searchQuery,
    //   offset: 0,
    //   limit: 20,
    //   isFavorite: event.isFavorite,
    // ));
    AppLogger.e('Refreshing bots with query: ${event.searchQuery}');
    emit(BotsLoading());
    try {
      final result = await _getAssistantsUseCase.call(
        query: event.searchQuery,
        order: SortOrder.DESC,
        orderField: 'updatedAt',
        offset: 0,
        limit: 20,
        isFavorite: event.isFavorite,
      );
      AppLogger.e(
          'Bots refreshed successfully: ${result.data.length} bots loaded.');
      emit(BotsLoaded(
        bots: result.data,
        hasMore: result.meta.hasNext,
        offset: result.meta.offset,
        total: result.meta.total,
      ));
    } catch (e) {
      AppLogger.e('Error refreshing bots: $e');
      emit(BotsError(message: e.toString()));
    }
  }

  /// Handler for CreateAssistantEvent
  Future<void> _onCreateAssistant(
    CreateAssistantEvent event,
    Emitter<BotState> emit,
  ) async {
    emit(AssistantCreating());

    try {
      final result = await _createAssistantUseCase.call(
        assistantName: event.assistantName,
        instructions: event.instructions,
        description: event.description,
        guidId: event.guidId,
      );

      emit(AssistantCreated(assistant: result));
      // add current assistant to bots list
    } catch (e) {
      emit(AssistantCreationFailed(message: e.toString()));
    }
  }

  /// Handler for UpdateAssistantEvent
  Future<void> _onUpdateAssistant(
    UpdateAssistantEvent event,
    Emitter<BotState> emit,
  ) async {
    emit(AssistantUpdating());

    try {
      final result = await _updateAssistantUseCase.call(
        assistantId: event.assistantId,
        assistantName: event.assistantName,
        instructions: event.instructions,
        description: event.description,
        xJarvisGuid: event.xJarvisGuid,
      );

      emit(AssistantUpdated(assistant: result));
    } catch (e) {
      emit(AssistantUpdateFailed(message: e.toString()));
    }
  }

  /// Handler for DeleteAssistantEvent
  Future<void> _onDeleteAssistant(
    DeleteAssistantEvent event,
    Emitter<BotState> emit,
  ) async {
    emit(AssistantDeleting());

    try {
      final success = await _deleteAssistantUseCase.call(
        assistantId: event.assistantId,
        xJarvisGuid: event.xJarvisGuid,
      );

      if (success) {
        emit(AssistantDeleted(assistantId: event.assistantId));

        // Refresh the list after successful deletion
        add(const RefreshBotsEvent());
      } else {
        emit(const AssistantDeleteFailed(
          message: 'Failed to delete assistant. Please try again.',
        ));
      }
    } catch (e) {
      emit(AssistantDeleteFailed(message: e.toString()));
    }
  }

  /// Handler for LinkKnowledgeToAssistantEvent
  Future<void> _onLinkKnowledgeToAssistant(
    LinkKnowledgeToAssistantEvent event,
    Emitter<BotState> emit,
  ) async {
    emit(AssistantLinkingKnowledge());

    try {
      final success = await _linkKnowledgeToAssistantUseCase.call(
        assistantId: event.assistantId,
        knowledgeId: event.knowledgeId,
        accessToken: event.accessToken,
        xJarvisGuid: event.xJarvisGuid,
      );

      if (success) {
        emit(AssistantKnowledgeLinked(
          assistantId: event.assistantId,
          knowledgeId: event.knowledgeId,
        ));
      } else {
        emit(const AssistantKnowledgeLinkFailed(
          message: 'Failed to link knowledge to assistant. Please try again.',
        ));
      }
    } catch (e) {
      emit(AssistantKnowledgeLinkFailed(message: e.toString()));
    }
  }

  /// Handler for RemoveKnowledgeFromAssistantEvent
  Future<void> _onRemoveKnowledgeFromAssistant(
    RemoveKnowledgeFromAssistantEvent event,
    Emitter<BotState> emit,
  ) async {
    emit(AssistantRemovingKnowledge());

    try {
      final success = await _removeKnowledgeFromAssistantUseCase.call(
        assistantId: event.assistantId,
        knowledgeId: event.knowledgeId,
        accessToken: event.accessToken,
        xJarvisGuid: event.xJarvisGuid,
      );

      if (success) {
        emit(AssistantKnowledgeRemoved(
          assistantId: event.assistantId,
          knowledgeId: event.knowledgeId,
        ));
      } else {
        emit(const AssistantKnowledgeRemoveFailed(
          message:
              'Failed to remove knowledge from assistant. Please try again.',
        ));
      }
    } catch (e) {
      emit(AssistantKnowledgeRemoveFailed(message: e.toString()));
    }
  }
}
