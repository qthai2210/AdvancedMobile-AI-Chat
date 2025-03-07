import 'package:flutter/material.dart';
import 'package:aichatbot/models/prompt_model.dart';
import 'package:aichatbot/widgets/prompts/prompt_card.dart';
import 'package:aichatbot/services/prompt_service.dart';
import 'package:aichatbot/screens/prompts/create_prompt_screen.dart';
import 'package:aichatbot/screens/prompts/private_prompts_screen.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;
import 'package:go_router/go_router.dart';

class PromptsScreen extends StatefulWidget {
  const PromptsScreen({Key? key}) : super(key: key);

  @override
  State<PromptsScreen> createState() => _PromptsScreenState();
}

class _PromptsScreenState extends State<PromptsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _selectedCategories = [];
  bool _isGridView = false; // Changed to false to default to list view
  bool _showOnlyFavorites = false;
  String _sortBy = 'popular'; // Options: popular, recent, alphabetical
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

  Future<void> _loadPrompts() async {
    setState(() => _isLoading = true);

    try {
      _prompts = await PromptService.getPrompts();
      _sortPrompts();
    } catch (e) {
      debugPrint('Error loading prompts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
      final matchesSearch = _searchQuery.isEmpty ||
          prompt.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          prompt.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply category filter
      final matchesCategory = _selectedCategories.contains('All') ||
          prompt.categories
              .any((category) => _selectedCategories.contains(category));

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Get only favorited prompts
  List<Prompt> get _favoritedPrompts =>
      _prompts.where((p) => p.isFavorite).toList();

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
      final message = isFavorite
          ? 'Đã thêm vào danh sách yêu thích'
          : 'Đã xóa khỏi danh sách yêu thích';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _saveAsPrivate(Prompt prompt) async {
    try {
      await PromptService.saveAsPrivate(prompt);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Đã lưu "${prompt.title}" vào prompt riêng tư')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  void _usePrompt(Prompt prompt) {
    setState(() {
      final index = _prompts.indexWhere((p) => p.id == prompt.id);
      if (index != -1) {
        _prompts[index] = prompt.copyWith(useCount: prompt.useCount + 1);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added "${prompt.title}" to chat')),
    );
  }

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
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Author info
              if (prompt.authorName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'By: ${prompt.authorName}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

              // Description
              Text(prompt.description),

              const SizedBox(height: 16),
              // Categories
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

              // Action buttons
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
                      Navigator.pop(context);
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
    // Navigate to the private prompts screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivatePromptsScreen(),
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
        title: const Text('Prompts'),
        actions: [
          // Button to navigate to private prompts
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'My Private Prompts',
            onPressed: _navigateToPrivatePrompts,
          ),
          IconButton(
            icon: Icon(
                _showOnlyFavorites ? Icons.favorite : Icons.favorite_border),
            color: _showOnlyFavorites ? Colors.red : null,
            onPressed: _toggleFavoritesView,
            tooltip: _showOnlyFavorites ? 'Show all prompts' : 'Show favorites',
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
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
        ],
      ),
      drawer: MainAppDrawer(
        currentIndex: 3, // Index 3 corresponds to the Prompts tab in the drawer
        onTabSelected: (index) => navigation_utils
            .handleDrawerNavigation(context, index, currentIndex: 3),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPromptContentView(filteredPrompts),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePromptScreen(),
            ),
          ).then((result) {
            if (result != null && result is Prompt) {
              // If a prompt was created, show a success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Đã tạo prompt riêng tư: ${result.title}')),
              );

              // Optionally refresh the list if needed
              _loadPrompts();
            }
          });
        },
        tooltip: 'Tạo Prompt Mới',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPromptContentView(List<Prompt> prompts) {
    if (prompts.isEmpty) {
      return _buildEmptyState(_showOnlyFavorites);
    }

    return _isGridView ? _buildPromptGrid(prompts) : _buildPromptList(prompts);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm prompt...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Categories',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _toggleCategory(category),
                    backgroundColor: Colors.grey[200],
                    selectedColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
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

  Widget _buildEmptyState(bool isFavoritesView) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFavoritesView ? Icons.favorite_outline : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isFavoritesView
                ? 'Chưa có prompt yêu thích nào'
                : 'Không tìm thấy prompt nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          if (isFavoritesView)
            Text(
              'Hãy thêm prompt vào danh sách yêu thích',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
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

  // Generate mock data for testing
  List<Prompt> _getMockPrompts() {
    return [
      Prompt(
        id: '1',
        title: 'Email Marketing Campaign',
        content:
            'Write a compelling email marketing campaign for [product] targeting [audience].',
        description:
            'Create effective email marketing campaigns that increase engagement and conversions.',
        categories: ['Marketing', 'Writing', 'Business'],
        useCount: 1250,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        authorName: 'Marketing Pro',
      ),
      Prompt(
        id: '2',
        title: 'Code Refactoring Helper',
        content:
            'Refactor this code to improve [specific aspect]: ```[code]```',
        description:
            'Get suggestions for improving your code quality, readability, and performance.',
        categories: ['Coding', 'Education'],
        useCount: 843,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        authorName: 'Dev Helper',
      ),
      Prompt(
        id: '3',
        title: 'Social Media Post Ideas',
        content:
            'Generate 5 engaging social media post ideas for a [type] business in the [industry] industry.',
        description:
            'Creative ideas for your social media content calendar across different platforms.',
        categories: ['Marketing', 'Creative', 'Business'],
        useCount: 2105,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        authorName: 'Social Media Expert',
      ),
      Prompt(
        id: '4',
        title: 'Essay Outline Generator',
        content:
            'Create a detailed outline for an essay about [topic] with the thesis statement: [thesis].',
        description:
            'Get help organizing your thoughts and creating a well-structured essay outline.',
        categories: ['Education', 'Writing'],
        useCount: 1672,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        authorName: 'Writing Assistant',
      ),
      Prompt(
        id: '5',
        title: 'Story Idea Generator',
        content:
            'Create a unique story idea with the following elements: [genre], [setting], [character trait].',
        description:
            'Spark your creativity with customizable story premises across different genres.',
        categories: ['Creative', 'Writing'],
        useCount: 934,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        authorName: 'Creative Writer',
      ),
      Prompt(
        id: '6',
        title: 'SQL Query Builder',
        content:
            'Write a SQL query to [task] with the following tables: [table definitions].',
        description:
            'Get help writing efficient SQL queries for your database operations.',
        categories: ['Coding', 'Business'],
        useCount: 761,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        authorName: 'Database Expert',
      ),
      Prompt(
        id: '7',
        title: 'Product Description',
        content:
            'Write a compelling product description for [product] highlighting its [features] and benefits for [target audience].',
        description:
            'Create persuasive product descriptions that highlight features and benefits.',
        categories: ['Marketing', 'Writing', 'Business'],
        useCount: 1587,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        authorName: 'Copywriting Pro',
      ),
      Prompt(
        id: '8',
        title: 'Interview Questions',
        content:
            'Create a list of interview questions for a [position] role that assess [skills].',
        description:
            'Prepare effective interview questions tailored to specific roles and skills.',
        categories: ['Business', 'Personal'],
        useCount: 892,
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
        authorName: 'HR Professional',
      ),
    ];
  }
}
