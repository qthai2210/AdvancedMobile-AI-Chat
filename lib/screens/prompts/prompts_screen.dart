import 'dart:async';

import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/screens/prompts/edit_prompt_screen.dart';
import 'package:aichatbot/screens/prompts/private_prompts_screen.dart';
import 'package:aichatbot/screens/prompts/widgets/empty_state.dart';
import 'package:aichatbot/screens/prompts/widgets/initial_state_view.dart';
import 'package:aichatbot/screens/prompts/widgets/loading_state_view.dart';
import 'package:aichatbot/screens/prompts/widgets/prompt_detail_sheet.dart';
import 'package:aichatbot/screens/prompts/widgets/prompt_grid_item.dart';
import 'package:aichatbot/screens/prompts/widgets/prompt_list_item.dart';
import 'package:aichatbot/screens/prompts/widgets/search_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/screens/prompts/create_prompt_screen.dart';

import 'package:aichatbot/screens/chat_detail_screen.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';

import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart'
    show LoadMorePrompts;
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;
import 'package:aichatbot/core/di/injection_container.dart' as di;

import 'package:aichatbot/widgets/app_notification.dart';
import 'package:aichatbot/utils/error_formatter.dart';
import 'package:aichatbot/utils/build_context_extensions.dart';

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
    'all', // Giữ lại "All" cho UI
    'business',
    'career',
    'chatbot',
    'coding',
    'education',
    'fun',
    'marketing',
    'productivity',
    'seo',
    'writing',
    'other'
  ];

  // Thêm Map để hiển thị friendly names trong UI
  final Map<String, String> _categoryDisplayNames = {
    'all': 'All',
    'business': 'Business',
    'career': 'Career',
    'chatbot': 'Chatbot',
    'coding': 'Coding',
    'education': 'Education',
    'fun': 'Fun',
    'marketing': 'Marketing',
    'productivity': 'Productivity',
    'seo': 'SEO',
    'writing': 'Writing',
    'other': 'Other'
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _loadPrompts();
  }

  void _onSearchChanged() {
    // Đã có SearchQueryChanged event, giữ lại để cập nhật state searchQuery
    final promptBloc = context.read<PromptBloc>();
    promptBloc.add(SearchQueryChanged(_searchController.text));

    // Sử dụng debounce để tránh gọi API quá nhiều lần
    _debounceSearch?.cancel();
    _debounceSearch = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text == promptBloc.state.searchQuery) {
        // Gọi API tìm kiếm
        _searchPrompts(_searchController.text);
      }
    });
  }

  Timer? _debounceSearch;

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounceSearch?.cancel();
    super.dispose();
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
    // Sử dụng lại phương thức _searchPrompts với query hiện tại
    _searchPrompts(_searchController.text);
  }

  /// Toggles favorite status for a prompt
  void _toggleFavorite(PromptModel prompt) async {
    final authState = context.read<AuthBloc>().state;
    final accessToken = authState.user?.accessToken;

    if (accessToken != null) {
      context.read<PromptBloc>().add(
            ToggleFavoriteRequested(
              promptId: prompt.id,
              accessToken: accessToken,
              currentFavoriteStatus:
                  prompt.isFavorite, // Thêm trạng thái hiện tại
              // xJarvisGuid: null, // Có thể thêm nếu cần
            ),
          );

      // Hiển thị thông báo
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
          context.go('/login');
        },
      );
    }
  }

  /// Saves a public prompt as a private prompt
  void _saveAsPrivate(PromptModel prompt) async {
    // Implementation would dispatch an event to save as private
    AppNotification.showSuccess(
      context,
      'Đã lưu "${prompt.title}" vào prompts riêng tư',
    );
  }

  /// Uses the selected prompt in a new chat conversation
  void _usePrompt(PromptModel prompt) {
    try {
      // Show notification first, before navigation
      context.showInfoNotification('Đang chuyển sang trò chuyện mới');

      // Delay navigation slightly to allow notification to show
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              initialPrompt: prompt.content,
              isNewChat: true,
              setCursorToEnd: true,
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('Navigation error: $e');
      context.showErrorNotification(
        'Không thể chuyển trang, vui lòng thử lại sau',
        actionLabel: 'Thử lại',
        onAction: () => _usePrompt(prompt),
      );
    }
  }

  /// Shows a bottom sheet with detailed prompt information
  void _viewPromptDetails(PromptModel prompt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PromptDetailSheet(
        prompt: prompt,
        isOwner: _isPromptOwner(prompt),
        onToggleFavorite: _toggleFavorite,
        onEdit: _editPrompt,
        onSaveAsPrivate: _saveAsPrivate,
        onUse: _usePrompt,
        onDelete: _showDeleteConfirmation,
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

    // Thêm category mới và lưu lại state
    promptBloc.add(CategorySelectionChanged(
      category: category,
      isSelected: !isCurrentlySelected,
    ));

    // Gọi API để lấy danh sách prompts theo category đã chọn
    final authState = context.read<AuthBloc>().state;
    if (authState.user?.accessToken != null) {
      // Xác định category để gửi lên API
      final apiCategory = category == 'all' ? null : category;

      // Gọi API với category mới
      promptBloc.add(FetchPrompts(
        accessToken: authState.user!.accessToken!,
        limit: 20,
        offset: 0,
        category: !isCurrentlySelected
            ? apiCategory
            : null, // Nếu đang select thì gửi null (all)
        isFavorite: promptBloc.state.showOnlyFavorites,
        query: promptBloc.state.searchQuery.isNotEmpty
            ? promptBloc.state.searchQuery
            : null,
      ));
    }
  }

  void _changeSortMethod(String sortBy) {
    context.read<PromptBloc>().add(SortMethodChanged(sortBy));
  }

  void _toggleFavoritesView() {
    final currentState = context.read<PromptBloc>().state;
    final newFavoriteState = !currentState.showOnlyFavorites;

    // Cập nhật UI state
    context.read<PromptBloc>().add(
          ToggleShowFavorites(newFavoriteState),
        );

    // Gọi API để lấy danh sách prompts yêu thích
    final authState = context.read<AuthBloc>().state;
    if (authState.user?.accessToken != null) {
      context.read<PromptBloc>().add(
            FetchPrompts(
              accessToken: authState.user!.accessToken!,
              limit: 20,
              offset: 0,
              category: currentState.selectedCategory == 'all'
                  ? null
                  : currentState.selectedCategory,
              isFavorite: newFavoriteState, // Truyền trạng thái mới
              query: currentState.searchQuery.isNotEmpty
                  ? currentState.searchQuery
                  : null,
            ),
          );
    }
  }

  void _toggleViewMode() {
    final currentState = context.read<PromptBloc>().state;
    context.read<PromptBloc>().add(
          ToggleViewMode(!(currentState.isGridView ?? false)),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PromptBloc>.value(
          value: di.sl<PromptBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<PromptBloc, PromptState>(
            listener: (context, state) {
              debugPrint('BlocListener received state: ${state.status}');

              if (state.status == PromptStatus.failure) {
                context.showApiErrorNotification(
                  ErrorFormatter.formatPromptError(state.errorMessage),
                );
              } else if (state.status == PromptStatus.success &&
                  state.deletedPromptId != null) {
                Navigator.of(context).pop();
                context.showSuccessNotification('Đã xóa prompt thành công');
              }
            },
            child: Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: _buildAppBar(),
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
                  // Sử dụng widget Modern Search Filter Bar mới
                  SearchFilterBar(
                    searchController: _searchController,
                    categories: _categories,
                    categoryDisplayNames: _categoryDisplayNames,
                    onToggleCategory: _toggleCategorySelection,
                  ),
                  Expanded(
                    child: BlocBuilder<PromptBloc, PromptState>(
                      buildWhen: (previous, current) {
                        return previous.status != current.status ||
                            previous.prompts != current.prompts ||
                            previous.isGridView != current.isGridView ||
                            previous.showOnlyFavorites !=
                                current.showOnlyFavorites ||
                            previous.searchQuery != current.searchQuery ||
                            previous.selectedCategories !=
                                current.selectedCategories ||
                            previous.sortBy != current.sortBy;
                      },
                      builder: (context, state) {
                        if (state.status == PromptStatus.initial) {
                          return const InitialStateView();
                        } else if (state.status == PromptStatus.loading &&
                            (state.prompts?.isEmpty ?? true)) {
                          return const LoadingStateView();
                        } else if (state.prompts?.isEmpty ?? true) {
                          return EmptyStateView(
                            isFavoritesView: state.showOnlyFavorites,
                          );
                        } else {
                          final prompts = [...?state.prompts];

                          // Áp dụng sắp xếp theo tham số sortBy
                          if (state.sortBy == 'alphabetical') {
                            prompts.sort((a, b) => a.title.compareTo(b.title));
                          } else if (state.sortBy == 'recent') {
                            prompts.sort(
                                (a, b) => b.createdAt.compareTo(a.createdAt));
                          } else if (state.sortBy == 'popular') {
                            prompts.sort(
                                (a, b) => b.useCount.compareTo(a.useCount));
                          } else {
                            // Mặc định sắp xếp theo thời gian tạo (mới nhất trước)
                            prompts.sort(
                                (a, b) => b.createdAt.compareTo(a.createdAt));
                          }

                          return (state.isGridView ?? false)
                              ? _buildPromptGrid(prompts)
                              : _buildPromptList(prompts);
                        }
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => _navigateToCreatePrompt(),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: const Text('Tạo Prompt',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Theme.of(context).primaryColor),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Prompt Collections',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        // Nút yêu thích với hiệu ứng
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
        // Nút truy cập prompts riêng tư
        IconButton(
          icon: const Icon(Icons.person_outline),
          tooltip: 'My Private Prompts',
          onPressed: _navigateToPrivatePrompts,
        ),
        // Menu sắp xếp và đổi chế độ xem
        _buildSortAndViewMenu(),
      ],
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  // Widget cho menu sắp xếp và thay đổi chế độ xem
  Widget _buildSortAndViewMenu() {
    return BlocBuilder<PromptBloc, PromptState>(
      builder: (context, state) {
        return PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: _toggleViewMode,
              child: Row(
                children: [
                  Icon(
                      (state.isGridView ?? false)
                          ? Icons.list
                          : Icons.grid_view,
                      size: 20),
                  const SizedBox(width: 8),
                  Text((state.isGridView ?? false) ? 'List view' : 'Grid view'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'divider',
              enabled: false,
              height: 10,
              child: Divider(),
            ),
            const PopupMenuItem(
              value: 'popular',
              child: Row(
                children: [
                  Icon(Icons.trending_up, size: 20),
                  SizedBox(width: 8),
                  Text('Sort by Popularity'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'recent',
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 20),
                  SizedBox(width: 8),
                  Text('Sort by Recent'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'alphabetical',
              child: Row(
                children: [
                  Icon(Icons.sort_by_alpha, size: 20),
                  SizedBox(width: 8),
                  Text('Sort Alphabetically'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value != 'divider') {
              _changeSortMethod(value.toString());
            }
          },
        );
      },
    );
  }

  Widget _buildPromptList(List<PromptModel> prompts) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), // Space for FAB
      itemCount: prompts.length,
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        final isOwner = _isPromptOwner(prompt);

        // Sử dụng ModernPromptListItem thay thế
        return PromptListItem(
          prompt: prompt,
          isOwner: isOwner,
          onViewDetails: _viewPromptDetails,
          onToggleFavorite: _toggleFavorite,
          onEdit: _editPrompt,
          onDelete: _showDeleteConfirmation,
          onUse: _usePrompt,
          formatDate: _formatDate,
        );
      },
    );
  }

  Widget _buildPromptGrid(List<PromptModel> prompts) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: prompts.length,
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        final isOwner = _isPromptOwner(prompt);

        // Sử dụng Modern Grid Item thay thế
        return PromptGridItem(
          prompt: prompt,
          isOwner: isOwner,
          onViewDetails: _viewPromptDetails,
          onToggleFavorite: _toggleFavorite,
          onEdit: _editPrompt,
          onDelete: _showDeleteConfirmation,
          onUse: _usePrompt,
          formatDate: _formatDate,
        );
      },
    );
  }

  // Helper method để định dạng ngày
  String _formatDate(DateTime date) {
    // Format to a user-friendly date
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Thêm phương thức xử lý sự kiện chỉnh sửa prompt
  void _editPrompt(PromptModel prompt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPromptScreen(prompt: prompt),
      ),
    ).then((result) {
      // Thêm log xác nhận quay lại từ màn hình edit
      debugPrint(
          'Prompts screen: Returned from edit screen with result: $result');

      // Reset state của PromptBloc để tránh giữ trạng thái loading
      if (result == true) {
        context.read<PromptBloc>().add(ResetPromptState());
      }

      // Reload danh sách prompts
      _loadPrompts();
    });
  }

  // Thêm phương thức xác nhận trước khi xóa prompt
  void _showDeleteConfirmation(BuildContext context, PromptModel prompt) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Xác nhận xóa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn có chắc chắn muốn xóa prompt "${prompt.title}"?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Hành động này không thể hoàn tác.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tất cả dữ liệu liên quan đến prompt này cũng sẽ bị xóa.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
            ],
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
              child: const Text(
                'Hủy',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.white),
              label: const Text(
                'Xóa',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                // Dispatch event xóa
                context.read<PromptBloc>().add(DeletePrompt(
                      accessToken:
                          context.read<AuthBloc>().state.user!.accessToken!,
                      promptId: prompt.id,
                    ));

                // Đóng dialog ngay lập tức
                Navigator.pop(dialogContext);

                // Hiển thị loading indicator trong khi chờ xóa
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (loadingContext) {
                    return BlocListener<PromptBloc, PromptState>(
                      listener: (context, state) {
                        if (state.status == PromptStatus.success &&
                            state.deletedPromptId == prompt.id) {
                          // Đóng loading dialog
                          Navigator.pop(loadingContext);
                          // Hiển thị thông báo thành công
                          context.showSuccessNotification(
                              'Đã xóa prompt thành công');
                        } else if (state.status == PromptStatus.failure) {
                          // Đóng loading dialog
                          Navigator.pop(loadingContext);
                          // Hiển thị lỗi
                          context.showApiErrorNotification(
                            ErrorFormatter.formatPromptError(
                                state.errorMessage),
                          );
                        }
                      },
                      child: AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            const CircularProgressIndicator(),
                            const SizedBox(height: 24),
                            Text(
                              'Đang xóa...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Thêm phương thức để kiểm tra quyền sở hữu prompt
  bool _isPromptOwner(PromptModel prompt) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id;

    // Thêm logs để debug
    debugPrint('Checking ownership: prompt.userId = ${prompt.userId}');
    debugPrint('Checking ownership: currentUserId = $currentUserId');
    debugPrint('Is owner? ${prompt.userId == currentUserId}');

    if (prompt.userId != null && currentUserId != null) {
      return prompt.userId == currentUserId;
    }
    return false;
  }

  // Phương thức tìm kiếm prompts
  void _searchPrompts(String query) {
    debugPrint('Searching prompts with query: "$query"');

    // Kiểm tra xem widget còn mounted không để tránh lỗi
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState.user?.accessToken == null) {
      if (mounted) {
        context.showWarningNotification(
          'Bạn cần đăng nhập để tìm kiếm prompts',
          actionLabel: 'Đăng nhập',
          onAction: () => Navigator.of(context).pushReplacementNamed('/login'),
        );
      }
      return;
    }

    try {
      // Kiểm tra xem PromptBloc còn tồn tại không
      final promptBloc = context.read<PromptBloc>();
      final selectedCategory = promptBloc.state.selectedCategory;
      final apiCategory =
          (selectedCategory != 'All' && selectedCategory != null)
              ? selectedCategory
              : null;

      // Gọi API getPrompts với tham số query
      if (mounted) {
        promptBloc.add(
          FetchPrompts(
            accessToken: authState.user!.accessToken!,
            limit: 20,
            offset: 0,
            category: apiCategory,
            isFavorite: promptBloc.state.isFavoriteFilter,
            query: query.isEmpty ? null : query, // Chỉ gửi query khi có giá trị
          ),
        );
      }
    } catch (e) {
      // Xử lý trường hợp PromptBloc đã bị đóng hoặc không tồn tại
      debugPrint('Error dispatching FetchPrompts event: $e');
      // Không hiển thị thông báo lỗi nếu widget không còn mounted
      if (mounted) {
        context.showErrorNotification('Đã xảy ra lỗi khi tìm kiếm');
      }
    }
  }

  // Phương thức điều hướng tạo prompt mới
  void _navigateToCreatePrompt() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePromptScreen()),
    ).then((result) {
      if (result == true) {
        _loadPrompts();
        context.showSuccessNotification('Tạo prompt thành công');
      }
    });
  }
}
