import 'package:aichatbot/data/models/prompt/prompt_model.dart';
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
  final bool isPublic;
  final String? ownerId;

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
    this.isPublic = false,
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

  // Thêm helper method để hiển thị category name thân thiện
  static String getDisplayCategoryName(String category) {
    final displayNames = {
      'business': 'Business',
      'career': 'Career',
      'chatbot': 'Chatbot',
      'coding': 'Coding',
      'education': 'Education',
      'fun': 'Fun',
      'marketing': 'Marketing',
      'productivity': 'Productivity',
      'seo': 'SEO',
      'writing': 'Writing',
      'other': 'Other'
    };

    return displayNames[category] ?? category;
  }

  // Thêm factory constructor để chuyển đổi từ PromptModel sang Prompt
  factory Prompt.fromPromptModel(PromptModel model) {
    return Prompt(
      id: model.id,
      title: model.title,
      description: model.description,
      content: model.content,
      isFavorite: model.isFavorite,
      category:
          model.category ?? 'other', // Sử dụng 'OTHER' nếu không có category
      authorName: model.userName, // Đảm bảo lấy userName từ PromptModel
      useCount: model.useCount,
      createdAt: model.createdAt,
      authorId: model.userId,
      // Các thuộc tính khác nếu cần
    );
  }
}
