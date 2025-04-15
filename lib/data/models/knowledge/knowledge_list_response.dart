import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';

class KnowledgeListResponse {
  final List<KnowledgeModel> data;
  final KnowledgeMetadata meta;

  KnowledgeListResponse({
    required this.data,
    required this.meta,
  });

  factory KnowledgeListResponse.fromJson(Map<String, dynamic> json) {
    return KnowledgeListResponse(
      data: (json['data'] as List)
          .map((item) => KnowledgeModel.fromJson(item))
          .toList(),
      meta: KnowledgeMetadata.fromJson(json['meta']),
    );
  }
}

class KnowledgeMetadata {
  final int limit;
  final int total;
  final int offset;
  final bool hasNext;

  KnowledgeMetadata({
    required this.limit,
    required this.total,
    required this.offset,
    required this.hasNext,
  });

  factory KnowledgeMetadata.fromJson(Map<String, dynamic> json) {
    return KnowledgeMetadata(
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      offset: json['offset'] ?? 0,
      hasNext: json['hasNext'] ?? false,
    );
  }
}
