// Implements a tabbed interface for bot editing with three main sections:
// 1. Details Tab: Edit basic info like name, description, and instructions
// 2. Knowledge Tab: Link and manage knowledge bases for this bot
// 3. Chat Settings Tab: Configure model parameters and chat behavior

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:aichatbot/data/models/chat/assistant_message_chunk.dart';
import 'package:aichatbot/data/datasources/remote/ai_assistant_ask_api_service.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/models/ai_agent_model.dart';
import 'package:aichatbot/models/ai_bot_model.dart';
import 'package:aichatbot/models/message_model.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_event.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_state.dart';
// import 'package:aichatbot/presentation/bloc/chat/chat_bloc.dart';  // Currently unused
// import 'package:aichatbot/presentation/bloc/chat/chat_event.dart';  // Currently unused
// import 'package:aichatbot/presentation/bloc/chat/chat_state.dart';  // Currently unused
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_event.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_state.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/core/services/bloc_manager.dart';
import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/widgets/chat/chat_message_list.dart';
// import 'package:aichatbot/widgets/chat/chat_input_field.dart';  // Currently unused
import 'package:aichatbot/widgets/knowledge/knowledge_base_selector_dialog.dart';
// import 'package:aichatbot/data/models/chat/message_request_model.dart';  // Removed to fix conflict
// import 'package:aichatbot/domain/entities/prompt.dart';  // Currently unused
import 'bot_details_tab.dart';

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
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _instructionsController = TextEditingController();
  TextEditingController _telegramBotTokenController = TextEditingController();
  TextEditingController _slackBotTokenController = TextEditingController();
  TextEditingController _slackClientIdController = TextEditingController();
  TextEditingController _slackClientSecretController = TextEditingController();
  TextEditingController _slackSigningSecretController = TextEditingController();
  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isPublishingToTelegram = false;
  bool _isValidatingTelegramBot = false;
  bool _isValidatingSlackBot = false;
  bool _isPublishingToSlack = false;
  String? _telegramBotUrl;
  String? _slackBotUrl;
  Map<String, dynamic>? _validatedBotInfo;
  Map<String, dynamic>? _validatedSlackBotInfo; // Preview chat variables
  final TextEditingController _chatInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _chatMessages = [];
  bool _isSendingMessage =
      false; // Used in _sendMessage to track message sending state
  bool _isPromptMenuOpen =
      false; // Controls prompt suggestion dropdown visibility

  // API service for the AI Assistant Ask endpoint
  final AiAssistantAskApiService _assistantAskService =
      AiAssistantAskApiService();

  // OpenAI thread ID for conversation tracking (would typically come from a backend)
  final String _openAiThreadId =
      'thread_${DateTime.now().millisecondsSinceEpoch}';
  @override
  void initState() {
    super.initState();

    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);

    // Set initial values for text controllers
    _nameController.text = widget.assistantModel.assistantName;
    _descriptionController.text = widget.assistantModel.description ?? '';
    _instructionsController.text = widget.assistantModel.instructions ?? '';

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

    // Setup chat input listener for prompt detection
    _chatInputController.addListener(
        _onChatInputChanged); // Add welcome message to preview chat
    _chatMessages.add(
      Message(
        text:
            'Welcome to the chat preview! This is where you can test your assistant before deploying it.',
        isUser: false,
        timestamp: DateTime.now(),
        agent: AIAgent(
          id: widget.bot.id,
          name: widget.bot.name,
          description: widget.bot.description,
          color: widget.bot.color,
          isCustom: true,
        ),
      ),
    );

    // Fetch available prompts for the prompt menu
    try {
      context.read<PromptBloc>().add(const FetchPrompts(accessToken: ''));
    } catch (e) {
      // If we can't fetch prompts in the initState, we'll do it when the user opens the prompt menu
      print('Failed to load prompts: $e');
    }

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
    _slackBotTokenController.dispose();
    _slackClientIdController.dispose();
    _slackClientSecretController.dispose();
    _slackSigningSecretController.dispose();
    _chatInputController.dispose();
    _scrollController.dispose();
    _assistantAskService.dispose(); // Dispose the API service
    super.dispose();
  }

  void _onChatInputChanged() {
    final text = _chatInputController.text;
    if (text.startsWith('/') && !_isPromptMenuOpen) {
      setState(() {
        _isPromptMenuOpen = true;
      });
      // Fetch prompts with the query string
      final promptBloc = sl<PromptBloc>();
      promptBloc.add(FetchPrompts(
          accessToken:
              '', // This will need to be adjusted based on your app's auth
          query: text.substring(1)));
    } else if (!text.startsWith('/') && _isPromptMenuOpen) {
      setState(() {
        _isPromptMenuOpen = false;
      });
    }
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

  // Method to validate Slack bot configuration
  void _validateSlackBot() {
    final botToken = _slackBotTokenController.text.trim();
    final clientId = _slackClientIdController.text.trim();
    final clientSecret = _slackClientSecretController.text.trim();
    final signingSecret = _slackSigningSecretController.text.trim();

    // Validate input fields
    if (botToken.isEmpty ||
        clientId.isEmpty ||
        clientSecret.isEmpty ||
        signingSecret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all Slack configuration fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isValidatingSlackBot = true;
    });

    // Dispatch the validation event to the BotBloc
    context.read<BotBloc>().add(
          ValidateSlackBotEvent(
            botToken: botToken,
            clientId: clientId,
            clientSecret: clientSecret,
            signingSecret: signingSecret,
          ),
        );
  }

  // Method to handle Slack bot publishing
  void _publishSlackBot() {
    // Check if we've already validated the bot configuration
    if (_validatedSlackBotInfo == null) {
      // If not validated yet, run validation first
      _validateSlackBot();
      return;
    }

    final botToken = _slackBotTokenController.text.trim();
    final clientId = _slackClientIdController.text.trim();
    final clientSecret = _slackClientSecretController.text.trim();
    final signingSecret = _slackSigningSecretController.text.trim();

    setState(() {
      _isPublishingToSlack = true;
    });

    // Dispatch the event to the BotBloc
    context.read<BotBloc>().add(
          PublishSlackBotEvent(
            assistantId: widget.assistantModel.id,
            botToken: botToken,
            clientId: clientId,
            clientSecret: clientSecret,
            signingSecret: signingSecret,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    // Try to get the BotBloc from the parent context first
    final botBloc = context.read<BotBloc>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<BotBloc>.value(
          value: botBloc,
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
              } else if (state is ValidatingSlackBot) {
                // Keep validating indicator
              } else if (state is SlackBotValidated) {
                setState(() {
                  _isValidatingSlackBot = false;
                  _validatedSlackBotInfo = state.botInfo;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Slack bot configuration validated successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else if (state is SlackBotValidationFailed) {
                setState(() => _isValidatingSlackBot = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Slack validation failed: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is PublishingSlackBot) {
                // Keep publishing indicator
              } else if (state is SlackBotPublished) {
                setState(() {
                  _isPublishingToSlack = false;
                  _slackBotUrl = state.slackBotUrl;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Slack bot published successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is SlackBotPublishFailed) {
                setState(() => _isPublishingToSlack = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Failed to publish Slack bot: ${state.message}'),
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
                Tab(icon: Icon(Icons.chat_bubble), text: 'Preview Chat'),
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
                    _buildPreviewChatTab(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return BotDetailsTab(
      bot: widget.bot,
      assistantModel: widget.assistantModel,
      nameController: _nameController,
      descriptionController: _descriptionController,
      instructionsController: _instructionsController,
      telegramBotTokenController: _telegramBotTokenController,
      slackBotTokenController: _slackBotTokenController,
      slackClientIdController: _slackClientIdController,
      slackClientSecretController: _slackClientSecretController,
      slackSigningSecretController: _slackSigningSecretController,
      isValidatingTelegramBot: _isValidatingTelegramBot,
      isPublishingToTelegram: _isPublishingToTelegram,
      isValidatingSlackBot: _isValidatingSlackBot,
      validatedBotInfo: _validatedBotInfo,
      validatedSlackBotInfo: _validatedSlackBotInfo,
      telegramBotUrl: _telegramBotUrl,
      validateTelegramBot: _validateTelegramBot,
      publishTelegramBot: _publishTelegramBot,
      validateSlackBot: _validateSlackBot,
      isPublishingToSlack: _isPublishingToSlack,
      slackBotUrl: _slackBotUrl,
      publishSlackBot: _publishSlackBot,
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

  Widget _buildPreviewChatTab() {
    return Column(
      children: [
        // Chat messages area
        Expanded(
          child: ChatMessageList(
            messages: _chatMessages,
            scrollController: _scrollController,
          ),
        ),

        // Prompt suggestions area (shown when "/" is typed)
        if (_isPromptMenuOpen)
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: BlocBuilder<PromptBloc, PromptState>(
              builder: (context, state) {
                if (state.status == PromptStatus.loading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state.status == PromptStatus.success &&
                    state.prompts != null &&
                    state.prompts!.isNotEmpty) {
                  return SizedBox(
                    height: 200,
                    child: ListView.separated(
                      itemCount: state.prompts!.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final prompt = state.prompts![index];
                        return ListTile(
                          title: Text(prompt.title),
                          subtitle: Text(
                            prompt.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            setState(() {
                              _chatInputController.text = prompt.content;
                              _chatInputController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: _chatInputController.text.length),
                              );
                              _isPromptMenuOpen = false;
                            });
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No prompts found')),
                  );
                }
              },
            ),
          ), // Typing indicator when message is being sent
        if (_isSendingMessage)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  "Bot is typing...",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

        // Chat input
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // New conversation button
              IconButton(
                icon: const Icon(Icons.add_comment),
                tooltip: 'New Conversation',
                onPressed: () {
                  setState(() {
                    _chatMessages.clear();
                    _chatMessages.add(
                      Message(
                        text:
                            'Welcome to a new conversation! How can I help you today?',
                        isUser: false,
                        timestamp: DateTime.now(),
                        // Convert AIBot to AIAgent for the agent parameter
                        agent: AIAgent(
                          id: widget.bot.id,
                          name: widget.bot.name,
                          description: widget.bot.description,
                          color: widget.bot.color,
                          isCustom: true,
                        ),
                      ),
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Started a new conversation')),
                  );
                },
              ),

              // Prompt button
              IconButton(
                icon: const Icon(Icons.psychology_outlined),
                tooltip: 'Browse Prompts',
                onPressed: () {
                  _showPromptSelector(context);
                },
              ),

              // Text field
              Expanded(
                child: TextField(
                  controller: _chatInputController,
                  decoration: InputDecoration(
                    hintText: 'Type a message or / for prompts...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: _sendMessage,
                ),
              ),

              // Send button
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () => _sendMessage(_chatInputController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Shows the prompt selector dialog
  void _showPromptSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider<PromptBloc>.value(
          value: sl<PromptBloc>(),
          child: BlocBuilder<PromptBloc, PromptState>(
            builder: (context, state) {
              return AlertDialog(
                title: const Text('Select Prompt'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: state.status == PromptStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : state.status == PromptStatus.success &&
                              state.prompts != null &&
                              state.prompts!.isNotEmpty
                          ? ListView.builder(
                              itemCount: state.prompts!.length,
                              itemBuilder: (context, index) {
                                final prompt = state.prompts![index];
                                return ListTile(
                                  title: Text(prompt.title),
                                  subtitle: Text(
                                    prompt.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _chatInputController.text =
                                          prompt.content;
                                      _chatInputController.selection =
                                          TextSelection.fromPosition(
                                        TextPosition(
                                            offset: _chatInputController
                                                .text.length),
                                      );
                                    });
                                  },
                                );
                              },
                            )
                          : const Center(child: Text('No prompts available')),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Handle sending a message
  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      // Add user message
      _chatMessages.add(
        Message(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );

      // Clear input
      _chatInputController.clear();

      // Show typing indicator
      _isSendingMessage = true;
    }); // Create a temporary buffer for storing message chunks
    String responseBuffer = '';

    // Tag for the partial response message
    final String partialResponseTag =
        'partial_response_${DateTime.now().millisecondsSinceEpoch}';

    // Use the AI Assistant Ask API to get a real response
    _assistantAskService
        .askAssistant(
      assistantId: widget.assistantModel.id,
      message: message,
      openAiThreadId: _openAiThreadId,
      additionalInstruction: '',
      jarvisGuid: null,
    )
        .listen(
      // Handle each message chunk as it arrives
      (AssistantMessageChunk chunk) {
        responseBuffer += chunk.content;

        // Update UI to show streamed text as it arrives
        if (mounted) {
          setState(() {
            // Remove any previous partial response using the tag
            _chatMessages.removeWhere(
                (msg) => msg.text.startsWith('$partialResponseTag:'));

            // Add the updated response with a tag prefix that we'll remove later
            _chatMessages.add(
              Message(
                text: '$partialResponseTag:$responseBuffer',
                isUser: false,
                timestamp: DateTime.now(),
                agent: AIAgent(
                  id: widget.bot.id,
                  name: widget.bot.name,
                  description: widget.bot.description,
                  color: widget.bot.color,
                  isCustom: true,
                ),
              ),
            );
          });

          // Scroll to bottom to show new content
          _scrollToBottom();
        }
      },
      // Handle stream completion
      onDone: () {
        if (mounted) {
          setState(() {
            // Remove the partial message using the tag
            _chatMessages.removeWhere(
                (msg) => msg.text.startsWith('$partialResponseTag:'));

            // Add the final complete message
            _chatMessages.add(
              Message(
                text: responseBuffer,
                isUser: false,
                timestamp: DateTime.now(),
                agent: AIAgent(
                  id: widget.bot.id,
                  name: widget.bot.name,
                  description: widget.bot.description,
                  color: widget.bot.color,
                  isCustom: true,
                ),
              ),
            );

            // Hide the typing indicator
            _isSendingMessage = false;
          });

          // Final scroll to bottom
          _scrollToBottom();
        }
      }, // Handle any errors during streaming
      onError: (error) {
        AppLogger.e('Error from AI Assistant Ask API: $error');
        if (mounted) {
          setState(() {
            // Add error message to chat
            _chatMessages.add(
              Message(
                text:
                    "Sorry, there was an error processing your request. Please try again.",
                isUser: false,
                timestamp: DateTime.now(),
                agent: AIAgent(
                  id: widget.bot.id,
                  name: widget.bot.name,
                  description: widget.bot.description,
                  color: widget.bot.color,
                  isCustom: true,
                ),
              ),
            );

            // Hide typing indicator
            _isSendingMessage = false;
          });

          // Scroll to show error message
          _scrollToBottom();
        }
      },
    );
  }

  // Scroll to the bottom of the chat
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
