/// Model representing a chunk of a message from the AI Assistant API
class AssistantMessageChunk {
  /// The content of this message chunk
  final String content;

  /// The conversation ID this message belongs to
  final String conversationId;

  AssistantMessageChunk({required this.content, required this.conversationId});

  /// Creates an instance from JSON map
  factory AssistantMessageChunk.fromJson(Map<String, dynamic> json) {
    return AssistantMessageChunk(
      content: json['content'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
    );
  }
}
