class CreateAssistantRequest {
  final String assistantName;
  final String? instructions;
  final String? description;

  CreateAssistantRequest({
    required this.assistantName,
    this.instructions,
    this.description,
  });

  factory CreateAssistantRequest.fromJson(Map<String, dynamic> json) {
    return CreateAssistantRequest(
      assistantName: json['assistantName'] as String,
      instructions: json['instructions'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'assistantName': assistantName,
    };

    if (instructions != null) {
      data['instructions'] = instructions;
    }

    if (description != null) {
      data['description'] = description;
    }

    return data;
  }
}
