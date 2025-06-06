import 'package:flutter/material.dart';

class Prompt {
  final String id;
  final String title;
  final String content;
  final String description;
  final String category;
  final int useCount;
  final bool isFavorite;
  final DateTime createdAt;
  final String? authorName;
  final String? authorId;
  final bool
      isPrivate; // New field to distinguish between public and private prompts
  final String? ownerId; // For private prompts, who owns it

  const Prompt({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    required this.category,
    this.useCount = 0,
    this.isFavorite = false,
    required this.createdAt,
    this.authorName,
    this.authorId,
    this.isPrivate = false, // Default to public
    this.ownerId,
  });

  // Helper method to generate a color based on the category
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'writing':
        return Colors.blue;
      case 'coding':
        return Colors.purple;
      case 'business':
        return Colors.amber;
      case 'marketing':
        return Colors.green;
      case 'education':
        return Colors.orange;
      case 'creative':
        return Colors.pink;
      case 'personal':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Create a copy with updated fields
  Prompt copyWith({
    String? id,
    String? title,
    String? content,
    String? description,
    String? category,
    int? useCount,
    bool? isFavorite,
    DateTime? createdAt,
    String? authorName,
    String? authorId,
    bool? isPrivate,
    String? ownerId,
  }) {
    return Prompt(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      description: description ?? this.description,
      category: category ?? this.category,
      useCount: useCount ?? this.useCount,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      authorName: authorName ?? this.authorName,
      authorId: authorId ?? this.authorId,
      isPrivate: isPrivate ?? this.isPrivate,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  /// Factory constructor to create a Prompt from JSON
  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      description: json['description'] as String,
      category: json['categories'] as String,
      useCount: json['useCount'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      authorName: json['authorName'] as String?,
      authorId: json['authorId'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      ownerId: json['ownerId'] as String?,
    );
  }
}
