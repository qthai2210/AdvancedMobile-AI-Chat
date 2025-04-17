class ConversationHistoryItem {
  final String? answer;
  final dynamic createdAt; // Changed to dynamic to handle both String and int
  final List<String>? files;
  final String? query;

  ConversationHistoryItem({
    this.answer,
    this.createdAt,
    this.files,
    this.query,
  });

  factory ConversationHistoryItem.fromJson(Map<String, dynamic> json) {
    // Parse createdAt from either a string date or directly use timestamp
    dynamic timestamp = json['createdAt'];
    if (timestamp is String) {
      try {
        // Try to parse the date string to an epoch timestamp (milliseconds)
        timestamp = DateTime.parse(timestamp).millisecondsSinceEpoch;
      } catch (e) {
        // If parsing fails, leave it as is
        print('Error parsing date: $e');
      }
    }

    return ConversationHistoryItem(
      answer: json['answer'],
      createdAt: timestamp,
      files: json['files'] != null ? List<String>.from(json['files']) : null,
      query: json['query'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'createdAt': createdAt,
      'files': files,
      'query': query,
    };
  }
}

class ConversationHistoryResponse {
  final String cursor;
  final bool hasMore;
  final int limit;
  final List<ConversationHistoryItem> items;

  ConversationHistoryResponse({
    required this.cursor,
    required this.hasMore,
    required this.limit,
    required this.items,
  });

  factory ConversationHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ConversationHistoryResponse(
      cursor: json['cursor'] ?? '',
      hasMore: json['has_more'] ?? false,
      limit: json['limit'] ?? 100,
      items: json['items'] != null
          ? List<ConversationHistoryItem>.from(json['items']
              .map((item) => ConversationHistoryItem.fromJson(item)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cursor': cursor,
      'has_more': hasMore,
      'limit': limit,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
