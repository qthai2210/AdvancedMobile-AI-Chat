import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:aichatbot/domain/usecases/knowledge/get_assistant_knowledges_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge/update_knowledge_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/data/models/knowledge/create_knowledge_params.dart';
import 'package:aichatbot/domain/usecases/knowledge/create_knowledge_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge/delete_knowledge_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge/get_knowledges_usecase.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_event.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_state.dart';
import 'package:aichatbot/utils/logger.dart';

/// BLoC for managing knowledge base data
class KnowledgeBloc extends Bloc<KnowledgeEvent, KnowledgeState> {
  final GetKnowledgesUseCase _getKnowledgesUseCase;
  final CreateKnowledgeUseCase _createKnowledgeUseCase;
  final DeleteKnowledgeUseCase _deleteKnowledgeUseCase;
  final UpdateKnowledgeUseCase _updateKnowledgeUseCase;
  final GetAssistantKnowledgesUseCase _getAssistantKnowledgesUseCase;

  KnowledgeBloc({
    required GetKnowledgesUseCase getKnowledgesUseCase,
    required CreateKnowledgeUseCase createKnowledgeUseCase,
    required DeleteKnowledgeUseCase deleteKnowledgeUseCase,
    required UpdateKnowledgeUseCase updateKnowledgeUseCase,
    required GetAssistantKnowledgesUseCase getAssistantKnowledgesUseCase,
  })  : _getKnowledgesUseCase = getKnowledgesUseCase,
        _createKnowledgeUseCase = createKnowledgeUseCase,
        _deleteKnowledgeUseCase = deleteKnowledgeUseCase,
        _updateKnowledgeUseCase = updateKnowledgeUseCase,
        _getAssistantKnowledgesUseCase = getAssistantKnowledgesUseCase,
        super(KnowledgeInitial()) {
    on<FetchKnowledgesEvent>(_onFetchKnowledges);
    on<FetchMoreKnowledgesEvent>(_onFetchMoreKnowledges);
    on<RefreshKnowledgesEvent>(_onRefreshKnowledges);
    on<CreateKnowledgeEvent>(_onCreateKnowledge);
    on<DeleteKnowledgeEvent>(_onDeleteKnowledge);
    on<UpdateKnowledgeEvent>(_onUpdateKnowledge);
    on<FetchAssistantKnowledgesEvent>(_onFetchAssistantKnowledges);
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

  /// Handles the [CreateKnowledgeEvent] to create a new knowledge base
  Future<void> _onCreateKnowledge(
    CreateKnowledgeEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    try {
      // First get the current state to later update it with the new knowledge
      final currentState = state;

      AppLogger.i('Creating knowledge base: ${event.knowledgeName}');

      final createParams = CreateKnowledgeParams(
        knowledgeName: event.knowledgeName,
        description: event.description,
        xJarvisGuid: event.xJarvisGuid,
      );

      final createdKnowledge = await _createKnowledgeUseCase(createParams);
      AppLogger.i(
          'Knowledge base created successfully: ${createdKnowledge.knowledgeName}');

      // If we're already in a loaded state, add the new knowledge to the list
      if (currentState is KnowledgeLoaded) {
        final updatedKnowledges = [
          createdKnowledge,
          ...currentState.knowledges
        ];

        emit(KnowledgeLoaded(
          knowledges: updatedKnowledges,
          hasReachedMax: currentState.hasReachedMax,
          currentOffset: currentState.currentOffset + 1,
          total: currentState.total + 1,
        ));
      } else {
        // If not in a loaded state, trigger a refresh to get the updated list
        add(const RefreshKnowledgesEvent(limit: 20));
      }
    } catch (e) {
      AppLogger.e('Error creating knowledge base: $e');
      emit(KnowledgeError('Failed to create knowledge base: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateKnowledge(
    UpdateKnowledgeEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    try {
      // First get the current state to later update it with the new knowledge
      final currentState = state;

      AppLogger.i('Updating knowledge base: ${event.knowledgeName}');

      final updateParams = CreateKnowledgeParams(
        knowledgeName: event.knowledgeName,
        description: event.description,
        xJarvisGuid: event.xJarvisGuid,
      );

      final updatedKnowledge =
          await _updateKnowledgeUseCase(event.id, updateParams);
      AppLogger.i('Knowledge base updated successfully: ${updatedKnowledge}');

      // If we're already in a loaded state, update the knowledge in the list
      if (currentState is KnowledgeLoaded) {
        final updatedKnowledges =
            currentState.knowledges.map<KnowledgeModel>((knowledge) {
          // Replace the updated knowledge in the list
          if (knowledge.id == event.id) {
            return updatedKnowledge;
          }
          return knowledge;
        }).toList();

        emit(KnowledgeLoaded(
          knowledges: updatedKnowledges,
          hasReachedMax: currentState.hasReachedMax,
          currentOffset: currentState.currentOffset,
          total: currentState.total,
        ));
      } else {
        // If not in a loaded state, trigger a refresh to get the updated list
        add(const RefreshKnowledgesEvent(limit: 20));
      }
    } catch (e) {
      AppLogger.e('Error updating knowledge base: $e');
      emit(KnowledgeError('Failed to update knowledge base: ${e.toString()}'));
    }
  }

  /// Handles the [DeleteKnowledgeEvent] to delete a knowledge base
  Future<void> _onDeleteKnowledge(
    DeleteKnowledgeEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    try {
      // Get the current state to update it after deletion
      final currentState = state;

      AppLogger.i('Deleting knowledge base with ID: ${event.id}');

      // Call the use case to delete the knowledge
      final success = await _deleteKnowledgeUseCase(event.id,
          xJarvisGuid: event.xJarvisGuid);

      if (success) {
        AppLogger.i('Knowledge base deleted successfully');

        // If we're in a loaded state, update the list by removing the deleted item
        if (currentState is KnowledgeLoaded) {
          final updatedKnowledges = currentState.knowledges
              .where((knowledge) => knowledge.id != event.id)
              .toList();

          emit(KnowledgeLoaded(
            knowledges: updatedKnowledges,
            hasReachedMax: currentState.hasReachedMax,
            currentOffset: currentState.currentOffset,
            total: currentState.total - 1,
          ));
        } else {
          // If not in a loaded state, trigger a refresh
          add(const RefreshKnowledgesEvent(limit: 20));
        }
      } else {
        emit(const KnowledgeError('Failed to delete knowledge base'));
      }
    } catch (e) {
      AppLogger.e('Error deleting knowledge base: $e');
      emit(KnowledgeError('Failed to delete knowledge base: ${e.toString()}'));
    }
  }

  /// Handles the [FetchAssistantKnowledgesEvent] to load knowledge bases attached to an assistant
  Future<void> _onFetchAssistantKnowledges(
    FetchAssistantKnowledgesEvent event,
    Emitter<KnowledgeState> emit,
  ) async {
    emit(KnowledgeLoading());

    try {
      final response = await _getAssistantKnowledgesUseCase.execute(
        assistantId: event.assistantId,
        q: event.searchQuery,
        order: event.order,
        orderField: event.orderField,
        offset: event.offset,
        limit: event.limit,
        xJarvisGuid: event.xJarvisGuid,
        accessToken: event.accessToken,
      );

      emit(KnowledgeLoaded(
        knowledges: response.data,
        hasReachedMax: !response.meta.hasNext,
        currentOffset: event.offset + response.data.length,
        total: response.meta.total,
      ));

      AppLogger.i('Loaded ${response.data.length} assistant knowledge bases');
    } catch (e) {
      AppLogger.e('Error fetching assistant knowledges: $e');
      emit(KnowledgeError(
          'Failed to load assistant knowledges: ${e.toString()}'));
    }
  }
}
