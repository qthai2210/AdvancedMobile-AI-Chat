import 'package:flutter/material.dart';
import 'package:aichatbot/models/prompt_model.dart';
import 'package:aichatbot/services/prompt_service.dart';

/// A screen for creating or editing AI chat prompts.
///
/// This screen allows users to:
/// * Create new custom prompts
/// * Edit existing prompts
/// * Add categories to prompts
/// * Use template tags for dynamic content
class CreatePromptScreen extends StatefulWidget {
  /// Optional prompt to edit. If null, creates a new prompt.
  final Prompt? editPrompt;

  const CreatePromptScreen({Key? key, this.editPrompt}) : super(key: key);

  @override
  State<CreatePromptScreen> createState() => _CreatePromptScreenState();
}

/// State management for [CreatePromptScreen].
/// Handles form input, validation, and prompt creation/editing.
class _CreatePromptScreenState extends State<CreatePromptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _selectedCategories = [];
  bool _isLoading = false;
  bool _isEditing = false;

  // Available categories
  final List<String> _allCategories = [
    'Writing',
    'Coding',
    'Business',
    'Marketing',
    'Education',
    'Creative',
    'Personal',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editPrompt != null;
    if (_isEditing) {
      _loadPromptData();
    }
  }

  /// Loads existing prompt data when in edit mode
  void _loadPromptData() {
    final prompt = widget.editPrompt!;
    _titleController.text = prompt.title;
    _descriptionController.text = prompt.description;
    _contentController.text = prompt.content;
    _selectedCategories.addAll(prompt.categories);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Saves the prompt data to storage
  ///
  /// Validates form input and creates/updates the prompt.
  /// Shows error messages if validation fails.
  Future<void> _savePrompt() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 danh mục')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Prompt prompt;

      if (_isEditing) {
        // Update existing prompt
        prompt = widget.editPrompt!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          content: _contentController.text.trim(),
          categories: List.from(_selectedCategories),
        );

        await PromptService.updatePrivatePrompt(prompt);
      } else {
        // Create new prompt
        prompt = await PromptService.createPrivatePrompt(
          _titleController.text.trim(),
          _contentController.text.trim(),
          _descriptionController.text.trim(),
          List.from(_selectedCategories),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Đã cập nhật prompt' : 'Đã tạo prompt mới',
            ),
          ),
        );
        Navigator.pop(context, prompt);
      }
    } catch (e) {
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

  /// Toggles selection of a category
  ///
  /// [category] The category to toggle selection state
  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh Sửa Prompt' : 'Tạo Prompt Mới'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleField(),
                        const SizedBox(height: 16),
                        _buildDescriptionField(),
                        const SizedBox(height: 24),
                        _buildCategorySelector(),
                        const SizedBox(height: 24),
                        _buildContentField(),
                        const SizedBox(height: 32),
                        _buildSaveButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  // UI Building Methods

  /// Builds the title input field with validation
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Tiêu đề *',
        hintText: 'Nhập tiêu đề cho prompt',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập tiêu đề';
        }
        return null;
      },
    );
  }

  /// Builds the description input field with validation
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Mô tả *',
        hintText: 'Mô tả ngắn gọn về prompt này',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập mô tả';
        }
        return null;
      },
    );
  }

  /// Builds the category selection chips
  ///
  /// Shows available categories and handles selection state
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh mục *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Chọn ít nhất 1 danh mục',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _allCategories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                final color = Prompt.getCategoryColor(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => _toggleCategory(category),
                  backgroundColor: Colors.grey[200],
                  selectedColor: color.withOpacity(0.2),
                  checkmarkColor: color,
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Builds the main prompt content input area
  ///
  /// Includes template tag buttons and a multi-line text input
  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nội dung prompt *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    _buildInsertTagButton('[name]'),
                    _buildInsertTagButton('[topic]'),
                    _buildInsertTagButton('[industry]'),
                    _buildInsertTagButton('[audience]'),
                  ],
                ),
              ),
              const Divider(height: 1),
              TextFormField(
                controller: _contentController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Nhập nội dung prompt ở đây...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập nội dung prompt';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Mẹo: Sử dụng các tag như [name], [topic] để tạo prompt template linh hoạt.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  /// Builds an insertable template tag button
  ///
  /// [tag] The template tag text to insert
  Widget _buildInsertTagButton(String tag) {
    return InkWell(
      onTap: () {
        final currentText = _contentController.text;
        final selection = _contentController.selection;

        // Check if selection is valid
        if (selection.baseOffset >= 0 && selection.extentOffset >= 0) {
          // Valid selection - insert at selection point
          final newText = currentText.replaceRange(
            selection.start,
            selection.end,
            tag,
          );

          _contentController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(
              offset: selection.start + tag.length,
            ),
          );
        } else {
          // No valid selection - append to end
          final newText = currentText + tag;
          _contentController.text = newText;

          // Place cursor after the inserted tag
          _contentController.selection = TextSelection.collapsed(
            offset: newText.length,
          );
        }
      },
      child: Chip(
        label: Text(tag, style: const TextStyle(fontSize: 12)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Builds the save/update button with loading state
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _savePrompt,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Text(_isEditing ? 'Cập nhật' : 'Lưu prompt'),
      ),
    );
  }
}
