import 'package:equatable/equatable.dart';
import 'package:aichatbot/data/models/chat/message_response_model.dart';

enum ChatStatus { initial, loading, success, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final MessageResponseModel? response;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.response,
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    MessageResponseModel? response,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == ChatStatus.loading;
  bool get isSuccess => status == ChatStatus.success;
  bool get isError => status == ChatStatus.error;

  @override
  List<Object?> get props => [status, response, errorMessage];
}
