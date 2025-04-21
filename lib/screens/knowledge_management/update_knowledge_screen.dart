import 'package:aichatbot/models/knowledge_base_model.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values
    _nameController = TextEditingController(text: widget.knowledgeBase.name);
    _descriptionController =
        TextEditingController(text: widget.knowledgeBase.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
              //xJarvisGuid: widget.knowledgeBase.xJarvisGuid,
            ),
          );

      // Delay a bit to show loading indicator
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context, true); // Return success
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật Cơ sở kiến thức'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên cơ sở kiến thức',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên cơ sở kiến thức';
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
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _updateKnowledge,
                        child: const Text('Cập nhật'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
