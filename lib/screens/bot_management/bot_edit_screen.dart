// Implements a tabbed interface for bot editing with three main sections:
// 1. Details Tab: Edit basic info like name, description, and instructions
// 2. Knowledge Tab: Link and manage knowledge bases for this bot
// 3. Chat Settings Tab: Configure model parameters and chat behavior

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:aichatbot/models/ai_bot_model.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_event.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_event.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_state.dart';
import 'package:aichatbot/core/services/bloc_manager.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/utils/secure_storage_util.dart';
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
  late TextEditingController _telegramBotTokenController;
  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isPublishingToTelegram = false;
  bool _isValidatingTelegramBot = false;
  String? _telegramBotUrl;
  Map<String, dynamic>? _validatedBotInfo;
  @override
  void initState() {
    super.initState();

    // Initialize tab controller
    _tabController = TabController(
        length: 3, vsync: this); // Initialize text controllers with bot data
    _nameController =
        TextEditingController(text: widget.assistantModel.assistantName);
    _descriptionController =
        TextEditingController(text: widget.assistantModel.description ?? '');
    _instructionsController =
        TextEditingController(text: widget.assistantModel.instructions ?? '');
    _telegramBotTokenController = TextEditingController();

    // Listen for changes to track if form is dirty
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _instructionsController.addListener(_onFieldChanged);

    // Reset validation state when token changes
    _telegramBotTokenController.addListener(() {
      if (_validatedBotInfo != null) {
        setState(() {
          _validatedBotInfo = null;
        });
      }
    });

    // Fetch the assistant's knowledge bases when the screen loads
    _fetchAssistantKnowledges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _telegramBotTokenController.dispose();
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
    final state = context.read<KnowledgeBloc>().state;

    // Get the IDs of knowledge bases already linked to this assistant
    List<String> linkedKnowledgeIds = [];
    if (state is KnowledgeLoaded) {
      linkedKnowledgeIds = state.knowledges
          .where((knowledge) => knowledge.id != null)
          .map((knowledge) => knowledge.id!)
          .toList();
    }

    // Show dialog with list of all available knowledge bases
    showDialog(
      context: context,
      builder: (context) {
        return KnowledgeBaseSelectorDialog(
          // Don't pass assistantId to show all available knowledge bases
          // Pass the list of already linked knowledge base IDs to exclude them
          excludeKnowledgeIds: linkedKnowledgeIds,
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

  /// Fetch knowledge bases attached to this assistant
  void _fetchAssistantKnowledges() {
    sl<KnowledgeBloc>().add(
      FetchAssistantKnowledgesEvent(
        assistantId: widget.assistantModel.id,
        limit: 50,
      ),
    );
  }

  /// Shows a confirmation dialog and removes the knowledge base from the assistant if confirmed
  void _confirmRemoveKnowledge(KnowledgeModel knowledge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove "${knowledge.knowledgeName}"?'),
        content: Text(
            'Are you sure you want to remove this knowledge base from the assistant? '
            'This action does not delete the knowledge base itself.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeKnowledgeFromAssistant(knowledge);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  /// Removes a knowledge base from the assistant
  void _removeKnowledgeFromAssistant(KnowledgeModel knowledge) {
    // Get assistant ID and knowledge ID
    final assistantId = widget.assistantModel.id;
    final knowledgeId = knowledge.id;

    // Check if both IDs are available (and not empty)
    if (assistantId.isNotEmpty && knowledgeId != null) {
      context.read<BotBloc>().add(
            RemoveKnowledgeFromAssistantEvent(
              assistantId: assistantId,
              knowledgeId: knowledgeId,
              xJarvisGuid: '', // Empty GUID is acceptable per the API
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removing knowledge base: ${knowledge.knowledgeName}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid assistant or knowledge ID'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to validate Telegram bot token
  void _validateTelegramBot() {
    final botToken = _telegramBotTokenController.text.trim();
    if (botToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Telegram bot token'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isValidatingTelegramBot = true;
    });

    // Dispatch the validation event to the BotBloc
    context.read<BotBloc>().add(
          ValidateTelegramBotEvent(
            botToken: botToken,
          ),
        );
  }

  // Method to handle Telegram bot publishing
  void _publishTelegramBot() {
    // Check if we've already validated the bot token
    if (_validatedBotInfo == null) {
      // If not validated yet, run validation first
      _validateTelegramBot();
      return;
    }

    final botToken = _telegramBotTokenController.text.trim();

    setState(() {
      _isPublishingToTelegram = true;
    });

    // Dispatch the event to the BotBloc
    context.read<BotBloc>().add(
          PublishTelegramBotEvent(
            assistantId: widget.assistantModel.id,
            botToken: botToken,
          ),
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
              } else if (state is ValidatingTelegramBot) {
                // Keep validating indicator
              } else if (state is TelegramBotValidated) {
                setState(() {
                  _isValidatingTelegramBot = false;
                  _validatedBotInfo = state.botInfo;
                }); // Show validation success message with bot info
                final botUsername = state.botInfo['username'] as String? ?? '';
                final botId = state.botInfo['id'].toString();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Telegram bot validated successfully: @$botUsername (ID: $botId)'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );

                // Automatically publish the bot after successful validation
                _publishTelegramBot();
              } else if (state is TelegramBotValidationFailed) {
                setState(() => _isValidatingTelegramBot = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bot validation failed: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is PublishingTelegramBot) {
                // Keep publishing indicator
              } else if (state is TelegramBotPublished) {
                setState(() {
                  _isPublishingToTelegram = false;
                  _telegramBotUrl = state.telegramBotUrl;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Telegram bot published successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is TelegramBotPublishFailed) {
                setState(() => _isPublishingToTelegram = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Failed to publish Telegram bot: ${state.message}'),
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

                // Refresh the list of knowledge bases after linking
                _fetchAssistantKnowledges();
              } else if (state is AssistantRemovingKnowledge) {
                // Show loading indicator or status if needed
              } else if (state is AssistantKnowledgeRemoved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Knowledge base removed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Refresh the list of knowledge bases after removal
                _fetchAssistantKnowledges();
              } else if (state is AssistantKnowledgeRemoveFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Failed to remove knowledge base: ${state.message}'),
                    backgroundColor: Colors.red,
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
          BlocListener<KnowledgeBloc, KnowledgeState>(
            listener: (context, state) {
              if (state is KnowledgeError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Knowledge base error: ${state.message}'),
                    backgroundColor: Colors.orange,
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
          const SizedBox(height: 24), // Telegram Bot Token field
          TextField(
            controller: _telegramBotTokenController,
            decoration: InputDecoration(
              labelText: 'Telegram Bot Token',
              hintText: 'Enter your Telegram bot token',
              prefixIcon: const Icon(Icons.telegram),
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
          const SizedBox(height: 16), // Show validation status if available
          if (_validatedBotInfo != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bot Successfully Validated',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // const Divider(height: 16),
                  // _buildBotInfoRow(
                  //     'Bot ID:', '${_validatedBotInfo!['id'] ?? 'Unknown'}'),
                  // _buildBotInfoRow('Username:',
                  //     '@${_validatedBotInfo!['username'] ?? 'Unknown'}'),
                  // _buildBotInfoRow('Display Name:',
                  //     '${_validatedBotInfo!['first_name'] ?? 'Unknown'}'),
                  // _buildBotInfoRow('Is Bot:',
                  //     _formatBoolValue(_validatedBotInfo!['is_bot'] as bool?)),
                  // _buildBotInfoRow(
                  //     'Can Join Groups:',
                  //     _formatBoolValue(
                  //         _validatedBotInfo!['can_join_groups'] as bool?)),
                  // _buildBotInfoRow(
                  //     'Read Group Messages:',
                  //     _formatBoolValue(
                  //         _validatedBotInfo!['can_read_all_group_messages']
                  //             as bool?)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Validate and Publish to Telegram button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_isValidatingTelegramBot || _isPublishingToTelegram)
                  ? null
                  : (_validatedBotInfo != null
                      ? _publishTelegramBot
                      : _validateTelegramBot),
              icon: const Icon(Icons.send),
              label: _isValidatingTelegramBot
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Validating...'),
                      ],
                    )
                  : _isPublishingToTelegram
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Publishing...'),
                          ],
                        )
                      : _validatedBotInfo != null
                          ? const Text('Publish to Telegram')
                          : const Text('Validate & Publish'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _validatedBotInfo != null ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: _validatedBotInfo != null ? 3 : 2,
              ),
            ),
          ), // Display Telegram bot URL if available
          if (_telegramBotUrl != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Telegram Bot Published Successfully',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Telegram Bot URL:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    _telegramBotUrl!,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Copy to clipboard
                          Clipboard.setData(
                              ClipboardData(text: _telegramBotUrl!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('URL copied to clipboard'),
                              duration: Duration(seconds: 1),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy URL'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Knowledge Bases',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh knowledge bases',
                onPressed: _fetchAssistantKnowledges,
              ),
            ],
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: BlocBuilder<KnowledgeBloc, KnowledgeState>(
        builder: (context, state) {
          if (state is KnowledgeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is KnowledgeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchAssistantKnowledges,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is KnowledgeLoaded && state.knowledges.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                _fetchAssistantKnowledges();
              },
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.knowledges.length,
                itemBuilder: (context, index) {
                  final knowledge = state.knowledges[index];
                  return ListTile(
                    leading: const Icon(Icons.auto_awesome),
                    title: Text(knowledge.knowledgeName),
                    subtitle: knowledge.description != null &&
                            knowledge.description!.isNotEmpty
                        ? Text(knowledge.description!)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            // Show knowledge details if needed
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _confirmRemoveKnowledge(knowledge),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            // No knowledge bases or initial state
            return ListView(
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
            );
          }
        },
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

  /// Helper method to build a row for displaying bot information
  Widget _buildBotInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to format boolean values for display
  String _formatBoolValue(bool? value) {
    if (value == null) return 'N/A';
    return value ? 'Yes' : 'No';
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
