abstract class PromptEvent {
  const PromptEvent();
}

class FetchPrompts extends PromptEvent {
  final String accessToken;
  final int? limit;
  final int? offset;
  final String? category;
  final bool? isFavorite;
  final String? query;
  final bool? isPublic; // Thêm trường isPublic

  const FetchPrompts({
    required this.accessToken,
    this.limit,
    this.offset,
    this.category,
    this.isFavorite,
    this.query,
    this.isPublic, // Mặc định null để lấy cả public và private
  });

  @override
  List<Object?> get props =>
      [accessToken, limit, offset, category, isFavorite, query, isPublic];
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
  final String category;
  final bool isPublic;
  final String language;
  final String accessToken;

  CreatePromptRequested({
    required this.title,
    required this.content,
    required this.description,
    required this.category,
    required this.accessToken,
    this.isPublic = false,
    this.language = 'vi',
  });
}

class UpdatePrompt extends PromptEvent {
  final String accessToken;
  final String promptId;
  final String title;
  final String description;
  final String content;
  final String category;
  final bool isPublic;

  UpdatePrompt({
    required this.accessToken,
    required this.promptId,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.isPublic,
  });
}

class DeletePrompt extends PromptEvent {
  final String accessToken;
  final String promptId;
  final String? xJarvisGuid;

  const DeletePrompt({
    required this.accessToken,
    required this.promptId,
    this.xJarvisGuid,
  });
}

class ToggleFavoriteRequested extends PromptEvent {
  final String promptId;
  final String accessToken;
  final bool currentFavoriteStatus;
  final String? xJarvisGuid;

  ToggleFavoriteRequested({
    required this.promptId,
    required this.accessToken,
    required this.currentFavoriteStatus,
    this.xJarvisGuid,
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

  const CategorySelectionChanged({
    required this.category,
    required this.isSelected,
  });
}

class ToggleShowFavorites extends PromptEvent {
  final bool showOnlyFavorites;

  const ToggleShowFavorites(this.showOnlyFavorites);
}

class ToggleViewMode extends PromptEvent {
  final bool isGridView;

  const ToggleViewMode(this.isGridView);
}

class SortMethodChanged extends PromptEvent {
  final String sortBy;

  const SortMethodChanged(this.sortBy);
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

class ResetPromptState extends PromptEvent {}
