import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_event.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_state.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;

/// A screen for managing multiple knowledge bases.
///
/// Features:
/// * View list of knowledge bases
/// * Search knowledge bases
/// * Add new knowledge bases
/// * View knowledge base details
/// * Track knowledge base stats
class KnowledgeManagementScreen extends StatefulWidget {
  const KnowledgeManagementScreen({super.key});

  @override
  State<KnowledgeManagementScreen> createState() =>
      _KnowledgeManagementScreenState();
}

/// State management for [KnowledgeManagementScreen].
/// Handles knowledge base operations and UI updates.
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
            //offset: 0,
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
        title: const Text('Delete Knowledge Base'),
        content: Text(
          'Are you sure you want to delete "${knowledge.knowledgeName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();
              // Delete the knowledge base
              _deleteKnowledgeBase(knowledge.id!);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
      const SnackBar(content: Text('Deleting knowledge base...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: MainAppDrawer(
        currentIndex: 5, // Index 2 corresponds to the Knowledge Base tab
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
          } // When a knowledge base is created or refreshed, update the UI
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
            ), // Slide-up form for adding new knowledge base
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _animation,
                child: _buildAddForm(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
          tooltip: 'Refresh',
          onPressed: _refreshKnowledgeBases,
        ),
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          tooltip: 'Filter',
          onPressed: () {
            // TODO: Implement filtering options
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filtering will be available soon')),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _toggleAddForm,
      child: Icon(_showAddForm ? Icons.close : Icons.add),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.menu_book : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Chưa có bộ dữ liệu tri thức nào'
                : 'Không tìm thấy bộ dữ liệu phù hợp với "$_searchQuery"',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: _toggleAddForm,
              icon: const Icon(Icons.add),
              label: const Text('Thêm bộ dữ liệu tri thức'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeBaseList(List<KnowledgeModel> knowledges) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: knowledges.length,
      itemBuilder: (context, index) {
        final knowledge = knowledges[index];
        return _buildKnowledgeBaseCard(knowledge);
      },
    );
  }

  Widget _buildKnowledgeBaseCard(KnowledgeModel knowledge) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToKnowledgeDetail(knowledge),
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKnowledgeBaseHeader(knowledge),
                  const SizedBox(height: 12),
                  _buildKnowledgeBaseDescription(knowledge),
                  const SizedBox(height: 16),
                  knowledge.updatedAt != null
                      ? _buildKnowledgeLastUpdated(knowledge)
                      : const SizedBox(),
                ],
              ),
            ),
            // Status indicator ribbon
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeBaseHeader(KnowledgeModel knowledge) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon indicating knowledge type
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: Theme.of(context).primaryColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        // Title
        Expanded(
          child: Text(
            knowledge.knowledgeName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Delete button
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(knowledge),
          tooltip: 'Delete knowledge base',
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildKnowledgeBaseDescription(KnowledgeModel knowledge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        knowledge.description ?? 'Chưa có mô tả',
        style: TextStyle(
          color: Colors.grey[800],
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAddForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thêm bộ dữ liệu tri thức',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleAddForm,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên bộ dữ liệu *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên cho bộ dữ liệu';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mô tả cho bộ dữ liệu';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _toggleAddForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addKnowledgeBase,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Thêm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToKnowledgeDetail(KnowledgeModel knowledge) {
    // Navigate to detail screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => KnowledgeDetailScreen(knowledge: knowledge),
    //   ),
    // );
  }
  Widget _buildKnowledgeLastUpdated(KnowledgeModel knowledge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          Icons.update,
          size: 14,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Text(
          'Cập nhật: ${_formatDate(knowledge.updatedAt ?? DateTime.now())}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
