import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/screens/prompts/create_prompt_screen.dart';
import 'package:aichatbot/utils/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        onAction: () => Navigator.of(context).pushReplacementNamed('/login'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Private Prompts'),
      ),
      body: BlocConsumer<PromptBloc, PromptState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.prompts?.length != current.prompts?.length,
        listener: (context, state) {
          if (state.status == PromptStatus.failure) {
            context.showErrorNotification(
              state.errorMessage ?? 'An error occurred while loading prompts',
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
            return const Center(child: CircularProgressIndicator());
          } else if (state.prompts?.isEmpty ?? true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa có prompt riêng tư nào',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatePromptScreen(),
                        ),
                      ).then((result) {
                        if (result == true) {
                          _loadPrivatePrompts();
                        }
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo prompt riêng tư'),
                  ),
                ],
              ),
            );
          } else {
            final prompts = [...?state.prompts];
            prompts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                return _buildPromptItem(prompt);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePromptScreen(),
            ),
          ).then((result) {
            if (result == true) {
              _loadPrivatePrompts();
            }
          });
        },
        tooltip: 'Tạo Prompt Riêng Tư',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPromptItem(PromptModel prompt) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewPromptDetails(prompt),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock_outline,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                prompt.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Private prompt',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      prompt.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: prompt.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => _toggleFavorite(prompt),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                prompt.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              if (prompt.category != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Prompt.getCategoryColor(
                                  prompt.category ?? 'Other')
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Prompt.getCategoryColor(
                                      prompt.category ?? 'Other')
                                  .withOpacity(0.3)),
                        ),
                        child: Text(
                          prompt.category ?? 'Other',
                          style: TextStyle(
                            fontSize: 12,
                            color: Prompt.getCategoryColor(
                                prompt.category ?? 'Other'),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    onPressed: () => _editPrompt(prompt),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    onPressed: () => _confirmDeletePrompt(prompt),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.chat, size: 16),
                    label: const Text('Use'),
                    onPressed: () => _usePrompt(prompt),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Các phương thức xử lý hành động - có thể tái sử dụng từ PromptsScreen
  void _viewPromptDetails(PromptModel prompt) {
    // Tái sử dụng phương thức từ PromptsScreen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildPromptDetailSheet(prompt),
    );
  }

  Widget _buildPromptDetailSheet(PromptModel prompt) {
    // Tái sử dụng phương thức từ PromptsScreen
    // Nhớ thêm biểu tượng khóa để thể hiện rằng đây là prompt riêng tư
    return DraggableScrollableSheet(
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            prompt.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              // Phần còn lại giống với _buildPromptDetailSheet của PromptsScreen
            ],
          ),
        );
      },
    );
  }

  void _toggleFavorite(PromptModel prompt) {
    // Tái sử dụng phương thức từ PromptsScreen
  }

  void _editPrompt(PromptModel prompt) {
    // Tái sử dụng phương thức từ PromptsScreen
  }

  void _confirmDeletePrompt(PromptModel prompt) {
    // Tái sử dụng phương thức từ PromptsScreen
  }

  void _usePrompt(PromptModel prompt) {
    // Tái sử dụng phương thức từ PromptsScreen
  }
}
