import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/utils/build_context_extensions.dart';
import 'package:aichatbot/screens/prompts/widgets/section_title.dart';
import 'package:aichatbot/screens/prompts/widgets/prompt_header_info.dart';
import 'package:aichatbot/screens/prompts/widgets/category_selector.dart';
import 'package:aichatbot/screens/prompts/widgets/privacy_toggle.dart';
import 'package:aichatbot/screens/prompts/widgets/submit_button.dart';
import 'package:go_router/go_router.dart';

class EditPromptScreen extends StatefulWidget {
  final PromptModel prompt;

  const EditPromptScreen({Key? key, required this.prompt}) : super(key: key);

  @override
  State<EditPromptScreen> createState() => _EditPromptScreenState();
}

class _EditPromptScreenState extends State<EditPromptScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contentController;
  String _selectedCategory = 'other';
  bool _isPublic = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.prompt.title);
    _descriptionController =
        TextEditingController(text: widget.prompt.description);
    _contentController = TextEditingController(text: widget.prompt.content);
    _selectedCategory = widget.prompt.category ?? 'other';
    _isPublic = widget.prompt.isPublic;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PromptBloc, PromptState>(
      listener: (context, state) {
        if (state.status == PromptStatus.success) {
          setState(() {
            _isSubmitting = false;
          });
          context.showSuccessNotification('Cập nhật prompt thành công');
          Future.delayed(const Duration(milliseconds: 500), () {
            context.pop(true);
          });
        } else if (state.status == PromptStatus.failure) {
          setState(() {
            _isSubmitting = false;
          });
          context.showErrorNotification('Lỗi: ${state.errorMessage}');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(state),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị thanh trạng thái
                _buildProgressBar(),

                // Form chính
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tiêu đề và ID prompt
                        PromptHeaderInfo(
                          title: widget.prompt.title,
                          id: widget.prompt.id,
                        ),
                        const SizedBox(height: 20),

                        // Thông tin cơ bản
                        const SectionTitle(title: 'Thông tin cơ bản'),
                        const SizedBox(height: 16),
                        _buildTitleField(),
                        const SizedBox(height: 16),
                        _buildDescriptionField(),
                        const SizedBox(height: 24),

                        // Danh mục
                        const SectionTitle(title: 'Danh mục'),
                        const SizedBox(height: 12),
                        CategorySelector(
                          selectedCategory: _selectedCategory,
                          onCategorySelected: (category) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Quyền riêng tư
                        const SectionTitle(title: 'Quyền riêng tư'),
                        const SizedBox(height: 12),
                        PrivacyToggle(
                          isPublic: _isPublic,
                          onToggle: (value) {
                            setState(() {
                              _isPublic = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Nội dung
                        const SectionTitle(title: 'Nội dung Prompt'),
                        const SizedBox(height: 12),
                        _buildContentField(),
                        const SizedBox(height: 30),

                        // Nút lưu
                        SubmitButton(
                          isLoading: _isSubmitting,
                          onPressed: _isSubmitting ? null : _savePrompt,
                          label: 'Cập nhật Prompt',
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(PromptState state) {
    return AppBar(
      title: const Text('Chỉnh sửa Prompt'),
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      actions: [
        if (_isSubmitting)
          const Padding(
            padding: EdgeInsets.all(14.0),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Lưu'),
            onPressed: _savePrompt,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: double.infinity,
      height: 4,
      color: Colors.grey[200],
      child: _isSubmitting
          ? LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            )
          : null,
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Tiêu đề',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: const Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập tiêu đề';
        }
        if (value.trim().length < 3) {
          return 'Tiêu đề phải có ít nhất 3 ký tự';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Mô tả',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: const Icon(Icons.description),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập mô tả';
        }
        if (value.trim().length < 10) {
          return 'Mô tả phải có ít nhất 10 ký tự';
        }
        return null;
      },
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: InputDecoration(
        labelText: 'Nội dung Prompt',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        alignLabelWithHint: true,
      ),
      maxLines: 10,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập nội dung prompt';
        }
        if (value.trim().length < 10) {
          return 'Nội dung prompt phải có ít nhất 10 ký tự';
        }
        return null;
      },
    );
  }

  void _savePrompt() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory.isEmpty) {
        context.showWarningNotification('Vui lòng chọn một danh mục');
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      final authState = context.read<AuthBloc>().state;
      if (authState.user?.accessToken != null) {
        final updatedPrompt = Prompt(
          id: widget.prompt.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          isPublic: _isPublic,
          authorId: widget.prompt.userId,
          authorName: widget.prompt.userName,
          isFavorite: widget.prompt.isFavorite,
          useCount: widget.prompt.useCount,
          createdAt: widget.prompt.createdAt,
        );

        context.read<PromptBloc>().add(
              UpdatePrompt(
                accessToken: authState.user!.accessToken!,
                promptId: widget.prompt.id,
                title: updatedPrompt.title,
                description: updatedPrompt.description,
                content: updatedPrompt.content,
                category: updatedPrompt.category,
                isPublic: updatedPrompt.isPublic,
              ),
            );
      } else {
        setState(() {
          _isSubmitting = false;
        });
        context.showWarningNotification(
          'Bạn cần đăng nhập để cập nhật prompt',
          actionLabel: 'Đăng nhập',
          onAction: () => context.pushReplacementNamed('/login'),
        );
      }
    }
  }
}
