import 'package:aichatbot/screens/knowledge_management/add_source_screen.dart';
import 'package:flutter/material.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';

/// A screen that displays detailed information about a knowledge base
/// and allows management of its sources.
///
/// Features:
/// * View knowledge base details and stats
/// * View list of sources
/// * Enable/disable sources
/// * Delete sources
/// * Add new sources
class KnowledgeDetailScreen extends StatefulWidget {
  /// The knowledge base to display and manage
  final KnowledgeBase knowledgeBase;

  const KnowledgeDetailScreen({super.key, required this.knowledgeBase});

  @override
  State<KnowledgeDetailScreen> createState() => _KnowledgeDetailScreenState();
}

/// State management for [KnowledgeDetailScreen].
/// Handles source operations and UI updates.
class _KnowledgeDetailScreenState extends State<KnowledgeDetailScreen> {
  /// The current knowledge base being displayed
  late KnowledgeBase _knowledgeBase;

  /// Loading state for async operations
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _knowledgeBase = widget.knowledgeBase;
  }

  /// Refreshes knowledge base data
  Future<void> _refreshKnowledgeBase() async {
    setState(() => _isLoading = true);

    // In a real app, this would refresh from the API/database
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isLoading = false);
  }

  /// Toggles the enabled state of a source
  void _toggleSourceStatus(KnowledgeSource source) {
    final updatedSource = source.copyWith(
      isEnabled: !source.isEnabled,
      lastUpdated: DateTime.now(),
    );

    setState(() {
      _knowledgeBase = _knowledgeBase.updateSource(updatedSource);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedSource.isEnabled
              ? 'Đã kích hoạt nguồn dữ liệu'
              : 'Đã vô hiệu hóa nguồn dữ liệu',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteSource(KnowledgeSource source) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa nguồn dữ liệu'),
            content: const Text(
              'Bạn có chắc muốn xóa nguồn dữ liệu này? Hành động này không thể hoàn tác.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _knowledgeBase = _knowledgeBase.removeSource(source.id);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa nguồn dữ liệu'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  void _showSourceOptions(KnowledgeSource source) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  source.isEnabled ? Icons.toggle_off : Icons.toggle_on,
                  color: source.isEnabled ? Colors.red : Colors.green,
                ),
                title: Text(
                  source.isEnabled
                      ? 'Vô hiệu hóa nguồn dữ liệu'
                      : 'Kích hoạt nguồn dữ liệu',
                  style: TextStyle(
                    color: source.isEnabled ? Colors.red : Colors.green,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleSourceStatus(source);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Xóa nguồn dữ liệu',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteSource(source);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingIndicator() : _buildBody(),
      floatingActionButton: _buildAddButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_knowledgeBase.name),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshKnowledgeBase,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildKnowledgeBaseHeader(),
        const Divider(height: 1),
        _buildSourcesHeader(),
        Expanded(
          child:
              _knowledgeBase.sources.isEmpty
                  ? _buildEmptySourcesView()
                  : _buildSourcesList(),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddSource,
      label: const Text('Thêm nguồn dữ liệu'),
      icon: const Icon(Icons.add),
    );
  }

  void _navigateToAddSource() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSourceScreen(knowledgeBase: _knowledgeBase),
      ),
    ).then((updatedBase) {
      if (updatedBase != null && updatedBase is KnowledgeBase) {
        setState(() {
          _knowledgeBase = updatedBase;
        });
      }
    });
  }

  /// Builds the knowledge base header with stats and status
  Widget _buildKnowledgeBaseHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _knowledgeBase.description,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  children: [
                    const TextSpan(text: 'Nguồn dữ liệu hoạt động: '),
                    TextSpan(
                      text:
                          '${_knowledgeBase.activeSourcesCount}/${_knowledgeBase.totalSourcesCount}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  _knowledgeBase.isEnabled
                      ? 'Đang hoạt động'
                      : 'Đã vô hiệu hóa',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                backgroundColor:
                    _knowledgeBase.isEnabled ? Colors.green : Colors.grey,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value:
                _knowledgeBase.totalSourcesCount > 0
                    ? _knowledgeBase.activeSourcesCount /
                        _knowledgeBase.totalSourcesCount
                    : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _knowledgeBase.isEnabled
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the sources list header with count
  Widget _buildSourcesHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Nguồn dữ liệu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (_knowledgeBase.sources.isNotEmpty)
            Text(
              '${_knowledgeBase.sources.length} nguồn',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptySourcesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.source_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có nguồn dữ liệu nào',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // In a real app, navigate to add source screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Chức năng thêm nguồn dữ liệu sẽ được triển khai sau',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm nguồn dữ liệu'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesList() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemCount: _knowledgeBase.sources.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final source = _knowledgeBase.sources[index];
        return _buildSourceItem(source);
      },
    );
  }

  /// Builds individual source list items
  Widget _buildSourceItem(KnowledgeSource source) {
    return ListTile(
      leading: _buildSourceIcon(source),
      title: _buildSourceTitle(source),
      subtitle: _buildSourceSubtitle(source),
      trailing: _buildSourceOptionsButton(source),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        // View source details (not implemented in this example)
      },
    );
  }

  Widget _buildSourceIcon(KnowledgeSource source) {
    final sourceColor =
        source.isEnabled
            ? KnowledgeSource.getColorForType(source.type)
            : Colors.grey;

    return CircleAvatar(
      backgroundColor: sourceColor.withOpacity(0.1),
      child: Icon(source.icon, color: sourceColor, size: 20),
    );
  }

  Widget _buildSourceTitle(KnowledgeSource source) {
    return Text(
      source.title,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: source.isEnabled ? null : Colors.grey,
        decoration: source.isEnabled ? null : TextDecoration.lineThrough,
      ),
    );
  }

  Widget _buildSourceSubtitle(KnowledgeSource source) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          source.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: source.isEnabled ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 4),
        _buildSourceMetadata(source),
      ],
    );
  }

  Widget _buildSourceMetadata(KnowledgeSource source) {
    return Row(
      children: [
        _buildDateInfo(
          Icons.calendar_today,
          'Thêm vào: ${_formatDate(source.addedAt)}',
        ),
        const SizedBox(width: 12),
        if (source.lastUpdated != null)
          _buildDateInfo(
            Icons.update,
            'Cập nhật: ${_formatDate(source.lastUpdated!)}',
          ),
      ],
    );
  }

  Widget _buildDateInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildSourceOptionsButton(KnowledgeSource source) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () => _showSourceOptions(source),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
