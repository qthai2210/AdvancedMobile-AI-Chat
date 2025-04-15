import 'package:aichatbot/domain/entities/assistant.dart';

class AssistantModel extends Assistant {
  const AssistantModel({
    required super.id,
    required super.assistantName,
    required super.openAiAssistantId,
    super.instructions,
    super.description,
    super.openAiThreadIdPlay,
    super.createdAt,
    super.updatedAt,
    super.createdBy,
    super.updatedBy,
  });

  factory AssistantModel.fromJson(Map<String, dynamic> json) {
    return AssistantModel(
      id: json['id'] as String,
      assistantName: json['assistantName'] as String,
      openAiAssistantId: json['openAiAssistantId'] as String,
      instructions: json['instructions'] as String?,
      description: json['description'] as String?,
      openAiThreadIdPlay: json['openAiThreadIdPlay'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assistantName': assistantName,
      'openAiAssistantId': openAiAssistantId,
      if (instructions != null) 'instructions': instructions,
      if (description != null) 'description': description,
      if (openAiThreadIdPlay != null) 'openAiThreadIdPlay': openAiThreadIdPlay,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (createdBy != null) 'createdBy': createdBy,
      if (updatedBy != null) 'updatedBy': updatedBy,
    };
  }

  factory AssistantModel.fromEntity(Assistant assistant) {
    return AssistantModel(
      id: assistant.id,
      assistantName: assistant.assistantName,
      openAiAssistantId: assistant.openAiAssistantId,
      instructions: assistant.instructions,
      description: assistant.description,
      openAiThreadIdPlay: assistant.openAiThreadIdPlay,
      createdAt: assistant.createdAt,
      updatedAt: assistant.updatedAt,
      createdBy: assistant.createdBy,
      updatedBy: assistant.updatedBy,
    );
  }
}
