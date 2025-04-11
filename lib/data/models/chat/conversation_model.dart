import 'package:json_annotation/json_annotation.dart';

part 'conversation_model.g.dart';

/// Model that represents a single conversation item in the response
@JsonSerializable()
class ConversationModel {
  /// Unique identifier for the conversation
  final String id;

  /// Title of the conversation
  final String title;

  /// Creation timestamp of the conversation
  @JsonKey(name: 'createdAt')
  final int createdAt;

  ConversationModel({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  /// Creates a ConversationModel from JSON data
  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  /// Converts this ConversationModel to JSON
  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);
}

/// Model that represents the response from the conversations API
@JsonSerializable()
class ConversationListResponseModel {
  /// The cursor to use for the next page of results
  final String? cursor;

  /// Whether there are more conversations to fetch
  @JsonKey(name: 'has_more')
  final bool hasMore;

  /// The maximum number of items in this response
  final int limit;

  /// The list of conversation items
  final List<ConversationModel> items;

  ConversationListResponseModel({
    this.cursor,
    required this.hasMore,
    required this.limit,
    required this.items,
  });

  /// Creates a ConversationListResponseModel from JSON data
  factory ConversationListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationListResponseModelFromJson(json);

  /// Converts this ConversationListResponseModel to JSON
  Map<String, dynamic> toJson() => _$ConversationListResponseModelToJson(this);
}
