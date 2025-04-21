import 'package:aichatbot/data/datasources/remote/knowledge_api_service.dart';
import 'package:aichatbot/data/models/knowledge/get_knowledge_units_params.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_unit_model.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_event.dart';
import 'package:aichatbot/screens/knowledge_management/update_knowledge_screen.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart' as di;
import 'package:aichatbot/screens/knowledge_management/add_source_screen.dart';
import 'package:flutter/material.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_event.dart';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_state.dart';

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
  // Add these fields for knowledge units
  final KnowledgeApiService _knowledgeApiService = di.sl<KnowledgeApiService>();
  List<KnowledgeUnitModel> _knowledgeUnits = [];
  bool _isLoadingUnits = false;
  String? _unitsErrorMessage;

  // Create the KnowledgeUnitBloc from dependency injection
  late final KnowledgeUnitBloc _knowledgeUnitBloc;

  /// Refreshes knowledge base data
  Future<void> _refreshKnowledgeBase() async {
    setState(() => _isLoading = true);

    // Refresh units from the API
    await _fetchKnowledgeUnits();

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
      builder: (context) => AlertDialog(
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
      builder: (context) => Column(
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

  /// Fetch knowledge units using Bloc
  Future<void> _fetchKnowledgeUnits() async {
    if (_knowledgeBase.id.isEmpty) {
      setState(() {
        _unitsErrorMessage = 'Invalid knowledge base ID';
      });
      return;
    }

    try {
      // Get access token from auth bloc
      final authState = context.read<AuthBloc>().state;
      final accessToken = authState.user?.accessToken;

      if (accessToken == null) {
        setState(() {
          _unitsErrorMessage = 'Authentication required';
        });
        return;
      }

      // Use the instance variable directly to ensure we're using the same bloc instance
      _knowledgeUnitBloc.add(
        FetchKnowledgeUnitsEvent(
          knowledgeId: _knowledgeBase.id,
          accessToken: accessToken,
        ),
      );

      setState(() {
        _unitsErrorMessage = null; // Reset error message
      });
    } catch (e) {
      setState(() {
        _unitsErrorMessage = 'Failed to load units: ${e.toString()}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _knowledgeBase = widget.knowledgeBase;
    print('KnowledgeBase ID: ${_knowledgeBase.id}');

    // Initialize bloc once
    _knowledgeUnitBloc = di.sl<KnowledgeUnitBloc>();

    // Fetch units when the screen loads
    _fetchKnowledgeUnits();
  }

  @override
  Widget build(BuildContext context) {
    // Provide the already created bloc instance
    return BlocProvider.value(
      value: _knowledgeUnitBloc,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _isLoading ? _buildLoadingIndicator() : _buildBody(),
        floatingActionButton: _buildAddButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_knowledgeBase.name),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _navigateToEditKnowledge,
        ),
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
          // Always use _buildSourcesList to ensure it receives bloc updates
          child: _buildSourcesList(),
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
            value: _knowledgeBase.totalSourcesCount > 0
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
    return BlocBuilder<KnowledgeUnitBloc, KnowledgeUnitState>(
      builder: (context, state) {
        AppLogger.e(
            "_buildSourcesHeader builder received state: ${state.runtimeType}");

        String headerText = 'Nguồn dữ liệu';

        if (state is KnowledgeUnitLoaded) {
          int totalUnits = state.meta['total'] ?? state.units.length;
          headerText = 'Nguồn dữ liệu ($totalUnits)';
        } else if (state is KnowledgeUnitError) {
          headerText = 'Nguồn dữ liệu (0)';
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headerText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _refreshKnowledgeBase,
                child: const Text('Refresh'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptySourcesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có dữ liệu',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Thêm nguồn dữ liệu đầu tiên của bạn bằng cách nhấn vào nút bên dưới',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddSource,
              icon: const Icon(Icons.add),
              label: const Text('Thêm nguồn dữ liệu'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourcesList() {
    return BlocConsumer<KnowledgeUnitBloc, KnowledgeUnitState>(
      listener: (context, state) {
        AppLogger.e(
            "_buildSourcesList listener received state: ${state.runtimeType}");

        if (state is KnowledgeUnitError) {
          setState(() {
            _unitsErrorMessage = state.message;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${state.message}')),
          );
        } else if (state is KnowledgeUnitLoaded) {
          // Update units list when loaded, even if empty
          AppLogger.e(
              "KnowledgeUnitLoaded: ${state.units.length} units loaded");
          setState(() {
            _knowledgeUnits = state.units;
            _unitsErrorMessage = null; // Clear any previous error
          });
        }
      },
      builder: (context, state) {
        // Add debug message for all state types in builder
        AppLogger.e(
            "_buildSourcesList builder received state: ${state.runtimeType}");

        if (state is KnowledgeUnitLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is KnowledgeUnitLoaded) {
          AppLogger.e(
              "KnowledgeUnitLoaded: ${state.units.length} units loaded");
          AppLogger.e("KnowledgeUnitLoaded: ${state.units}");
          if (state.units.isEmpty) {
            return _buildEmptySourcesView();
          }

          return ListView.separated(
            itemCount: state.units.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final unit = state.units[index];
              return _buildUnitItem(unit);
            },
          );
        }

        // Fallback for initial state
        return _buildEmptySourcesView();
      },
    );
  }

  /// Builds individual source list items
  Widget _buildUnitItem(KnowledgeUnitModel unit) {
    return ExpansionTile(
      leading: _buildUnitIcon(unit),
      title: Text(
        unit.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type: ${unit.type}, Size: ${_formatFileSize(unit.size)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Created: ${_formatDate(unit.createdAt)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showUnitOptions(unit),
      ),
      children: [
        if (unit.metadata.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Metadata:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...unit.metadata.entries
                    .map((entry) =>
                        _buildDetailItem(entry.key, entry.value.toString()))
                    .toList(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUnitIcon(KnowledgeUnitModel unit) {
    IconData iconData;
    Color iconColor;

    // Determine icon based on type and metadata
    switch (unit.type) {
      case 'local_file':
        final fileName = unit.name.toLowerCase();
        if (fileName.endsWith('.pdf')) {
          iconData = Icons.picture_as_pdf;
          iconColor = Colors.red;
        } else if (fileName.endsWith('.docx') || fileName.endsWith('.doc')) {
          iconData = Icons.description;
          iconColor = Colors.blue;
        } else if (fileName.endsWith('.txt')) {
          iconData = Icons.text_snippet;
          iconColor = Colors.orange;
        } else {
          iconData = Icons.insert_drive_file;
          iconColor = Colors.grey;
        }
        break;
      default:
        iconData = Icons.file_present;
        iconColor = Colors.teal;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showUnitOptions(KnowledgeUnitModel unit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              _showUnitDetails(unit);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Delete Unit',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteUnit(unit);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showUnitDetails(KnowledgeUnitModel unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(unit.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Type', unit.type),
              _buildDetailItem('Size', _formatFileSize(unit.size)),
              _buildDetailItem('Status', unit.status ? 'Active' : 'Inactive'),
              _buildDetailItem('Created', _formatDate(unit.createdAt)),
              _buildDetailItem('Updated', _formatDate(unit.updatedAt)),
              if (unit.metadata.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Metadata',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...unit.metadata.entries
                    .map((entry) =>
                        _buildDetailItem(entry.key, entry.value.toString()))
                    .toList(),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _confirmDeleteUnit(KnowledgeUnitModel unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text(
          'Are you sure you want to delete "${unit.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement unit deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Unit deletion will be implemented soon')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToEditKnowledge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UpdateKnowledgeScreen(knowledgeBase: _knowledgeBase),
      ),
    ).then((updated) {
      if (updated == true) {
        // Refresh to get the updated knowledge base
        _refreshKnowledgeBase();
      }
    });
  }

  void _showKnowledgeOptions(KnowledgeBase knowledge) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Xem chi tiết'),
            onTap: () {
              Navigator.pop(context);
              _navigateToKnowledgeDetail(knowledge);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Chỉnh sửa'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UpdateKnowledgeScreen(knowledgeBase: knowledge),
                ),
              ).then((updated) {
                if (updated == true) {
                  // Refresh the list if updated
                  context.read<KnowledgeBloc>().add(
                        const RefreshKnowledgesEvent(limit: 20),
                      );
                }
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteKnowledge(knowledge);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _confirmDeleteKnowledge(KnowledgeBase knowledge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nguồn tri thức'),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${knowledge.name}"? Hành động này không thể hoàn tác và sẽ xóa tất cả nguồn dữ liệu liên quan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // Get auth token
              final authState = context.read<AuthBloc>().state;
              final accessToken = authState.user?.accessToken;

              if (accessToken == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Bạn cần đăng nhập để thực hiện thao tác này')),
                );
                return;
              }

              // Delete knowledge base using bloc
              context.read<KnowledgeBloc>().add(
                    DeleteKnowledgeEvent(
                      id: knowledge.id,
                      xJarvisGuid: accessToken,
                    ),
                  );

              // Navigate back to knowledge list screen
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa nguồn tri thức')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _navigateToKnowledgeDetail(KnowledgeBase knowledge) {
    // Since we're already in the knowledge detail screen, this method doesn't need to navigate
    // to a new screen. We can just show a dialog with more details if needed.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(knowledge.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('ID', knowledge.id),
              _buildDetailItem('Description', knowledge.description),
              _buildDetailItem(
                  'Status', knowledge.isEnabled ? 'Active' : 'Inactive'),
              _buildDetailItem('Sources', '${knowledge.totalSourcesCount}'),
              _buildDetailItem(
                  'Active Sources', '${knowledge.activeSourcesCount}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
