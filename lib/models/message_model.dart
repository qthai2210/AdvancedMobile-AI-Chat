import 'package:flutter/material.dart';
import 'package:aichatbot/models/ai_agent_model.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final AIAgent? agent;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.agent,
  });
}
