import 'package:flutter/material.dart';

class Prompt {
  final String id;
  final String title;
  final String content;
  final String description;
  final List<String> categories;
  final int useCount;
  final bool isFavorite;
  final DateTime createdAt;
  final String? authorName;
  final String? authorId;
  final bool isPrivate;
  final String? ownerId;

  const Prompt({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    required this.categories,
    this.useCount = 0,
    this.isFavorite = false,
    required this.createdAt,
    this.authorName,
    this.authorId,
    this.isPrivate = false,
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
      case 'career':
        return Colors.deepOrange;
      case 'chatbot':
        return Colors.indigo;
      case 'fun':
        return Colors.pinkAccent;
      case 'productivity':
        return Colors.lightBlue;
      case 'seo':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
