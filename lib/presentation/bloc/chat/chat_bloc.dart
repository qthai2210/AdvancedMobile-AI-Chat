import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_event.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_state.dart';
import 'package:aichatbot/domain/usecases/chat/send_message_usecase.dart';
import 'package:aichatbot/domain/usecases/chat/send_custom_bot_message_usecase.dart';
import 'package:aichatbot/data/models/chat/message_response_model.dart';
import 'package:aichatbot/core/errors/failures.dart';
import 'package:aichatbot/utils/token_management_service.dart';
import 'package:aichatbot/utils/logger.dart';
import 'dart:convert';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final SendCustomBotMessageUseCase? sendCustomBotMessageUseCase;
  ChatBloc({
    required this.sendMessageUseCase,
    this.sendCustomBotMessageUseCase,
  }) : super(const ChatState()) {
    on<SendMessageEvent>(_onSendMessage);
    on<SendCustomBotMessageEvent>(_onSendCustomBotMessage);
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

  void _onSendCustomBotMessage(
      SendCustomBotMessageEvent event, Emitter<ChatState> emit) async {
    if (sendCustomBotMessageUseCase == null) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Custom bot message use case not initialized',
      ));
      return;
    }

    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final customBotResponse = await sendCustomBotMessageUseCase!(
        request: event.request,
      );

      // Convert CustomBotMessageResponse to MessageResponseModel
      final responseModel = MessageResponseModel(
        message: customBotResponse.message,
        // Use the conversation ID from the request
        conversationId: event.request.metadata.conversation.id,
        remainingUsage: customBotResponse.remainingUsage,
      );

      // Emit success state with converted response
      emit(state.copyWith(
        status: ChatStatus.success,
        response: responseModel,
      ));

      // Log remaining usage for monitoring (optional)
      AppLogger.i(
          'Remaining custom bot usage: ${customBotResponse.remainingUsage}');
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
