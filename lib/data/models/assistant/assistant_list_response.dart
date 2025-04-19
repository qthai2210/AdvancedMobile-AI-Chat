import 'package:aichatbot/data/models/assistant/assistant_model.dart';

class AssistantListResponse {
  final List<AssistantModel> data;
  final MetaData meta;

  AssistantListResponse({
    required this.data,
    required this.meta,
  });

  factory AssistantListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List;
    final assistants =
        dataList.map((item) => AssistantModel.fromJson(item)).toList();

    return AssistantListResponse(
      data: assistants,
      meta: MetaData.fromJson(json['meta']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((assistant) => assistant.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class MetaData {
  final int limit;
  final int total;
  final int offset;
  final bool hasNext;

  MetaData({
    required this.limit,
    required this.total,
    required this.offset,
    required this.hasNext,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      offset: json['offset'] ?? 0,
      hasNext: json['hasNext'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limit': limit,
      'total': total,
      'offset': offset,
      'hasNext': hasNext,
    };
  }
}
