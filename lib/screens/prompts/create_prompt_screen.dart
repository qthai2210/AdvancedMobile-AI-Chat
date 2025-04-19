import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_state.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/utils/build_context_extensions.dart';
import 'package:aichatbot/screens/prompts/widgets/section_title.dart';
import 'package:aichatbot/screens/prompts/widgets/category_selector.dart';
import 'package:aichatbot/screens/prompts/widgets/privacy_toggle.dart';
import 'package:aichatbot/screens/prompts/widgets/submit_button.dart';

class CreatePromptScreen extends StatefulWidget {
  const CreatePromptScreen({Key? key}) : super(key: key);

  @override
  State<CreatePromptScreen> createState() => _CreatePromptScreenState();
}

class _CreatePromptScreenState extends State<CreatePromptScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'other';
  bool _isPublic = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PromptBloc, PromptState>(
      listener: (context, state) {
        if (state.status == PromptStatus.loading && _isSubmitting) {
          // Show loading indicator
        } else if (state.status == PromptStatus.success &&
            state.newPrompt != null) {
          _isSubmitting = false;
          context.showSuccessNotification('Prompt đã được tạo thành công!');
          Navigator.of(context).pop(true);
        } else if (state.status == PromptStatus.failure && _isSubmitting) {
          _isSubmitting = false;
          context.showApiErrorNotification(
              state.errorMessage ?? "Failed to create prompt");
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh tiến trình
              LinearProgressIndicator(
                value: 0.5,
                backgroundColor: Colors.grey[200],
                color: Theme.of(context).primaryColor,
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      // Cài đặt quyền riêng tư
                      const SectionTitle(title: 'Cài đặt quyền riêng tư'),
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

                      // Nội dung Prompt
                      const SectionTitle(title: 'Nội dung Prompt'),
                      const SizedBox(height: 12),
                      _buildContentField(),
                      const SizedBox(height: 30),

                      // Nút tạo prompt
                      BlocBuilder<PromptBloc, PromptState>(
                        builder: (context, state) {
                          return SubmitButton(
                            isLoading: state.status == PromptStatus.loading &&
                                _isSubmitting,
                            onPressed: state.status == PromptStatus.loading
                                ? null
                                : _submitForm,
                            label: 'Tạo Prompt',
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Tạo Prompt mới'),
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      actions: [
        BlocBuilder<PromptBloc, PromptState>(
          builder: (context, state) {
            return TextButton.icon(
              onPressed:
                  state.status == PromptStatus.loading ? null : _submitForm,
              icon: state.status == PromptStatus.loading && _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Lưu'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Tiêu đề',
        hintText: 'Nhập tiêu đề cho prompt của bạn',
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        prefixIcon: const Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập tiêu đề';
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
        hintText: 'Mô tả ngắn gọn về prompt',
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        prefixIcon: const Icon(Icons.description),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập mô tả';
        }
        return null;
      },
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: InputDecoration(
        hintText: 'Nhập nội dung prompt của bạn...',
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: 10,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập nội dung prompt';
        }
        return null;
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (!authState.status.isSuccess || authState.user?.accessToken == null) {
        context.showWarningNotification(
          'Bạn cần đăng nhập để tạo prompt',
          actionLabel: 'Đăng nhập',
          onAction: () => Navigator.of(context).pushReplacementNamed('/login'),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      context.read<PromptBloc>().add(
            CreatePrompt(
              accessToken: authState.user!.accessToken!,
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              description: _descriptionController.text.trim(),
              category: _selectedCategory,
              isPublic: _isPublic,
              language: 'vi',
              xJarvisGuid: null,
            ),
          );
    }
  }
}
