import 'package:aichatbot/domain/entities/prompt.dart';

class PromptModel extends Prompt {
  const PromptModel({
    required String id,
    required String title,
    required String content,
    required String description,
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
          description: description,
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
    return PromptModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      description: json['description'],
      categories: List<String>.from(
          json['categories'] ?? [json['category'] ?? 'General']),
      useCount: json['useCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      authorName: json['authorName'],
      authorId: json['authorId'],
      isPrivate: json['isPrivate'] ?? !json['isPublic'] ?? false,
      ownerId: json['ownerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'description': description,
      'category': categories.isNotEmpty ? categories[0] : 'General',
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
}
