import 'package:aichatbot/data/models/knowledge/knowledge_unit_model.dart';
import 'package:equatable/equatable.dart';

class KnowledgeUnitListResponse extends Equatable {
  final List<KnowledgeUnitModel> data;
  final Meta meta;

  const KnowledgeUnitListResponse({
    required this.data,
    required this.meta,
  });

  factory KnowledgeUnitListResponse.fromJson(Map<String, dynamic> json) {
    return KnowledgeUnitListResponse(
      data: (json['data'] as List)
          .map((item) => KnowledgeUnitModel.fromJson(item))
          .toList(),
      meta: Meta.fromJson(json['meta']),
    );
  }

  @override
  List<Object> get props => [data, meta];
}

class Meta extends Equatable {
  final int limit;
  final int offset;
  final int total;
  final bool hasNext;

  const Meta({
    required this.limit,
    required this.offset,
    required this.total,
    required this.hasNext,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      total: json['total'] as int,
      hasNext: json['hasNext'] as bool,
    );
  }

  @override
  List<Object> get props => [limit, offset, total, hasNext];
}
