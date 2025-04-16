import 'package:json_annotation/json_annotation.dart';

/// Model that represents a single conversation item in the response
class ConversationModel {
  /// Unique identifier for the conversation
  final String id;

  /// Title of the conversation
  final String title;

  /// Creation timestamp of the conversation
  final dynamic createdAt;

  ConversationModel({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  /// Creates a ConversationModel from JSON data
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt: json['createdAt'] ?? 0,
    );
  }

  /// Converts this ConversationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt,
    };
  }
}

/// Model that represents the response from the conversations API
class ConversationListResponseModel {
  /// The cursor to use for the next page of results
  final String cursor;

  /// Whether there are more conversations to fetch
  final bool hasMore;

  /// The maximum number of items in this response
  final int limit;

  /// The list of conversation items
  final List<ConversationModel> items;

  ConversationListResponseModel({
    required this.cursor,
    required this.hasMore,
    required this.limit,
    required this.items,
  });

  /// Creates a ConversationListResponseModel from JSON data
  factory ConversationListResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle the items array by mapping each item to a ConversationModel
    final itemsList = (json['items'] as List?)?.map((item) {
          if (item is Map<String, dynamic>) {
            return ConversationModel.fromJson(item);
          }
          // Return a default model if the item isn't a Map
          return ConversationModel(
            id: '',
            title: '',
            createdAt: 0,
          );
        }).toList() ??
        [];

    return ConversationListResponseModel(
      cursor: json['cursor'].toString(),
      hasMore: json['has_more'] == true, // Explicitly convert to boolean
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      items: itemsList,
    );
  }

  /// Converts this ConversationListResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'cursor': cursor,
      'has_more': hasMore,
      'limit': limit,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
