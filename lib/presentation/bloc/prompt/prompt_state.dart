import 'package:aichatbot/domain/entities/prompt.dart';

enum PromptStatus { initial, loading, success, failure }

class PromptState {
  final PromptStatus status;
  final List<Prompt> prompts;
  final Prompt? currentPrompt;
  final String? errorMessage;

  const PromptState({
    this.status = PromptStatus.initial,
    this.prompts = const [],
    this.currentPrompt,
    this.errorMessage,
  });

  PromptState copyWith({
    PromptStatus? status,
    List<Prompt>? prompts,
    Prompt? currentPrompt,
    String? errorMessage,
  }) {
    return PromptState(
      status: status ?? this.status,
      prompts: prompts ?? this.prompts,
      currentPrompt: currentPrompt ?? this.currentPrompt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
