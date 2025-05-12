import 'package:aichatbot/data/datasources/remote/knowledge_api_service.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_unit_model.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_event.dart';
import 'package:aichatbot/screens/knowledge_management/update_knowledge_screen.dart';
import 'package:aichatbot/widgets/knowledge/knowledge_detail_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart' as di;
import 'package:aichatbot/screens/knowledge_management/add_source_screen.dart';
import 'package:flutter/material.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_event.dart';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_state.dart';
import 'package:aichatbot/widgets/knowledge/knowledge_unit_card.dart';
import 'package:aichatbot/widgets/knowledge/empty_knowledge_view.dart';
import 'package:go_router/go_router.dart';

class KnowledgeDetailScreen extends StatefulWidget {
  final KnowledgeBase knowledgeBase;

  const KnowledgeDetailScreen({Key? key, required this.knowledgeBase})
      : super(key: key);

  @override
  State<KnowledgeDetailScreen> createState() => _KnowledgeDetailScreenState();
}

class _KnowledgeDetailScreenState extends State<KnowledgeDetailScreen> {
  /// The current knowledge base being displayed
  late KnowledgeBase _knowledgeBase;

  /// Loading state for async operations
  bool _isLoading = false;

  // Knowledge units data
  final KnowledgeApiService _knowledgeApiService = di.sl<KnowledgeApiService>();
  List<KnowledgeUnitModel> _knowledgeUnits = [];
  bool _isLoadingUnits = false;
  String? _unitsErrorMessage;
  Set<String> _expandedUnitIds = {};

  // Create the KnowledgeUnitBloc from dependency injection
  late final KnowledgeUnitBloc _knowledgeUnitBloc;

  @override
  void initState() {
    super.initState();
    _knowledgeBase = widget.knowledgeBase;

    // Initialize bloc once
    _knowledgeUnitBloc = di.sl<KnowledgeUnitBloc>();

    // Fetch units when the screen loads
    _fetchKnowledgeUnits();
  }

  /// Refreshes knowledge base data
  Future<void> _refreshKnowledgeBase() async {
    setState(() => _isLoading = true);

    // Refresh units from the API
    await _fetchKnowledgeUnits();

    setState(() => _isLoading = false);
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

  void _toggleUnitExpansion(String unitId) {
    setState(() {
      if (_expandedUnitIds.contains(unitId)) {
        _expandedUnitIds.remove(unitId);
      } else {
        _expandedUnitIds.add(unitId);
      }
    });
  }

  void _showUnitDetails(KnowledgeUnitModel unit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(unit.name),
        content: SingleChildScrollView(
          child: Column(
            children: [
              //_buildDetailItem('Source', unit.source),
              _buildDetailItem('Type', unit.type),
              _buildDetailItem('Created', _formatDate(unit.createdAt)),
              if (unit.size != null)
                _buildDetailItem('Size', _formatFileSize(unit.size)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUnit(KnowledgeUnitModel unit) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 48,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Delete Datasource',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete "${unit.name}"? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          final token =
                              context.read<AuthBloc>().state.user?.accessToken;
                          if (token == null) return;
                          _knowledgeUnitBloc.add(DeleteDatasourceEvent(
                            knowledgeId: _knowledgeBase.id,
                            datasourceId: unit.id,
                            accessToken: token,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToAddSource() {
    context
        .pushNamed(
      'addSource',
      pathParameters: {'id': _knowledgeBase.id},
      extra: _knowledgeBase,
    )
        .then((updatedBase) {
      if (updatedBase is KnowledgeBase) {
        setState(() {
          _knowledgeBase = updatedBase;
        });
      }
    });
  }

  void _navigateToEditKnowledge() {
    context
        .pushNamed(
      'editKnowledge',
      pathParameters: {'id': _knowledgeBase.id},
      extra: _knowledgeBase,
    )
        .then((updated) {
      if (updated == true) {
        _refreshKnowledgeBase();
      }
    });
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
            onPressed: () => context.pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.pop();

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
              context.pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa nguồn tri thức'),
                  behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    // Provide the already created bloc instance
    return BlocProvider.value(
      value: _knowledgeUnitBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_knowledgeBase.name),
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(
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
              ))
            : Column(
                children: [
                  KnowledgeDetailHeader(
                    knowledgeBase: _knowledgeBase,
                    onRefresh: _refreshKnowledgeBase,
                    onEdit: _navigateToEditKnowledge,
                    onDelete: () => _confirmDeleteKnowledge(_knowledgeBase),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nguồn dữ liệu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _fetchKnowledgeUnits,
                          tooltip: 'Làm mới',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildSourcesList(),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToAddSource,
          label: const Text('Thêm nguồn'),
          icon: const Icon(Icons.add),
          elevation: 3,
        ),
      ),
    );
  }

  Widget _buildSourcesList() {
    return BlocConsumer<KnowledgeUnitBloc, KnowledgeUnitState>(
      listener: (context, state) {
        if (state is KnowledgeUnitError) {
          setState(() {
            _unitsErrorMessage = state.message;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${state.message}')),
          );
        } else if (state is KnowledgeUnitLoaded) {
          setState(() {
            _knowledgeUnits = state.units;
            _unitsErrorMessage = null; // Clear any previous error
          });
        }
      },
      builder: (context, state) {
        if (state is KnowledgeUnitLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is KnowledgeUnitLoaded) {
          if (state.units.isEmpty) {
            return EmptyKnowledgeView(
              message: 'Chưa có nguồn dữ liệu nào',
              onAddPressed: _navigateToAddSource,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: state.units.length,
            itemBuilder: (context, index) {
              final unit = state.units[index];
              final isExpanded = _expandedUnitIds.contains(unit.id);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: KnowledgeUnitCard(
                  unit: unit,
                  isExpanded: isExpanded,
                  onExpansionChanged: (expanded) =>
                      _toggleUnitExpansion(unit.id),
                  onViewDetails: () => _showUnitDetails(unit),
                  onDelete: () => _confirmDeleteUnit(unit),
                ),
              );
            },
          );
        }

        // Fallback for initial state
        return EmptyKnowledgeView(
          message: 'Chưa có nguồn dữ liệu nào',
          onAddPressed: _navigateToAddSource,
        );
      },
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
