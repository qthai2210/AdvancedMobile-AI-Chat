import 'package:aichatbot/models/knowledge_base_model.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_event.dart';
import 'package:aichatbot/widgets/knowledge/update_knowledge_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UpdateKnowledgeScreen extends StatefulWidget {
  final KnowledgeBase knowledgeBase;

  const UpdateKnowledgeScreen({
    Key? key,
    required this.knowledgeBase,
  }) : super(key: key);

  @override
  State<UpdateKnowledgeScreen> createState() => _UpdateKnowledgeScreenState();
}

class _UpdateKnowledgeScreenState extends State<UpdateKnowledgeScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values
    _nameController = TextEditingController(text: widget.knowledgeBase.name);
    _descriptionController =
        TextEditingController(text: widget.knowledgeBase.description);

    // Listen for changes to detect if form is modified
    _nameController.addListener(_checkChanges);
    _descriptionController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final nameChanged = _nameController.text != widget.knowledgeBase.name;
    final descriptionChanged =
        _descriptionController.text != widget.knowledgeBase.description;

    setState(() {
      _hasChanges = nameChanged || descriptionChanged;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hủy thay đổi?'),
            content: const Text(
                'Bạn đã thực hiện thay đổi. Bạn có chắc chắn muốn hủy không?'),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: const Text('Tiếp tục chỉnh sửa'),
              ),
              TextButton(
                onPressed: () => context.pop(true),
                child: const Text('Hủy thay đổi',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _updateKnowledge() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      context.read<KnowledgeBloc>().add(
            UpdateKnowledgeEvent(
              id: widget.knowledgeBase.id,
              knowledgeName: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
            ),
          );

      // Delay a bit to show loading indicator
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thành công!'),
              behavior: SnackBarBehavior.floating,
            ),
          );

          context.pop(true); // Return success
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cập nhật Cơ sở kiến thức'),
          elevation: 0,
          actions: [
            if (_hasChanges)
              IconButton(
                icon: const Icon(Icons.check),
                tooltip: 'Lưu thay đổi',
                onPressed: _updateKnowledge,
              ),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang cập nhật...'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: UpdateKnowledgeForm(
                    knowledgeBase: widget.knowledgeBase,
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    formKey: _formKey,
                    hasChanges: _hasChanges,
                  ),
                ),
        ),
        floatingActionButton: _hasChanges
            ? FloatingActionButton(
                onPressed: _updateKnowledge,
                tooltip: 'Lưu thay đổi',
                child: const Icon(Icons.save),
              )
            : null,
      ),
    );
  }
}
