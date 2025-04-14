import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_event.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_state.dart';
import 'package:aichatbot/domain/usecases/chat/send_message_usecase.dart';
import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/utils/token_management_service.dart';
import 'dart:convert';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessageUseCase;

  ChatBloc({required this.sendMessageUseCase}) : super(const ChatState()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ResetChatEvent>(_onResetChat);
  }

  void _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final response = await sendMessageUseCase(
        request: event.request,
      );

      emit(state.copyWith(
        status: ChatStatus.success,
        response: response,
      ));
    } on Failure catch (failure) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: failure.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onResetChat(ResetChatEvent event, Emitter<ChatState> emit) {
    emit(const ChatState());
  }
}
