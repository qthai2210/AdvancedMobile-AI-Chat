import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/screens/prompts/create_prompt_screen.dart';
import 'package:aichatbot/screens/prompts/private_prompts_screen.dart';
import 'package:aichatbot/screens/chat_detail_screen.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_state.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart'
    show LoadMorePrompts;
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;
import 'package:aichatbot/core/di/injection_container.dart' as di;
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/widgets/app_notification.dart';
import 'package:aichatbot/utils/error_formatter.dart';
import 'package:aichatbot/utils/build_context_extensions.dart';

class PrivatePromptsScreen extends StatelessWidget {
  const PrivatePromptsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Private Prompts'),
      ),
      body: const Center(
        child: Text('Private prompts will be implemented soon'),
      ),
    );
  }
}

class PromptsScreen extends StatefulWidget {
  const PromptsScreen({Key? key}) : super(key: key);

  @override
  State<PromptsScreen> createState() => _PromptsScreenState();
}

class _PromptsScreenState extends State<PromptsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Available categories
  final List<String> _categories = [
    'All',
    'Business',
    'Career',
    'Chatbot',
    'Coding',
    'Education',
    'Fun',
    'Marketing',
    'Productivity',
    'SEO',
    'Writing',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _loadPrompts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final promptBloc = context.read<PromptBloc>();
    promptBloc.add(SearchQueryChanged(_searchController.text));

    // Debounce search
    if (_searchController.text.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_searchController.text == promptBloc.state.searchQuery) {
          _loadPrompts();
        }
      });
    } else {
      _loadPrompts();
    }
  }

  void _onScroll() {
    final promptState = context.read<PromptBloc>().state;

    if (promptState.promptListResponse == null) {
      return;
    }

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        promptState.promptListResponse!.hasNext &&
        promptState.status != PromptStatus.loading &&
        promptState.status != PromptStatus.loadingMore) {
      final authState = context.read<AuthBloc>().state;
      if (authState.user?.accessToken == null) {
        // Xử lý khi chưa đăng nhập
        return;
      }

      final accessToken = authState.user!.accessToken!;
      final currentOffset = promptState.promptListResponse!.offset;
      final pageSize = promptState.promptListResponse!.limit;

      // Thêm try-catch để bắt lỗi
      try {
        context.read<PromptBloc>().add(
              LoadMorePrompts(
                accessToken: accessToken,
                offset: currentOffset + pageSize,
                limit: pageSize,
                query: promptState.currentQuery,
                category: promptState.selectedCategory != 'All' &&
                        promptState.selectedCategory != null
                    ? promptState.selectedCategory
                    : null,
              ),
            );
      } catch (e) {
        debugPrint('Error loading more prompts: $e');
      }
    }
  }

  /// Loads prompts from the API
  void _loadPrompts() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user?.accessToken != null) {
      debugPrint(
          "Loading prompts with token: ${authState.user!.accessToken!.substring(0, 10)}...");

      context.read<PromptBloc>().add(
            FetchPrompts(
              accessToken: authState.user!.accessToken!,
              limit: 20,
              offset: 0,
              isFavorite: context.read<PromptBloc>().state.isFavoriteFilter,
              query: _searchController.text.isEmpty
                  ? null
                  : _searchController.text,
            ),
          );
    } else {
      debugPrint("Cannot load prompts: user not authenticated");
      AppNotification.showWarning(
        context,
        'Bạn cần đăng nhập để xem prompts',
        actionLabel: 'Đăng nhập',
        onAction: () {
          // Chuyển đến trang đăng nhập
          Navigator.of(context).pushReplacementNamed('/login');
        },
      );
    }
  }

  /// Toggles favorite status for a prompt
  void _toggleFavorite(Prompt prompt) async {
    final authState = context.read<AuthBloc>().state;
    final accessToken = authState.user?.accessToken;

    if (accessToken != null) {
      context.read<PromptBloc>().add(
            ToggleFavoriteRequested(
              promptId: prompt.id,
              accessToken: accessToken,
            ),
          );

      final message = prompt.isFavorite
          ? 'Đã xóa khỏi danh sách yêu thích'
          : 'Đã thêm vào danh sách yêu thích';

      AppNotification.showSuccess(context, message);
    } else {
      AppNotification.showWarning(
        context,
        'Bạn cần đăng nhập để sử dụng tính năng này',
        actionLabel: 'Đăng nhập',
        onAction: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
      );
    }
  }

  /// Saves a public prompt as a private prompt
  void _saveAsPrivate(Prompt prompt) async {
    // Implementation would dispatch an event to save as private
    AppNotification.showSuccess(
      context,
      'Đã lưu "${prompt.title}" vào prompts riêng tư',
    );
  }

  /// Uses the selected prompt in a new chat conversation
  void _usePrompt(Prompt prompt) {
    try {
      context.go('/chat/detail/new', extra: {'initialPrompt': prompt.content});
      context.showInfoNotification('Đã chuyển sang trò chuyện mới');
    } catch (e) {
      // Fallback to regular navigation
      try {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              initialPrompt: prompt.content,
              isNewChat: true,
            ),
          ),
          (route) => false,
        );
      } catch (e2) {
        context.showErrorNotification(
          'Không thể chuyển trang, vui lòng thử lại sau',
          actionLabel: 'Thử lại',
          onAction: () => _usePrompt(prompt),
        );
      }
    }
  }

  /// Shows a bottom sheet with detailed prompt information
  void _viewPromptDetails(Prompt prompt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildPromptDetailSheet(prompt),
    );
  }

  Widget _buildPromptDetailSheet(Prompt prompt) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    prompt.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (prompt.authorName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'By: ${prompt.authorName}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              Text(prompt.description),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: prompt.categories.map((category) {
                  final color = Prompt.getCategoryColor(category);
                  return Chip(
                    label: Text(category),
                    backgroundColor: color.withOpacity(0.2),
                    labelStyle: TextStyle(color: color),
                  );
                }).toList(),
              ),
              const Divider(height: 32),
              const Text(
                'Prompt Content:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(prompt.content),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.favorite,
                    label: prompt.isFavorite
                        ? 'Remove from Favorites'
                        : 'Add to Favorites',
                    onPressed: () {
                      _toggleFavorite(prompt);
                      Navigator.pop(context);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.save_alt,
                    label: 'Save as Private',
                    onPressed: () {
                      _saveAsPrivate(prompt);
                      Navigator.pop(context);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.chat,
                    label: 'Use in Chat',
                    onPressed: () {
                      _usePrompt(prompt);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  void _navigateToPrivatePrompts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivatePromptsScreen()),
    );
  }

  void _toggleCategorySelection(String category) {
    final promptBloc = context.read<PromptBloc>();
    final isCurrentlySelected =
        promptBloc.state.selectedCategories.contains(category);
    promptBloc.add(CategorySelectionChanged(
      category: category,
      isSelected: !isCurrentlySelected,
    ));
  }

  void _changeSortMethod(String sortBy) {
    context.read<PromptBloc>().add(SortMethodChanged(sortBy));
  }

  void _toggleFavoritesView() {
    final currentState = context.read<PromptBloc>().state;
    context.read<PromptBloc>().add(
          ToggleShowFavorites(!currentState.showOnlyFavorites),
        );
  }

  void _toggleViewMode() {
    final currentState = context.read<PromptBloc>().state;
    context.read<PromptBloc>().add(
          ToggleViewMode(!currentState.isGridView),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PromptBloc>(
      create: (context) => di.sl<PromptBloc>(),
      child: Builder(
        builder: (context) {
          return BlocListener<PromptBloc, PromptState>(
            listener: (context, state) {
              // Xử lý các trạng thái và hiển thị thông báo
              if (state.status == PromptStatus.failure) {
                AppNotification.showError(
                  context,
                  ErrorFormatter.formatApiError(state.errorMessage),
                );
              }

              // Hiển thị thông báo khi tạo prompt thành công
              if (state.newPrompt != null) {
                AppNotification.showSuccess(
                  context,
                  'Đã tạo prompt mới thành công',
                );
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Prompts'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    tooltip: 'My Private Prompts',
                    onPressed: _navigateToPrivatePrompts,
                  ),
                  BlocBuilder<PromptBloc, PromptState>(
                    builder: (context, state) {
                      return IconButton(
                        icon: Icon(
                          state.showOnlyFavorites
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        color: state.showOnlyFavorites ? Colors.red : null,
                        onPressed: _toggleFavoritesView,
                        tooltip: state.showOnlyFavorites
                            ? 'Show all prompts'
                            : 'Show favorites',
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    onSelected: _changeSortMethod,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'popular',
                        child: Text('Sort by Popularity'),
                      ),
                      const PopupMenuItem(
                        value: 'recent',
                        child: Text('Sort by Recent'),
                      ),
                      const PopupMenuItem(
                        value: 'alphabetical',
                        child: Text('Sort Alphabetically'),
                      ),
                    ],
                  ),
                  BlocBuilder<PromptBloc, PromptState>(
                    builder: (context, state) {
                      return IconButton(
                        icon: Icon(
                            state.isGridView ? Icons.list : Icons.grid_view),
                        onPressed: _toggleViewMode,
                        tooltip: state.isGridView ? 'List view' : 'Grid view',
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      // Navigate to create prompt screen
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreatePromptScreen(),
                        ),
                      );
                      // Nếu quay lại với result = true (đã tạo prompt mới), load lại danh sách
                      if (result == true) {
                        _loadPrompts();
                      }
                    },
                  ),
                ],
              ),
              drawer: MainAppDrawer(
                currentIndex: 3,
                onTabSelected: (index) =>
                    navigation_utils.handleDrawerNavigation(
                  context,
                  index,
                  currentIndex: 3,
                ),
              ),
              body: Column(
                children: [
                  _buildSearchBar(),
                  _buildCategoryFilter(),
                  Expanded(
                    child: BlocBuilder<PromptBloc, PromptState>(
                      builder: (context, state) {
                        if (state.status == PromptStatus.initial) {
                          return const Center(
                              child: Text('Hãy tìm kiếm prompt'));
                        } else if (state.status == PromptStatus.loading &&
                            state.prompts.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          final sortedPrompts = state.sortedPrompts();
                          return _buildPromptContentView(
                              sortedPrompts, state.isGridView);
                        }
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreatePromptScreen()),
                  ).then((result) {
                    if (result != null) {
                      // Refresh the list if a prompt was created
                      _loadPrompts();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Prompt created successfully')),
                      );
                    }
                  });
                },
                tooltip: 'Tạo Prompt Mới',
                child: const Icon(Icons.add),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromptContentView(List<Prompt> prompts, bool isGridView) {
    if (prompts.isEmpty) {
      return _buildEmptyState(
          context.read<PromptBloc>().state.showOnlyFavorites);
    }
    return isGridView ? _buildPromptGrid(prompts) : _buildPromptList(prompts);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm prompt...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PromptBloc>().add(SearchQueryChanged(''));
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: SizedBox(
        height: 40,
        child: BlocBuilder<PromptBloc, PromptState>(
          builder: (context, state) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = state.selectedCategories.contains(category);
                final color = Prompt.getCategoryColor(category);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => _toggleCategorySelection(category),
                    child: Chip(
                      label: Text(category),
                      backgroundColor: isSelected
                          ? color.withOpacity(0.2)
                          : Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? color : Colors.black54,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isFavoritesView) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFavoritesView ? Icons.favorite_border : Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isFavoritesView
                ? 'Bạn chưa có prompt yêu thích nào'
                : 'Không tìm thấy prompt nào',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isFavoritesView
                ? 'Hãy thêm prompt yêu thích để xem ở đây'
                : 'Thử tìm kiếm với từ khóa khác',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptGrid(List<Prompt> prompts) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: prompts.length,
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _viewPromptDetails(prompt),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          prompt.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          prompt.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: prompt.isFavorite ? Colors.red : null,
                          size: 20,
                        ),
                        onPressed: () => _toggleFavorite(prompt),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (prompt.categories.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: prompt.categories.map((category) {
                        final color = Prompt.getCategoryColor(category);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      prompt.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'By: ${prompt.authorName ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat, size: 18),
                        onPressed: () => _usePrompt(prompt),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromptList(List<Prompt> prompts) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemCount: prompts.length,
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _viewPromptDetails(prompt),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prompt.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'By: ${prompt.authorName ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          prompt.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: prompt.isFavorite ? Colors.red : null,
                        ),
                        onPressed: () => _toggleFavorite(prompt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prompt.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...prompt.categories.map((category) {
                          final color = Prompt.getCategoryColor(category);
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Uses: ${prompt.useCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text('Use'),
                        onPressed: () => _usePrompt(prompt),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
