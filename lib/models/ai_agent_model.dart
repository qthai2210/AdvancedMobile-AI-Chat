import 'package:flutter/material.dart';
import 'package:aichatbot/data/models/chat/conversation_request_params.dart';

class AIAgent {
  final dynamic id; // Can be either AssistantId or String for custom assistants
  final String name;
  final String description;
  final Color color;
  final bool isCustom;

  AIAgent({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    this.isCustom = false,
  });

  String get idString => id.toString();
}

class AIAgents {
  static List<AIAgent> agents = [
    AIAgent(
      id: AssistantId.GPT_4_O,
      name: 'GPT-4o',
      description: 'Most advanced OpenAI model with highest performance',
      color: Colors.blue,
    ),
    AIAgent(
      id: AssistantId.GPT_4_O_MINI,
      name: 'GPT-4o Mini',
      description: 'Faster, more efficient version of GPT-4o',
      color: Colors.green,
    ),
    AIAgent(
      id: AssistantId.CLAUDE_35_SONNET_20240620,
      name: 'Claude 3.5 Sonnet',
      description: 'Latest Claude model with excellent reasoning',
      color: Colors.purple,
    ),
    AIAgent(
      id: AssistantId.CLAUDE_3_HAIKU_20240307,
      name: 'Claude 3 Haiku',
      description: 'Fast and efficient Claude model',
      color: Colors.orange,
    ),
    AIAgent(
      id: AssistantId.GEMINI_15_PRO_LATEST,
      name: 'Gemini 1.5 Pro',
      description: 'Google\'s advanced multimodal model',
      color: Colors.red,
    ),
    AIAgent(
      id: AssistantId.GEMINI_15_FLASH_LATEST,
      name: 'Gemini 1.5 Flash',
      description: 'Fast and efficient Gemini model',
      color: Colors.teal,
    ),
  ];
}
