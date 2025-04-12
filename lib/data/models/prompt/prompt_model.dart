import 'package:aichatbot/domain/entities/prompt.dart';

class PromptModel {
  final String id;
  final String title;
  final String description;
  final String content;
  final bool isFavorite;
  final String? category;
  final bool isPublic;
  final bool? isOwner;

  // Các thuộc tính khác...

  final String? userId;
  final String? userName;
  final String? language;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int useCount;

  PromptModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.isPublic = false,
    this.isOwner,
    this.userId,
    this.userName,
    this.language,
    this.useCount = 0,
  });

  factory PromptModel.fromJson(Map<String, dynamic> json) {
    // Xử lý categories từ API
    String? categoryValue;
    if (json['categories'] != null &&
        json['categories'] is List &&
        (json['categories'] as List).isNotEmpty) {
      // Take the first category from the list if available
      categoryValue = (json['categories'] as List).first.toString();
    } else {
      // Otherwise use the category field directly
      categoryValue = json['category']?.toString();
    }

    return PromptModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      category: json['category'],
      isPublic: json['isPublic'] ?? false,
      isOwner: json['isOwner'],
      userId: json['userId'],
      userName: json['userName'],
      language: json['language'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      useCount: json['useCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'content': content,
      'isFavorite': isFavorite,
      'category': category,
      'isPublic': isPublic,
      'isOwner': isOwner,
      'userId': userId,
      'userName': userName,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'useCount': useCount,
    };
  }

  // Cập nhật phương thức copyWith
  PromptModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    bool? isFavorite,
    String? category,
    bool? isPublic,
    bool? isOwner,
    String? userId,
    String? userName,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? useCount,
  }) {
    return PromptModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
      isOwner: isOwner ?? this.isOwner,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      useCount: useCount ?? this.useCount,
    );
  }
}
