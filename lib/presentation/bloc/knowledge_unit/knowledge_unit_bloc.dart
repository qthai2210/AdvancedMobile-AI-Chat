import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/fetch_knowledge_units_use_case.dart';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_event.dart';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_state.dart';
import 'package:aichatbot/utils/logger.dart';

class KnowledgeUnitBloc extends Bloc<KnowledgeUnitEvent, KnowledgeUnitState> {
  final FetchKnowledgeUnitsUseCase fetchKnowledgeUnitsUseCase;

  KnowledgeUnitBloc({
    required this.fetchKnowledgeUnitsUseCase,
  }) : super(KnowledgeUnitInitial()) {
    on<FetchKnowledgeUnitsEvent>(_onFetchKnowledgeUnits);
  }

  Future<void> _onFetchKnowledgeUnits(
    FetchKnowledgeUnitsEvent event,
    Emitter<KnowledgeUnitState> emit,
  ) async {
    emit(KnowledgeUnitLoading());
    try {
      final response = await fetchKnowledgeUnitsUseCase.execute(
        knowledgeId: event.knowledgeId,
        accessToken: event.accessToken,
      );

      // Now we have both units and metadata
      emit(KnowledgeUnitLoaded(
        units: response.units,
        meta: response.meta,
      ));

      AppLogger.d(
          'Loaded ${response.units[0].id} units with metadata: ${response.meta}');
    } catch (e) {
      AppLogger.e('Error fetching knowledge units: $e');
      emit(KnowledgeUnitError(message: e.toString()));
    }
  }
}
