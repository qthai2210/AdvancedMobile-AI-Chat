import 'package:flutter/material.dart';

class AIBot {
  final String id;
  final String name;
  final String description;
  final IconData iconData;
  final Color color;
  final String? prompt;
  final List<KnowledgeItem>? knowledgeBase;
  final DateTime createdAt;
  final Map<String, bool>? integrations;

  AIBot({
    required this.id,
    required this.name,
    required this.description,
    required this.iconData,
    required this.color,
    this.prompt,
    this.knowledgeBase,
    required this.createdAt,
    this.integrations,
  });

  AIBot copyWith({
    String? id,
    String? name,
    String? description,
    IconData? iconData,
    Color? color,
    String? prompt,
    List<KnowledgeItem>? knowledgeBase,
    DateTime? createdAt,
    Map<String, bool>? integrations,
  }) {
    return AIBot(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconData: iconData ?? this.iconData,
      color: color ?? this.color,
      prompt: prompt ?? this.prompt,
      knowledgeBase: knowledgeBase ?? this.knowledgeBase,
      createdAt: createdAt ?? this.createdAt,
      integrations: integrations ?? this.integrations,
    );
  }
}

class KnowledgeItem {
  final String id;
  final String title;
  final String content;
  final DateTime addedAt;
  final String type; // e.g., 'text', 'url', 'pdf'

  KnowledgeItem({
    required this.id,
    required this.title,
    required this.content,
    required this.addedAt,
    required this.type,
  });
}
