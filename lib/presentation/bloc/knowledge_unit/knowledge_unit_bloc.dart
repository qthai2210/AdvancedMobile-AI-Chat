import 'package:aichatbot/domain/usecases/knowledge_unit/delete_datasource_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/fetch_knowledge_units_use_case.dart';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_event.dart';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_state.dart';
import 'package:aichatbot/utils/logger.dart';

class KnowledgeUnitBloc extends Bloc<KnowledgeUnitEvent, KnowledgeUnitState> {
  final FetchKnowledgeUnitsUseCase fetchKnowledgeUnitsUseCase;
  final DeleteDatasourceUseCase deleteDatasourceUseCase;

  KnowledgeUnitBloc({
    required this.fetchKnowledgeUnitsUseCase,
    required this.deleteDatasourceUseCase,
  }) : super(KnowledgeUnitInitial()) {
    on<FetchKnowledgeUnitsEvent>(_onFetchKnowledgeUnits);
    on<DeleteDatasourceEvent>(_onDeleteDatasource);
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

  Future<void> _onDeleteDatasource(
    DeleteDatasourceEvent e,
    Emitter<KnowledgeUnitState> emit,
  ) async {
    emit(KnowledgeUnitLoading());
    try {
      await deleteDatasourceUseCase.call(
        knowledgeId: e.knowledgeId,
        datasourceId: e.datasourceId,
        accessToken: e.accessToken,
      );
      // sau khi xóa thành công, reload lại danh sách
      add(FetchKnowledgeUnitsEvent(
        knowledgeId: e.knowledgeId,
        accessToken: e.accessToken,
      ));
    } catch (ex) {
      emit(KnowledgeUnitError(message: e.toString()));
    }
  }
}
