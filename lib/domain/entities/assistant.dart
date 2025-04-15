class Assistant {
  final String id;
  final String assistantName;
  final String openAiAssistantId;
  final String? instructions;
  final String? description;
  final String? openAiThreadIdPlay;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  const Assistant({
    required this.id,
    required this.assistantName,
    required this.openAiAssistantId,
    this.instructions,
    this.description,
    this.openAiThreadIdPlay,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });
}
