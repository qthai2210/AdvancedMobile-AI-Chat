class ChatThread {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final String agentType;

  ChatThread({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.agentType,
  });
}
