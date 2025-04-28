import 'package:aichatbot/models/knowledge_base_model.dart';
import 'package:aichatbot/screens/knowledge_management/knowledge_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_event.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_state.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;
import 'package:aichatbot/widgets/knowledge/empty_knowledge_view.dart';
import 'package:aichatbot/widgets/knowledge/knowledge_base_card.dart';
import 'package:aichatbot/widgets/knowledge/add_knowledge_form.dart';
import 'package:go_router/go_router.dart';

class KnowledgeManagementScreen extends StatefulWidget {
  const KnowledgeManagementScreen({super.key});

  @override
  State<KnowledgeManagementScreen> createState() =>
      _KnowledgeManagementScreenState();
}

class _KnowledgeManagementScreenState extends State<KnowledgeManagementScreen>
    with SingleTickerProviderStateMixin {
  /// Controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  /// Current search query
  String _searchQuery = '';

  /// State for showing/hiding the add form
  bool _showAddForm = false;

  /// State for loading indicator when adding knowledge
  bool _isLoading = false;

  // Form controllers for adding new knowledge base
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Animation controller for the add form
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  /// Flag to track if we just deleted a knowledge base
  bool _justDeletedKnowledge = false;

  @override
  void initState() {
    super.initState();

    // Set up animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Initialize data
    _fetchKnowledgeBases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Fetch knowledge bases from the server
  void _fetchKnowledgeBases() {
    context.read<KnowledgeBloc>().add(
          FetchKnowledgesEvent(
            searchQuery: _searchQuery,
            offset: 0,
            limit: 20,
          ),
        );
  }

  /// Refresh knowledge bases from the server
  void _refreshKnowledgeBases() {
    context.read<KnowledgeBloc>().add(
          RefreshKnowledgesEvent(
            searchQuery: _searchQuery,
            limit: 20,
          ),
        );
  }

  /// Load more knowledge bases (pagination)
  void _loadMoreKnowledgeBases(int currentOffset) {
    context.read<KnowledgeBloc>().add(
          FetchMoreKnowledgesEvent(
            searchQuery: _searchQuery,
            offset: currentOffset,
            limit: 20,
          ),
        );
  }

  /// Shows or hides the add knowledge base form
  void _toggleAddForm() {
    setState(() {
      _showAddForm = !_showAddForm;

      if (_showAddForm) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        // Clear form fields
        _nameController.clear();
        _descriptionController.clear();
      }
    });
  }

  Future<void> _addKnowledgeBase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    try {
      // Create new knowledge base via bloc
      context.read<KnowledgeBloc>().add(
            CreateKnowledgeEvent(
              knowledgeName: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
            ),
          );

      // Hide the form - success message will be shown by the bloc listener
      _toggleAddForm();
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Shows a confirmation dialog before deleting a knowledge base
  void _showDeleteConfirmation(KnowledgeModel knowledge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bộ dữ liệu tri thức'),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${knowledge.knowledgeName}"? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog
              context.pop();
              // Delete the knowledge base
              _deleteKnowledgeBase(knowledge.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  /// Deletes a knowledge base with the given ID
  void _deleteKnowledgeBase(String id) {
    // Set the flag to indicate we've just deleted a knowledge base
    setState(() {
      _justDeletedKnowledge = true;
    });

    context.read<KnowledgeBloc>().add(
          DeleteKnowledgeEvent(id: id),
        );

    // Show a temporary snackbar indicating deletion is in progress
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang xóa bộ dữ liệu tri thức...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: MainAppDrawer(
        currentIndex: 5,
        onTabSelected: (index) => navigation_utils.handleDrawerNavigation(
          context,
          index,
          currentIndex: 5,
        ),
      ),
      body: BlocListener<KnowledgeBloc, KnowledgeState>(
        listener: (context, state) {
          if (state is KnowledgeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.message}')),
            );
          }
          if (state is KnowledgeLoaded) {
            setState(() {
              _isLoading = false;
            });
            // Show success message if we just added a knowledge base
            if (_showAddForm) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Đã thêm bộ dữ liệu tri thức mới')),
              );
              _toggleAddForm(); // Hide form after adding
            }

            // Show success message if we just deleted a knowledge base
            if (_justDeletedKnowledge) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Bộ dữ liệu tri thức đã được xóa thành công')),
              );
              setState(() {
                _justDeletedKnowledge = false;
              });
            }
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: BlocBuilder<KnowledgeBloc, KnowledgeState>(
                    builder: (context, state) {
                      if (state is KnowledgeLoading) {
                        return _buildLoadingState();
                      } else if (state is KnowledgeLoaded) {
                        if (state.knowledges.isEmpty) {
                          return _buildEmptyState();
                        } else {
                          return _buildKnowledgeBaseList(state.knowledges);
                        }
                      } else {
                        return const Center(child: Text('Đã xảy ra lỗi'));
                      }
                    },
                  ),
                ),
              ],
            ),
            // Slide-up form for adding new knowledge base
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _animation,
                child: AddKnowledgeForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                  onSave: _addKnowledgeBase,
                  onCancel: _toggleAddForm,
                  isLoading: _isLoading,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !_showAddForm ? _buildFloatingActionButton() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text(
        'Bộ dữ liệu tri thức',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Làm mới',
          onPressed: _refreshKnowledgeBases,
        ),
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          tooltip: 'Lọc',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Tính năng lọc sẽ có trong thời gian tới')),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _toggleAddForm,
      label: const Text('Thêm mới'),
      icon: const Icon(Icons.add),
      elevation: 3,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          'Đang tải dữ liệu...',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ));
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bộ dữ liệu...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _refreshKnowledgeBases();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
          if (value.isEmpty) {
            _refreshKnowledgeBases();
          }
        },
        onSubmitted: (_) {
          _refreshKnowledgeBases();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyKnowledgeView(
      message: _searchQuery.isEmpty
          ? 'Chưa có bộ dữ liệu tri thức nào'
          : 'Không tìm thấy bộ dữ liệu phù hợp với "$_searchQuery"',
      searchQuery: _searchQuery,
      onAddPressed: _toggleAddForm,
    );
  }

  Widget _buildKnowledgeBaseList(List<KnowledgeModel> knowledges) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: knowledges.length,
      itemBuilder: (context, index) {
        final knowledge = knowledges[index];
        return KnowledgeBaseCard(
          knowledge: knowledge,
          onTap: () => _navigateToKnowledgeDetail(knowledge),
          onDelete: () => _showDeleteConfirmation(knowledge),
        );
      },
    );
  }

  void _navigateToKnowledgeDetail(KnowledgeModel knowledge) {
    // Create a KnowledgeBase from KnowledgeModel
    final KnowledgeBase knowledgeBase = KnowledgeBase(
      id: knowledge.id ?? '',
      name: knowledge.knowledgeName,
      createdAt: knowledge.createdAt ?? DateTime.now(),
      lastUpdatedAt: knowledge.updatedAt ?? DateTime.now(),
      description: knowledge.description ?? '',
    );

    // Navigate to detail screen
    context.push('/knowledge/${knowledgeBase.id}/add_source',
        extra: knowledgeBase);
  }
}
