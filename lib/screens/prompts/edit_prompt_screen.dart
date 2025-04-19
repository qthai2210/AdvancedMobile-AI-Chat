import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/widgets/app_notification.dart'; // Đảm bảo đã import AppNotification
import 'package:aichatbot/utils/error_formatter.dart';
import 'package:aichatbot/utils/build_context_extensions.dart'; // Đầu tiên, thêm import cho BuildContext extension
import 'package:aichatbot/core/di/injection_container.dart' as di;

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
  String _selectedCategory =
      'other'; // This is already defined as a single string
  bool _isPublic = true;
  bool _isSubmitting = false;

  // Available categories
  final List<String> _categories = [
    'business',
    'career',
    'chatbot',
    'coding',
    'education',
    'fun',
    'marketing',
    'productivity',
    'seo',
    'writing',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.prompt.title);
    _descriptionController =
        TextEditingController(text: widget.prompt.description);
    _contentController = TextEditingController(text: widget.prompt.content);
    _selectedCategory =
        widget.prompt.category ?? 'Other'; // Use the single category
    _isPublic = widget.prompt.isPublic;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _savePrompt() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory.isEmpty) {
        // Thay ScaffoldMessenger bằng extension
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

        // Thay AppNotification bằng extension
        context.showWarningNotification(
          'Đăng nhập để tiếp tục',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PromptBloc, PromptState>(
      listener: (context, state) {
        // Thêm log ở đây để xem state thực tế
        debugPrint(
            'EditPromptScreen - Current state: ${state.status}, updatedPrompt: ${state.updatedPrompt?.id}');

        // Sửa điều kiện kiểm tra - chỉ kiểm tra status là success
        if (state.status == PromptStatus.success) {
          debugPrint('Edit screen: Success detected, hiding loading indicator');
          setState(() {
            _isSubmitting = false;
          });

          // Đảm bảo thông báo hiển thị trước khi navigation
          context.showSuccessNotification('Cập nhật prompt thành công');

          // Thêm delay nhỏ trước khi điều hướng để đảm bảo thông báo đã hiển thị
          Future.delayed(const Duration(milliseconds: 500), () {
            // Đóng màn hình và quay lại
            Navigator.of(context).pop(true);
          });
        } else if (state.status == PromptStatus.failure) {
          debugPrint('Edit screen: Failure detected, hiding loading indicator');
          setState(() {
            _isSubmitting = false;
          });

          context.showErrorNotification('Lỗi: ${state.errorMessage}');
        }
      },
      builder: (context, state) {
        // Phần còn lại của builder...
        debugPrint('Edit screen: Building UI with state: ${state.status}');

        return Scaffold(
          appBar: AppBar(
            title: Text('Chỉnh sửa Prompt'),
            actions: [
              if (_isSubmitting) // Hiển thị loading indicator ở app bar
                const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else // Hiển thị nút save khi không loading
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _savePrompt,
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề',
                    border: OutlineInputBorder(),
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
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
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
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung Prompt',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập nội dung prompt';
                    }
                    if (value.trim().length < 10) {
                      return 'Nội dung prompt phải có ít nhất 10 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Danh mục',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    final color = Prompt.getCategoryColor(category);
                    return InkWell(
                      onTap: () => _selectCategory(category),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? color.withOpacity(0.5)
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? color : Colors.black54,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Hiển thị công khai'),
                  subtitle: const Text(
                      'Người khác có thể thấy và sử dụng prompt này'),
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _savePrompt,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Cập nhật Prompt'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
