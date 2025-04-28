import 'package:flutter/material.dart';
import 'package:aichatbot/models/ai_bot_model.dart';
import 'package:go_router/go_router.dart';

class CreateBotScreen extends StatefulWidget {
  final AIBot? editBot;

  const CreateBotScreen({super.key, this.editBot});

  @override
  State<CreateBotScreen> createState() => _CreateBotScreenState();
}

class _CreateBotScreenState extends State<CreateBotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _promptController = TextEditingController();

  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.smart_toy;
  bool _isLoading = false;
  bool _isEditing = false;

  // Available colors for bot
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  // Available icons for bot
  final List<IconData> _iconOptions = [
    Icons.smart_toy,
    Icons.support_agent,
    Icons.shopping_cart,
    Icons.school,
    Icons.health_and_safety,
    Icons.food_bank,
    Icons.home,
    Icons.sports_esports,
    Icons.code,
    Icons.psychology,
    Icons.translate,
    Icons.chat,
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editBot != null;

    if (_isEditing) {
      _loadBotData();
    }
  }

  void _loadBotData() {
    final bot = widget.editBot!;
    _nameController.text = bot.name;
    _descriptionController.text = bot.description;
    _selectedColor = bot.color;
    _selectedIcon = bot.iconData;

    if (bot.prompt != null) {
      _promptController.text = bot.prompt!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _saveBot() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create bot model
      final bot = AIBot(
        id: _isEditing
            ? widget.editBot!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        iconData: _selectedIcon,
        color: _selectedColor,
        prompt: _promptController.text.trim().isNotEmpty
            ? _promptController.text.trim()
            : null,
        createdAt: _isEditing ? widget.editBot!.createdAt : DateTime.now(),
        knowledgeBase: [],
      );

      // In a real app, you would save to database or API
      await Future.delayed(
          const Duration(milliseconds: 800)); // Simulate network delay

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEditing
                  ? 'Bot updated successfully'
                  : 'Bot created successfully')),
        );
        context.pop(bot);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteBot() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Bot'),
        content: const Text(
            'Bạn có chắc muốn xóa bot này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(
                  'delete'); // Return to previous screen with delete signal
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa AI BOT' : 'Tạo AI BOT mới'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteBot,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBasicInfoSection(),
                  const SizedBox(height: 20),
                  _buildAppearanceSection(),
                  const SizedBox(height: 20),
                  _buildPromptSection(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cơ bản',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên Bot *',
                hintText: 'Customer Support Bot',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên cho bot';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả *',
                hintText: 'Bot này sẽ hỗ trợ trả lời các câu hỏi về...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mô tả cho bot';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Giao diện',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Color selection
            const Text(
              'Chọn màu cho Bot',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildColorPicker(),

            const SizedBox(height: 20),

            // Icon selection
            const Text(
              'Chọn biểu tượng cho Bot',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildIconPicker(),

            const SizedBox(height: 20),

            // Preview
            const Text('Xem trước',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _selectedColor,
                    child: Icon(
                      _selectedIcon,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _nameController.text.isEmpty
                        ? 'AI Bot'
                        : _nameController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colorOptions.map((color) {
        final isSelected = color.value == _selectedColor.value;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconPicker() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: _iconOptions.length,
        itemBuilder: (context, index) {
          final icon = _iconOptions[index];
          final isSelected = icon.codePoint == _selectedIcon.codePoint;

          return GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? _selectedColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromptSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cài đặt Prompt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Định hình cách AI trả lời và cá nhân hóa bot của bạn',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _promptController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'You are a helpful assistant that specializes in...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 8),

            // Prompt template suggestions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPromptChip('Customer Support',
                    'You are a helpful customer support agent for a company that sells tech products...'),
                _buildPromptChip('HR Assistant',
                    'You are an HR assistant who helps employees with questions about company policies...'),
                _buildPromptChip('Sales Bot',
                    'You are a sales representative helping customers find the right product...'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String label, String promptText) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        setState(() {
          _promptController.text = promptText;
        });
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveBot,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        _isEditing ? 'Cập nhật Bot' : 'Tạo Bot',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
