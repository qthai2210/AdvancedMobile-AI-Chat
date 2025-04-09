import 'package:aichatbot/domain/entities/prompt.dart';

abstract class PromptEvent {}

class FetchPrompts extends PromptEvent {
  final String accessToken;
  final String? query;
  final int? offset;
  final int? limit;
  final String? category;
  final bool? isFavorite;
  final bool? isPublic;

  FetchPrompts({
    required this.accessToken,
    this.query,
    this.offset,
    this.limit,
    this.category,
    this.isFavorite,
    this.isPublic,
  });
}

class LoadMorePrompts extends PromptEvent {
  final String accessToken;
  final String? query;
  final int offset;
  final int limit;
  final String? category;
  final bool? isFavorite;
  final bool? isPublic;

  LoadMorePrompts({
    required this.accessToken,
    required this.offset,
    required this.limit,
    this.query,
    this.category,
    this.isFavorite,
    this.isPublic,
  });
}

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

class ToggleFavoriteRequested extends PromptEvent {
  final String promptId;
  final String accessToken;

  ToggleFavoriteRequested({
    required this.promptId,
    required this.accessToken,
  });
}

class SearchQueryChanged extends PromptEvent {
  final String query;

  SearchQueryChanged(this.query);
}

class CategorySelected extends PromptEvent {
  final String? category;

  CategorySelected(this.category);
}

class CategorySelectionChanged extends PromptEvent {
  final String category;
  final bool isSelected;

  CategorySelectionChanged({
    required this.category,
    required this.isSelected,
  });
}

class ToggleShowFavorites extends PromptEvent {
  final bool showOnlyFavorites;

  ToggleShowFavorites(this.showOnlyFavorites);
}

class SortMethodChanged extends PromptEvent {
  final String sortBy;

  SortMethodChanged(this.sortBy);
}

class ToggleViewMode extends PromptEvent {
  final bool isGridView;

  ToggleViewMode(this.isGridView);
}

class CreatePrompt extends PromptEvent {
  final String accessToken;
  final String title;
  final String content;
  final String description;
  final String category;
  final bool isPublic;
  final String language;
  final String? xJarvisGuid;

  CreatePrompt({
    required this.accessToken,
    required this.title,
    required this.content,
    required this.description,
    required this.category,
    required this.isPublic,
    this.language = 'English',
    this.xJarvisGuid,
  });
}
