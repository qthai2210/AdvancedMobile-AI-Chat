import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/screens/chat_detail_screen.dart';
import 'package:aichatbot/screens/prompts/create_prompt_screen.dart';
import 'package:aichatbot/screens/prompts/edit_prompt_screen.dart';
import 'package:aichatbot/screens/prompts/widgets/loading_state_view.dart';
import 'package:aichatbot/screens/prompts/widgets/prompt_detail_sheet.dart';
import 'package:aichatbot/screens/prompts/widgets/private_prompt_item.dart';
import 'package:aichatbot/screens/prompts/widgets/private_prompts_header.dart';
import 'package:aichatbot/screens/prompts/widgets/private_prompts_empty_state.dart';
import 'package:aichatbot/utils/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/utils/date_formatter.dart';
import 'package:go_router/go_router.dart';

class PrivatePromptsScreen extends StatefulWidget {
  const PrivatePromptsScreen({Key? key}) : super(key: key);

  @override
  State<PrivatePromptsScreen> createState() => _PrivatePromptsScreenState();
}

class _PrivatePromptsScreenState extends State<PrivatePromptsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPrivatePrompts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
      if (authState.user?.accessToken == null) return;

      final accessToken = authState.user!.accessToken!;
      final currentOffset = promptState.promptListResponse!.offset;
      final pageSize = promptState.promptListResponse!.limit;

      try {
        context.read<PromptBloc>().add(
              LoadMorePrompts(
                accessToken: accessToken,
                offset: currentOffset + pageSize,
                limit: pageSize,
                isPublic: false, // Chỉ lấy private prompts
              ),
            );
      } catch (e) {
        debugPrint('Error loading more private prompts: $e');
      }
    }
  }

  void _loadPrivatePrompts() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user?.accessToken == null) {
      context.showWarningNotification(
        'Bạn cần đăng nhập để xem prompts riêng tư',
        actionLabel: 'Đăng nhập',
        onAction: () => context.pushReplacementNamed('/login'),
      );
      return;
    }

    // Gọi API để lấy private prompts
    context.read<PromptBloc>().add(
          FetchPrompts(
            accessToken: authState.user!.accessToken!,
            limit: 20,
            offset: 0,
            isPublic: false, // Chỉ lấy prompts riêng tư
          ),
        );
  }

  void _toggleFavorite(PromptModel prompt) async {
    final authState = context.read<AuthBloc>().state;
    final accessToken = authState.user?.accessToken;

    if (accessToken != null) {
      context.read<PromptBloc>().add(
            ToggleFavoriteRequested(
              promptId: prompt.id,
              accessToken: accessToken,
              currentFavoriteStatus: prompt.isFavorite,
            ),
          );

      final message = prompt.isFavorite
          ? 'Đã xóa khỏi danh sách yêu thích'
          : 'Đã thêm vào danh sách yêu thích';

      context.showSuccessNotification(message);
    } else {
      context.showWarningNotification(
        'Bạn cần đăng nhập để sử dụng tính năng này',
      );
    }
  }

  void _editPrompt(PromptModel prompt) {
    context
        .pushNamed(
      'editPrompt',
      pathParameters: {'id': prompt.id},
      extra: prompt,
    )
        .then((result) {
      if (result == true) {
        _loadPrivatePrompts();
      }
    });
  }

  void _usePrompt(PromptModel prompt) {
    try {
      // Show notification first, before navigation
      context.showInfoNotification('Đang chuyển sang trò chuyện mới');

      // Delay navigation slightly to allow notification to show
      Future.delayed(const Duration(milliseconds: 100), () {
        context.pushNamed(
          'chatDetail',
          pathParameters: {'threadId': 'new'},
          extra: <String, dynamic>{
            'initialPrompt': prompt.content,
            'setCursorToEnd': true,
          },
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

  void _confirmDeletePrompt(BuildContext context, PromptModel prompt) {
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
                'Đây là prompt riêng tư và sẽ bị xóa vĩnh viễn.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
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
              onPressed: () => context.pop(dialogContext),
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
                context.pop(dialogContext);
                _deletePrompt(prompt);
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

  void _deletePrompt(PromptModel prompt) {
    final authState = context.read<AuthBloc>().state;
    if (authState.user?.accessToken != null) {
      context.read<PromptBloc>().add(
            DeletePrompt(
              accessToken: authState.user!.accessToken!,
              promptId: prompt.id,
            ),
          );

      // Hiển thị loading indicator trong khi chờ xóa
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) {
          return BlocListener<PromptBloc, PromptState>(
            listener: (context, state) {
              if (state.status == PromptStatus.success &&
                  state.deletedPromptId == prompt.id) {
                context.pop(loadingContext);
                context.showSuccessNotification('Đã xóa prompt thành công');
                _loadPrivatePrompts(); // Reload danh sách sau khi xóa
              } else if (state.status == PromptStatus.failure) {
                context.pop(loadingContext);
                context.showErrorNotification(
                  'Lỗi: ${state.errorMessage ?? "Không thể xóa prompt"}',
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Đang xóa prompt...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vui lòng đợi trong giây lát',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _viewPromptDetails(PromptModel prompt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PromptDetailSheet(
        prompt: prompt,
        isOwner: true, // Private prompts are always owned by the user
        onToggleFavorite: _toggleFavorite,
        onEdit: _editPrompt,
        onSaveAsPrivate: (_) {}, // Not needed for private prompts
        onUse: _usePrompt,
        onDelete: _confirmDeletePrompt,
      ),
    );
  }

  void _navigateToCreatePrompt() {
    context.push('/prompts/create').then((result) {
      if (result == true) {
        _loadPrivatePrompts();
        context.showSuccessNotification('Tạo prompt thành công');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Prompts Riêng Tư',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tạo Prompt mới',
            onPressed: _navigateToCreatePrompt,
          ),
        ],
      ),
      body: BlocConsumer<PromptBloc, PromptState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.prompts?.length != current.prompts?.length,
        listener: (context, state) {
          if (state.status == PromptStatus.failure) {
            context.showErrorNotification(
              state.errorMessage ?? 'Lỗi khi tải prompts',
            );
          }
        },
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.prompts != current.prompts;
        },
        builder: (context, state) {
          if (state.status == PromptStatus.initial ||
              state.status == PromptStatus.loading &&
                  (state.prompts?.isEmpty ?? true)) {
            return const LoadingStateView();
          } else if (state.prompts?.isEmpty ?? true) {
            return PrivatePromptsEmptyState(
              onCreatePrompt: _navigateToCreatePrompt,
            );
          } else {
            final prompts = [...?state.prompts];
            prompts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: prompts.length + 1, // +1 for the header
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Header with count
                  return PrivatePromptsHeader(count: prompts.length);
                }

                final prompt = prompts[index - 1];
                return PrivatePromptItem(
                  prompt: prompt,
                  onViewDetails: _viewPromptDetails,
                  onToggleFavorite: _toggleFavorite,
                  onEdit: _editPrompt,
                  onUsePrompt: _usePrompt,
                  onDeletePrompt: _confirmDeletePrompt,
                  formatDate: DateFormatter.formatRelative,
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreatePrompt,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tạo Prompt', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
