abstract class KnowledgeUnitEvent {}

class FetchKnowledgeUnitsEvent extends KnowledgeUnitEvent {
  final String knowledgeId;
  final String accessToken;

  FetchKnowledgeUnitsEvent({
    required this.knowledgeId,
    required this.accessToken,
  });
}
