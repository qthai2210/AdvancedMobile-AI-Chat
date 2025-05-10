abstract class KnowledgeUnitEvent {}

class FetchKnowledgeUnitsEvent extends KnowledgeUnitEvent {
  final String knowledgeId;
  final String accessToken;

  FetchKnowledgeUnitsEvent({
    required this.knowledgeId,
    required this.accessToken,
  });
}

class DeleteDatasourceEvent extends KnowledgeUnitEvent {
  final String knowledgeId;
  final String datasourceId;
  final String accessToken;
  DeleteDatasourceEvent({
    required this.knowledgeId,
    required this.datasourceId,
    required this.accessToken,
  });
  @override
  List<Object?> get props => [knowledgeId, datasourceId, accessToken];
}
