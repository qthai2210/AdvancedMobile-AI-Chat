import 'package:aichatbot/data/models/prompt/prompt_model.dart';

class PromptListResponseModel {
  final bool hasNext;
  final int offset;
  final int limit;
  final int total;
  final List<PromptModel> items;

  PromptListResponseModel({
    required this.hasNext,
    required this.offset,
    required this.limit,
    required this.total,
    required this.items,
  });

  factory PromptListResponseModel.fromJson(Map<String, dynamic> json) {
    // Safely handle items array
    List<PromptModel> promptItems = [];
    if (json['items'] != null && json['items'] is List) {
      promptItems = (json['items'] as List)
          .where((item) => item is Map<String, dynamic>)
          .map((item) => PromptModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return PromptListResponseModel(
      hasNext: json['hasNext'] ?? false,
      offset: json['offset'] ?? 0,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      items: promptItems,
    );
  }
}
