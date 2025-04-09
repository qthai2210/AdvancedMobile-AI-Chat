import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_state.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';

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

  // Danh sách các category
  final List<String> _categories = [
    'writing',
    'coding',
    'business',
    'marketing',
    'education',
    'creative',
    'personal',
    'career',
    'chatbot',
    'fun',
    'productivity',
    'seo',
    'other'
  ];

  @override
  void initState() {
    super.initState();
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
    return BlocListener<PromptBloc, PromptState>(
      listener: (context, state) {
        if (state.status == PromptStatus.loading && _isSubmitting) {
          // Show loading indicator
        } else if (state.status == PromptStatus.success &&
            state.newPrompt != null) {
          // Reset submission flag
          _isSubmitting = false;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prompt created successfully!')),
          );

          // Navigate back to prompts screen
          Navigator.of(context).pop(true); // Return true to indicate success
        } else if (state.status == PromptStatus.failure && _isSubmitting) {
          // Reset submission flag
          _isSubmitting = false;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Error: ${state.errorMessage ?? "Failed to create prompt"}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create New Prompt'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    hintText: 'Enter a title for your prompt',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    hintText: 'Enter a short description',
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category.capitalize()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Make this prompt public'),
                  subtitle:
                      const Text('Public prompts can be seen by other users'),
                  value: _isPublic,
                  onChanged: (bool value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prompt Content',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your prompt content here...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter prompt content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<PromptBloc, PromptState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state.status == PromptStatus.loading
                          ? null
                          : _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child:
                          state.status == PromptStatus.loading && _isSubmitting
                              ? const CircularProgressIndicator()
                              : const Text('Create Prompt'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (!authState.status.isSuccess || authState.user?.accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to create prompts')),
        );
        return;
      }

      _isSubmitting = true;

      context.read<PromptBloc>().add(
            CreatePrompt(
              accessToken: authState.user!.accessToken!,
              title: _titleController.text,
              content: _contentController.text,
              description: _descriptionController.text,
              category: _selectedCategory,
              isPublic: _isPublic,
              language: 'English', // Default language
            ),
          );
    }
  }
}

// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
