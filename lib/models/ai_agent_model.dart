import 'package:flutter/material.dart';

class AIAgent {
  final String id;
  final String name;
  final String description;
  final Color color;

  AIAgent({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });
}

class AIAgents {
  static List<AIAgent> agents = [
    AIAgent(
      id: 'gpt-4',
      name: 'GPT-4',
      description: 'Model tiên tiến nhất với hiệu suất cao',
      color: Colors.blue,
    ),
    AIAgent(
      id: 'gpt-3.5-turbo',
      name: 'GPT-3.5 Turbo',
      description: 'Cân bằng giữa hiệu suất và tốc độ',
      color: Colors.green,
    ),
    AIAgent(
      id: 'claude',
      name: 'Claude',
      description: 'AI trợ lý từ Anthropic',
      color: Colors.purple,
    ),
    AIAgent(
      id: 'llama2',
      name: 'Llama 2',
      description: 'Model mã nguồn mở từ Meta',
      color: Colors.orange,
    ),
  ];
}
