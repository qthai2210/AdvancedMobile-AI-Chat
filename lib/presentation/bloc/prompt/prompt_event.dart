import 'package:aichatbot/domain/entities/prompt.dart';

abstract class PromptEvent {}

class CreatePromptRequested extends PromptEvent {
  final String title;
  final String content;
  final String description;
  final List<String> categories;
  final bool isPublic;
  final String language;
  final String accessToken;

  CreatePromptRequested({
    required this.title,
    required this.content,
    required this.description,
    required this.categories,
    required this.accessToken,
    this.isPublic = false,
    this.language = 'vi',
  });
}

class UpdatePromptRequested extends PromptEvent {
  final Prompt prompt;
  final String accessToken;

  UpdatePromptRequested({
    required this.prompt,
    required this.accessToken,
  });
}

class DeletePromptRequested extends PromptEvent {
  final String promptId;
  final String accessToken;

  DeletePromptRequested({
    required this.promptId,
    required this.accessToken,
  });
}

class PromptListRequested extends PromptEvent {
  final String accessToken;

  PromptListRequested({required this.accessToken});
}
