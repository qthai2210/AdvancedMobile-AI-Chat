import 'package:equatable/equatable.dart';
import 'package:aichatbot/data/models/chat/message_request_model.dart';

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

class ResetChatEvent extends ChatEvent {}
