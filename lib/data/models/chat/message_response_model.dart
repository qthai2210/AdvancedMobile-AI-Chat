class MessageResponseModel {
  final String id;
  final String content;
  final String role;
  final String createdAt;
  final AssistantInfo? assistant;

  MessageResponseModel({
    required this.id,
    required this.content,
    required this.role,
    required this.createdAt,
    this.assistant,
  });

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageResponseModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['createdAt'] ?? '',
      assistant: json['assistant'] != null
          ? AssistantInfo.fromJson(json['assistant'])
          : null,
    );
  }
}

class AssistantInfo {
  final String model;
  final String name;
  final String id;

  AssistantInfo({
    required this.model,
    required this.name,
    required this.id,
  });

  factory AssistantInfo.fromJson(Map<String, dynamic> json) {
    return AssistantInfo(
      model: json['model'] ?? '',
      name: json['name'] ?? '',
      id: json['id'] ?? '',
    );
  }
}
