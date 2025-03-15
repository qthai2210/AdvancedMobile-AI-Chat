import 'package:aichatbot/screens/knowledge_management/knowledge_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';
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

  /// Loading state for async operations
  bool _isLoading = false;

  /// State for showing/hiding the add form
  bool _showAddForm = false;

  // Form controllers for adding new knowledge base
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Animation controller for the add form
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Mock data for knowledge bases
  List<KnowledgeBase> _knowledgeBases = [];

  @override
  void initState() {
    super.initState();
    _loadKnowledgeBases();

    // Setup animation for the add form
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Loads or refreshes the list of knowledge bases
  Future<void> _loadKnowledgeBases() async {
    setState(() => _isLoading = true);

    try {
      // In a real app, load from API or database
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate network delay

      // Create some sample data
      _knowledgeBases = [
        KnowledgeBaseFactory.createWithSampleData(
          name: 'Tài liệu sản phẩm',
          description:
              'Bộ dữ liệu chứa hướng dẫn sử dụng và thông tin sản phẩm',
        ),
        KnowledgeBaseFactory.createWithSampleData(
          name: 'Câu hỏi thường gặp',
          description: 'Các câu hỏi thường gặp từ khách hàng',
        ),
        KnowledgeBaseFactory.createWithSampleData(
          name: 'Tài liệu kỹ thuật',
          description: 'Thông số kỹ thuật và tài liệu API',
        ),
      ];
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Returns filtered knowledge bases based on search query
  List<KnowledgeBase> get _filteredKnowledgeBases {
    if (_searchQuery.isEmpty) return _knowledgeBases;
    return _knowledgeBases
        .where(
          (kb) =>
              kb.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              kb.description.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
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

    setState(() => _isLoading = true);

    try {
      // Create new knowledge base
      final newKnowledgeBase = KnowledgeBaseFactory.createEmpty(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _knowledgeBases.add(newKnowledgeBase);
        _toggleAddForm(); // Hide form after adding
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm bộ dữ liệu tri thức mới')),
        );
      }
    } catch (e) {
      // Handle error
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: MainAppDrawer(
        currentIndex: 2, // Index 2 corresponds to the Knowledge Base tab
        onTabSelected:
            (index) => navigation_utils.handleDrawerNavigation(
              context,
              index,
              currentIndex: 2,
            ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child:
                    _isLoading
                        ? _buildLoadingState()
                        : _filteredKnowledgeBases.isEmpty
                        ? _buildEmptyState()
                        : _buildKnowledgeBaseList(),
              ),
            ],
          ),

          // Slide-up form for adding new knowledge base
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(_animation),
              child: _buildAddForm(),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Bộ dữ liệu tri thức'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadKnowledgeBases,
        ),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bộ dữ liệu...',
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
        onChanged: (value) {
          setState(() => _searchQuery = value);
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

  Widget _buildKnowledgeBaseList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _filteredKnowledgeBases.length,
      itemBuilder: (context, index) {
        final kb = _filteredKnowledgeBases[index];
        return _buildKnowledgeBaseCard(kb);
      },
    );
  }

  Widget _buildKnowledgeBaseCard(KnowledgeBase knowledgeBase) {
    // Source type icons count
    final sourceTypeCount = {
      for (var type in KnowledgeSourceType.values)
        type: knowledgeBase.getSourcesByType(type).length,
    };

    // Get the 3 most used source types
    final topSourceTypes =
        sourceTypeCount.entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              knowledgeBase.isEnabled
                  ? Colors.transparent
                  : Colors.grey.shade300,
          width: knowledgeBase.isEnabled ? 0 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToKnowledgeDetail(knowledgeBase),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKnowledgeBaseHeader(knowledgeBase),
              const SizedBox(height: 8),
              _buildKnowledgeBaseDescription(knowledgeBase),
              const SizedBox(height: 16),
              _buildKnowledgeBaseStats(knowledgeBase, topSourceTypes),
              const SizedBox(height: 8),
              _buildProgressIndicator(knowledgeBase),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKnowledgeBaseHeader(KnowledgeBase knowledgeBase) {
    return Row(
      children: [
        Expanded(
          child: Text(
            knowledgeBase.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: knowledgeBase.isEnabled ? null : Colors.grey,
            ),
          ),
        ),
        if (!knowledgeBase.isEnabled)
          _buildStatusChip('Vô hiệu hóa', Colors.grey),
        if (knowledgeBase.isOverTokenLimit)
          _buildStatusChip('Quá giới hạn token', Colors.orange),
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

  Widget _buildKnowledgeBaseDescription(KnowledgeBase knowledgeBase) {
    return Text(
      knowledgeBase.description,
      style: TextStyle(
        color: knowledgeBase.isEnabled ? Colors.black87 : Colors.grey,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildKnowledgeBaseStats(
    KnowledgeBase knowledgeBase,
    List<MapEntry<KnowledgeSourceType, int>> topSourceTypes,
  ) {
    return Row(
      children: [
        // Source statistics
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSourceCountText(knowledgeBase),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Show top 3 source type icons
                  for (int i = 0; i < topSourceTypes.length && i < 3; i++)
                    _buildSourceTypeIcon(topSourceTypes[i]),
                  if (topSourceTypes.length > 3)
                    _buildExtraSourcesIndicator(topSourceTypes.length - 3),
                ],
              ),
            ],
          ),
        ),

        // Last updated date
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Cập nhật: ${_formatDate(knowledgeBase.lastUpdatedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (knowledgeBase.requiresSyncing)
              const Chip(
                label: Text('Cần đồng bộ', style: TextStyle(fontSize: 10)),
                backgroundColor: Color(0xFFE0E0FD),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSourceCountText(KnowledgeBase knowledgeBase) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        children: [
          const TextSpan(text: 'Nguồn dữ liệu: '),
          TextSpan(
            text:
                '${knowledgeBase.activeSourcesCount}/${knowledgeBase.totalSourcesCount}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceTypeIcon(MapEntry<KnowledgeSourceType, int> entry) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: '${KnowledgeSource.getTypeName(entry.key)}: ${entry.value}',
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: KnowledgeSource.getColorForType(entry.key).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            KnowledgeSource.getDefaultIcon(entry.key),
            size: 16,
            color: KnowledgeSource.getColorForType(entry.key),
          ),
        ),
      ),
    );
  }

  Widget _buildExtraSourcesIndicator(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '+$count',
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildProgressIndicator(KnowledgeBase knowledgeBase) {
    return LinearProgressIndicator(
      value:
          knowledgeBase.totalSourcesCount > 0
              ? knowledgeBase.activeSourcesCount /
                  knowledgeBase.totalSourcesCount
              : 0,
      backgroundColor: Colors.grey.shade200,
      valueColor: AlwaysStoppedAnimation<Color>(
        knowledgeBase.isEnabled ? Theme.of(context).primaryColor : Colors.grey,
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
                    child:
                        _isLoading
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

  void _navigateToKnowledgeDetail(KnowledgeBase knowledgeBase) {
    // Navigate to detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => KnowledgeDetailScreen(knowledgeBase: knowledgeBase),
      ),
    );
  }
}
