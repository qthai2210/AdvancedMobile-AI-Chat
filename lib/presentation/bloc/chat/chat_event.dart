import 'package:equatable/equatable.dart';
import 'package:aichatbot/data/models/chat/message_request_model.dart';
import 'package:aichatbot/data/models/chat/custom_bot_message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final MessageRequestModel request;

  const SendMessageEvent({
    required this.request,
  });

  @override
  List<Object?> get props => [request];
}

/// Event to send a message to a custom bot
class SendCustomBotMessageEvent extends ChatEvent {
  final CustomBotMessageRequest request;

  const SendCustomBotMessageEvent({
    required this.request,
  });

  @override
  List<Object?> get props => [request];
}

class ResetChatEvent extends ChatEvent {}
