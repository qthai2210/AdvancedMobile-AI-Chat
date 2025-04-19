class MessageResponseModel {
  // Required fields from the actual API response
  final String conversationId;
  final String message;
  final int remainingUsage;

  MessageResponseModel({
    required this.conversationId,
    required this.message,
    required this.remainingUsage,
  });

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageResponseModel(
      conversationId: json['conversationId'] ?? '',
      message: json['message'] ?? '',
      remainingUsage: json['remainingUsage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'message': message,
      'remainingUsage': remainingUsage,
    };
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
