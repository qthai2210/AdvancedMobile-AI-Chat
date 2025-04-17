import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_event.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_state.dart';
import 'package:aichatbot/data/models/assistant/assistant_model.dart';

class UpdateAssistantExample extends StatefulWidget {
  final AssistantModel assistant;

  const UpdateAssistantExample({
    Key? key,
    required this.assistant,
  }) : super(key: key);

  @override
  State<UpdateAssistantExample> createState() => _UpdateAssistantExampleState();
}

class _UpdateAssistantExampleState extends State<UpdateAssistantExample> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _instructionsController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current assistant data
    _nameController =
        TextEditingController(text: widget.assistant.assistantName);
    _instructionsController =
        TextEditingController(text: widget.assistant.instructions ?? '');
    _descriptionController =
        TextEditingController(text: widget.assistant.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateAssistant() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Dispatch the UpdateAssistantEvent to the BotBloc
    context.read<BotBloc>().add(
          UpdateAssistantEvent(
            assistantId: widget.assistant.id,
            assistantName: _nameController.text.trim(),
            instructions: _instructionsController.text.trim().isNotEmpty
                ? _instructionsController.text.trim()
                : null,
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Assistant'),
      ),
      body: BlocListener<BotBloc, BotState>(
        listener: (context, state) {
          // Handle the different states that can result from the update operation
          if (state is AssistantUpdating) {
            // Show loading state if needed
            setState(() => _isLoading = true);
          } else if (state is AssistantUpdated) {
            // Assistant was successfully updated
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Assistant updated successfully')),
            );
            Navigator.pop(context, state.assistant);
          } else if (state is AssistantUpdateFailed) {
            // Update failed
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Update failed: ${state.message}')),
            );
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Assistant Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an assistant name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _instructionsController,
                        decoration: const InputDecoration(
                          labelText: 'Instructions (Optional)',
                          border: OutlineInputBorder(),
                          hintText:
                              'Provide specific instructions for this assistant...',
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _updateAssistant,
                        child: const Text('Update Assistant'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
