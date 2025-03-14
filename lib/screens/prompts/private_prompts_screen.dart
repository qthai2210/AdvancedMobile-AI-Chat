import 'package:aichatbot/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:aichatbot/models/prompt_model.dart';
import 'package:aichatbot/widgets/prompts/prompt_card.dart';
import 'package:aichatbot/services/prompt_service.dart';
import 'package:aichatbot/screens/prompts/create_prompt_screen.dart';
import 'package:go_router/go_router.dart';

/// PrivatePromptsScreen displays and manages user's personal collection of prompts.
///
/// Features:
/// * CRUD operations for private prompts
/// * Search and filter functionality
/// * Grid/List view toggle
/// * Sorting options
/// * Favorites management
///
/// This screen provides full management capabilities for user-created prompts.
class PrivatePromptsScreen extends StatefulWidget {
  const PrivatePromptsScreen({Key? key}) : super(key: key);

  @override
  State<PrivatePromptsScreen> createState() => _PrivatePromptsScreenState();
}

/// State management for the PrivatePromptsScreen widget.
///
/// Handles:
/// * Private prompts data management
/// * User interactions and filtering
/// * CRUD operations
class _PrivatePromptsScreenState extends State<PrivatePromptsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _selectedCategories = [];
  bool _isGridView = false; // Changed to false to default to list view
  bool _showOnlyFavorites = false;
  String _sortBy = 'recent'; // Default sort for private prompts is most recent
  List<Prompt> _prompts = [];
  bool _isLoading = false;

  // Available categories
  final List<String> _categories = [
    'All',
    'Writing',
    'Coding',
    'Business',
    'Marketing',
    'Education',
    'Creative',
    'Personal',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategories = ['All'];
    _loadPrompts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loads private prompts from the PromptService and applies initial sorting.
  /// Sets loading state during the operation.
  Future<void> _loadPrompts() async {
    setState(() => _isLoading = true);

    try {
      _prompts = await PromptService.getPrivatePrompts();
      _sortPrompts();
    } catch (e) {
      debugPrint('Error loading private prompts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Applies current sorting criteria to the prompts list.
  /// Options: popular, recent, alphabetical
  void _sortPrompts() {
    switch (_sortBy) {
      case 'popular':
        _prompts.sort((a, b) => b.useCount.compareTo(a.useCount));
        break;
      case 'recent':
        _prompts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'alphabetical':
        _prompts.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
  }

  List<Prompt> _filteredPrompts() {
    return _prompts.where((prompt) {
      // Apply favorites filter
      if (_showOnlyFavorites && !prompt.isFavorite) {
        return false;
      }

      // Apply search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          prompt.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prompt.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply category filter
      final matchesCategory =
          _selectedCategories.contains('All') ||
          prompt.categories.any(
            (category) => _selectedCategories.contains(category),
          );

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (category == 'All') {
        _selectedCategories = ['All'];
      } else {
        // Remove 'All' if it's selected
        _selectedCategories.removeWhere((c) => c == 'All');

        if (_selectedCategories.contains(category)) {
          _selectedCategories.remove(category);
        } else {
          _selectedCategories.add(category);
        }

        // If no categories are selected, select 'All'
        if (_selectedCategories.isEmpty) {
          _selectedCategories = ['All'];
        }
      }
    });
  }

  void _toggleFavorite(Prompt prompt) async {
    final isFavorite = await PromptService.toggleFavorite(prompt.id);

    setState(() {
      final index = _prompts.indexWhere((p) => p.id == prompt.id);
      if (index != -1) {
        _prompts[index] = prompt.copyWith(isFavorite: isFavorite);
      }
    });

    if (mounted) {
      final message =
          isFavorite
              ? 'Đã thêm vào danh sách yêu thích'
              : 'Đã xóa khỏi danh sách yêu thích';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _usePrompt(Prompt prompt) {
    // Update usage count
    setState(() {
      final index = _prompts.indexWhere((p) => p.id == prompt.id);
      if (index != -1) {
        _prompts[index] = prompt.copyWith(useCount: prompt.useCount + 1);
      }
    });

    // Update usage count in service
    PromptService.incrementPromptUseCount(prompt.id);

    // Navigate to chat with this prompt content - use safer navigation
    try {
      // Try to use GoRouter navigation
      context.go('/chat/detail/new', extra: {'initialPrompt': prompt.content});
    } catch (e) {
      // Fallback to regular navigation if GoRouter fails
      try {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder:
                (_) => ChatDetailScreen(
                  initialPrompt: prompt.content,
                  isNewChat: true,
                ),
          ),
          (route) => false,
        );
      } catch (e2) {
        // Last resort fallback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation error: $e2. Please try again.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _editPrompt(Prompt prompt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePromptScreen(editPrompt: prompt),
      ),
    ).then((result) {
      if (result != null && result is Prompt) {
        setState(() {
          final index = _prompts.indexWhere((p) => p.id == prompt.id);
          if (index != -1) {
            _prompts[index] = result;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật prompt thành công')),
        );
      }
    });
  }

  /// Shows a confirmation dialog and handles prompt deletion.
  /// Updates UI and shows feedback on success/failure.
  void _deletePrompt(Prompt prompt) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa Prompt'),
            content: Text(
              'Bạn có chắc chắn muốn xóa prompt "${prompt.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (shouldDelete != true) return;

    // Perform deletion
    setState(() => _isLoading = true);

    try {
      final success = await PromptService.deletePrivatePrompt(prompt.id);
      if (success && mounted) {
        setState(() {
          _prompts.removeWhere((p) => p.id == prompt.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa prompt "${prompt.title}"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _viewPromptDetails(Prompt prompt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildPromptDetailSheet(prompt),
    );
  }

  /// Creates a bottom sheet dialog showing detailed prompt information
  /// and management options.
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

              // Author info - for private prompts, it's always the current user
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'By: ${prompt.authorName ?? "Me"}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),

              // Description
              Text(prompt.description),

              const SizedBox(height: 16),
              // Categories
              Wrap(
                spacing: 8,
                children:
                    prompt.categories.map((category) {
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

              // Action buttons - for private prompts include edit and delete
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.favorite,
                    label:
                        prompt.isFavorite
                            ? 'Remove from Favorites'
                            : 'Add to Favorites',
                    onPressed: () {
                      _toggleFavorite(prompt);
                      Navigator.pop(context);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'Edit',
                    onPressed: () {
                      Navigator.pop(context);
                      _editPrompt(prompt);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.delete,
                    label: 'Delete',
                    onPressed: () {
                      Navigator.pop(context);
                      _deletePrompt(prompt);
                    },
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text('Use in Chat'),
                  onPressed: () {
                    _usePrompt(prompt);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
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
    Color? color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        foregroundColor: color,
        backgroundColor: color?.withOpacity(0.1),
      ),
    );
  }

  void _changeSortMethod(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _sortPrompts();
    });
  }

  void _toggleFavoritesView() {
    setState(() {
      _showOnlyFavorites = !_showOnlyFavorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPrompts = _filteredPrompts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompts Cá Nhân'),
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
            ),
            color: _showOnlyFavorites ? Colors.red : null,
            onPressed: _toggleFavoritesView,
            tooltip:
                _showOnlyFavorites
                    ? 'Hiển thị tất cả'
                    : 'Chỉ hiển thị yêu thích',
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'Dạng danh sách' : 'Dạng lưới',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _changeSortMethod,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'popular',
                    child: Text('Sắp xếp theo Phổ biến'),
                  ),
                  const PopupMenuItem(
                    value: 'recent',
                    child: Text('Sắp xếp theo Gần đây nhất'),
                  ),
                  const PopupMenuItem(
                    value: 'alphabetical',
                    child: Text('Sắp xếp theo Bảng chữ cái'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredPrompts.isEmpty
                    ? _buildEmptyState()
                    : _isGridView
                    ? _buildPromptGrid(filteredPrompts)
                    : _buildPromptList(filteredPrompts),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewPrompt,
        tooltip: 'Tạo Prompt Mới',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Creates a new private prompt via the CreatePromptScreen.
  /// Updates the list and shows feedback on successful creation.
  void _createNewPrompt() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePromptScreen()),
    ).then((result) {
      if (result != null && result is Prompt) {
        setState(() {
          _prompts.add(result);
          _sortPrompts(); // Re-sort after adding
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tạo prompt "${result.title}"')),
        );
      }
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm prompt cá nhân...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh mục',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
                  _categories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) => _toggleCategory(category),
                        backgroundColor: Colors.grey[200],
                        selectedColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showOnlyFavorites
                ? Icons.favorite_outline
                : (_searchQuery.isNotEmpty ? Icons.search_off : Icons.note_add),
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _showOnlyFavorites
                ? 'Chưa có prompt cá nhân nào được yêu thích'
                : (_searchQuery.isNotEmpty
                    ? 'Không tìm thấy prompt cá nhân nào'
                    : 'Bạn chưa có prompt cá nhân nào'),
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_searchQuery.isNotEmpty ||
              (_selectedCategories.isNotEmpty &&
                  !_selectedCategories.contains('All')))
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategories = ['All'];
                });
              },
              child: const Text('Xóa bộ lọc'),
            )
          else if (!_showOnlyFavorites)
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tạo Prompt Cá Nhân Đầu Tiên'),
              onPressed: _createNewPrompt,
            ),
        ],
      ),
    );
  }

  Widget _buildPromptGrid(List<Prompt> prompts) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: prompts.length,
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        return PromptCard(
          prompt: prompt,
          onTap: () => _viewPromptDetails(prompt),
          onFavorite: () => _toggleFavorite(prompt),
          onUse: () => _usePrompt(prompt),
        );
      },
    );
  }

  Widget _buildPromptList(List<Prompt> prompts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prompts.length,
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        return PromptCard(
          prompt: prompt,
          onTap: () => _viewPromptDetails(prompt),
          onFavorite: () => _toggleFavorite(prompt),
          onUse: () => _usePrompt(prompt),
        );
      },
    );
  }
}
