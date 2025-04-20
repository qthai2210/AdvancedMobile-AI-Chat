import 'package:aichatbot/data/models/knowledge/knowledge_unit_model.dart';

class KnowledgeUnitsResponse {
  final List<KnowledgeUnitModel> units;
  final Map<String, dynamic> meta;

  KnowledgeUnitsResponse({
    required this.units,
    required this.meta,
  });
}
