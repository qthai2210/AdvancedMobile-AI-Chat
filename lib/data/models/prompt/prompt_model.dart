import 'package:aichatbot/domain/entities/prompt.dart';

class PromptModel extends Prompt {
  const PromptModel({
    required String id,
    required String title,
    required String content,
    String? description,
    required List<String> categories,
    int useCount = 0,
    bool isFavorite = false,
    required DateTime createdAt,
    String? authorName,
    String? authorId,
    bool isPrivate = false,
    String? ownerId,
  }) : super(
          id: id,
          title: title,
          content: content,
          description: description ?? '',
          categories: categories,
          useCount: useCount,
          isFavorite: isFavorite,
          createdAt: createdAt,
          authorName: authorName,
          authorId: authorId,
          isPrivate: isPrivate,
          ownerId: ownerId,
        );

  factory PromptModel.fromJson(Map<String, dynamic> json) {
    String id = json['_id'] ?? json['id'] ?? '';

    // Safely handle categories
    List<String> categories = [];
    if (json['categories'] != null) {
      categories = List<String>.from(json['categories']);
    } else if (json['category'] != null && json['category'] is String) {
      categories = [json['category']];
    }

    return PromptModel(
      id: id,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      description: json['description'],
      categories: categories,
      useCount: json['useCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      authorName: json['userName'] ?? json['authorName'],
      authorId: json['userId'] ?? json['authorId'],
      isPrivate: json['isPrivate'] ?? !(json['isPublic'] ?? true),
      ownerId: json['ownerId'] ?? json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'description': description,
      'category': categories.isNotEmpty ? categories[0] : 'other',
      'categories': categories,
      'useCount': useCount,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'authorName': authorName,
      'authorId': authorId,
      'isPrivate': isPrivate,
      'ownerId': ownerId,
    };
  }

  // Helper method to return a copy with modified fields
  PromptModel copyWith({
    String? id,
    String? title,
    String? content,
    String? description,
    List<String>? categories,
    int? useCount,
    bool? isFavorite,
    DateTime? createdAt,
    String? authorName,
    String? authorId,
    bool? isPrivate,
    String? ownerId,
  }) {
    return PromptModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      useCount: useCount ?? this.useCount,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      authorName: authorName ?? this.authorName,
      authorId: authorId ?? this.authorId,
      isPrivate: isPrivate ?? this.isPrivate,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
