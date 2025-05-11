// Implements a tabbed interface for bot editing with three main sections:
// 1. Details Tab: Edit basic info like name, description, and instructions
// 2. Knowledge Tab: Link and manage knowledge bases for this bot
// 3. Chat Settings Tab: Configure model parameters and chat behavior

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/models/ai_bot_model.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_event.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_state.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/core/services/bloc_manager.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/widgets/knowledge/knowledge_base_selector_dialog.dart';

/// A screen for editing bot details with a tabbed interface.
/// This screen allows users to:
/// * Edit basic bot properties
/// * Manage knowledge bases
/// * Configure chat settings
class BotEditScreen extends StatefulWidget {
  final AIBot bot;
  final AssistantModel assistantModel;

  const BotEditScreen({
    Key? key,
    required this.bot,
    required this.assistantModel,
  }) : super(key: key);

  @override
  State<BotEditScreen> createState() => _BotEditScreenState();
}

class _BotEditScreenState extends State<BotEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructionsController;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);

    // Initialize text controllers with bot data
    _nameController =
        TextEditingController(text: widget.assistantModel.assistantName);
    _descriptionController =
        TextEditingController(text: widget.assistantModel.description ?? '');
    _instructionsController =
        TextEditingController(text: widget.assistantModel.instructions ?? '');

    // Listen for changes to track if form is dirty
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _instructionsController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final nameChanged =
        _nameController.text != widget.assistantModel.assistantName;
    final descriptionChanged = _descriptionController.text !=
        (widget.assistantModel.description ?? '');
    final instructionsChanged = _instructionsController.text !=
        (widget.assistantModel.instructions ?? '');

    final newHasChanges =
        nameChanged || descriptionChanged || instructionsChanged;

    if (newHasChanges != _hasChanges) {
      setState(() {
        _hasChanges = newHasChanges;
      });
    }
  }

  void _saveChanges() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assistant name cannot be empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Dispatch the update event
    sl<BlocManager>().getBloc<BotBloc>(() => sl<BotBloc>()).add(
          UpdateAssistantEvent(
            assistantId: widget.assistantModel.id,
            assistantName: _nameController.text.trim(),
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            instructions: _instructionsController.text.trim().isNotEmpty
                ? _instructionsController.text.trim()
                : null,
          ),
        );
  }

  void _linkKnowledgeToAssistant() {
    // Show dialog with list of knowledge bases
    showDialog(
      context: context,
      builder: (context) {
        return KnowledgeBaseSelectorDialog(
          onKnowledgeSelected: (String knowledgeId, String knowledgeName) {
            // Dispatch the LinkKnowledgeToAssistantEvent
            context.read<BotBloc>().add(
                  LinkKnowledgeToAssistantEvent(
                    assistantId: widget.assistantModel.id,
                    knowledgeId: knowledgeId,
                    accessToken:
                        null, // Replace with actual auth token if needed
                  ),
                );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Linking knowledge base: $knowledgeName'),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BotBloc>.value(
          value: sl<BlocManager>().getBloc<BotBloc>(() => sl<BotBloc>()),
        ),
        BlocProvider<KnowledgeBloc>.value(
          value: sl<KnowledgeBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<BotBloc, BotState>(
            listener: (context, state) {
              if (state is AssistantUpdating) {
                // Keep loading indicator
              } else if (state is AssistantUpdated) {
                setState(() => _isLoading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${state.assistant.assistantName} updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Go back to previous screen
                if (context.mounted) context.pop();
              } else if (state is AssistantUpdateFailed) {
                setState(() => _isLoading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Update failed: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is AssistantKnowledgeLinked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Knowledge base linked successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is AssistantKnowledgeLinkFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Failed to link knowledge base: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text('Edit ${widget.bot.name}'),
            actions: [
              if (_hasChanges)
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Save Changes',
                  onPressed: _isLoading ? null : _saveChanges,
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.edit), text: 'Details'),
                Tab(icon: Icon(Icons.auto_awesome), text: 'Knowledge'),
                Tab(icon: Icon(Icons.chat_bubble), text: 'Chat Settings'),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDetailsTab(),
                    _buildKnowledgeTab(),
                    _buildChatSettingsTab(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot header with icon and color
          Center(
            child: Column(
              children: [
                Hero(
                  tag: 'bot-avatar-${widget.bot.id}',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: widget.bot.color.withOpacity(0.2),
                    child: Icon(
                      widget.bot.iconData,
                      color: widget.bot.color,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bot ID: ${widget.bot.id.substring(0, 8)}...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Name field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Assistant Name',
              hintText: 'Enter assistant name',
              prefixIcon: const Icon(Icons.smart_toy),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 24),

          // Description field
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Enter assistant description',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 64),
                child: Icon(Icons.description),
              ),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 24),

          // Instructions field
          TextField(
            controller: _instructionsController,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Instructions (Optional)',
              hintText: 'Enter specific instructions for the assistant',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 120),
                child: Icon(Icons.psychology),
              ),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 24),

          // Created date info
          Text(
            'Created on: ${_formatDate(widget.bot.createdAt)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.bot.color.withOpacity(0.2),
                radius: 24,
                child: Icon(widget.bot.iconData, color: widget.bot.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bot.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ID: ${widget.bot.id.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Knowledge Bases',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildKnowledgeBasesList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _linkKnowledgeToAssistant,
              icon: const Icon(Icons.add_link),
              label: const Text('Link Knowledge Base'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeBasesList() {
    // This would ideally display knowledge bases linked to this assistant
    // For now, we'll display a placeholder
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Link a knowledge base'),
            subtitle: const Text('No knowledge bases linked yet'),
            trailing: const Icon(Icons.add_circle_outline),
            onTap: _linkKnowledgeToAssistant,
          ),
        ],
      ),
    );
  }

  Widget _buildChatSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chat Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Model selection
          const Text(
            'AI Model',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GPT-4',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Most capable model',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Temperature setting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Temperature',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '0.7',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: 0.7,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '0.7',
            onChanged: (value) {
              // In a real app, you would save this value
            },
          ),
          const Text(
            'Lower values make responses more focused and deterministic. Higher values make responses more creative and varied.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // Response settings
          const Text(
            'Response Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Use streaming responses'),
            subtitle: const Text('Get responses as they are being generated'),
            value: true,
            onChanged: (bool value) {
              // In a real app, you would save this value
            },
          ),
          SwitchListTile(
            title: const Text('Include citations'),
            subtitle:
                const Text('Reference sources in responses when possible'),
            value: true,
            onChanged: (bool value) {
              // In a real app, you would save this value
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
