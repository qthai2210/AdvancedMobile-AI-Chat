import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/models/ai_bot_model.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_event.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_state.dart';

import 'package:aichatbot/widgets/bots/bot_list_item.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;
import 'package:aichatbot/core/di/injection_container.dart';

/// A screen that displays and manages a list of AI bots.
///
/// This screen allows users to:
/// * View a list of existing AI bots
/// * Search for specific bots
/// * Create new bots
/// * Edit existing bots
/// * Delete bots
/// * Share bots across different platforms
class BotListScreen extends StatefulWidget {
  const BotListScreen({super.key});

  @override
  State<BotListScreen> createState() => _BotListScreenState();
}

/// State class for [BotListScreen] that manages the UI and bot data.
class _BotListScreenState extends State<BotListScreen> {
  /// Controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  /// Controller for list scrolling
  final ScrollController _scrollController = ScrollController();

  /// Current search query entered by the user
  String _searchQuery = '';

  /// Track if we're currently creating an assistant
  bool _isCreatingAssistant = false;

  /// Track if we're currently deleting an assistant
  bool _isDeletingAssistant = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // We'll fetch assistants in the build method using BlocProvider instead of directly here
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Converts an AssistantModel to an AIBot model
  AIBot _convertToAIBot(AssistantModel assistant) {
    // Create a consistent color and icon based on the assistant ID
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo
    ];

    final icons = [
      Icons.smart_toy,
      Icons.support_agent,
      Icons.people,
      Icons.shopping_cart,
      Icons.school,
      Icons.code,
      Icons.medical_services
    ];

    // Use a hash of the ID to determine the color and icon
    final colorIndex = assistant.id.hashCode.abs() % colors.length;
    final iconIndex = assistant.id.hashCode.abs() % icons.length;

    return AIBot(
      id: assistant.id,
      name: assistant.assistantName,
      description: assistant.description ?? 'No description available',
      iconData: icons[iconIndex],
      color: colors[colorIndex],
      createdAt: assistant.createdAt ?? DateTime.now(),
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Load more when 80% scrolled
    if (currentScroll >= maxScroll * 0.8) {
      final botState = context.read<BotBloc>().state;

      if (botState is BotsLoaded && botState.hasMore) {
        context.read<BotBloc>().add(
              FetchMoreBotsEvent(
                offset: botState.offset + botState.bots.length,
                searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
              ),
            );
      }
    }
  }

  /// Builds an empty state widget shown when no bots are available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No assistants available yet'
                : 'No assistants match your search',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty)
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Clear Search'),
            )
          else
            ElevatedButton.icon(
              onPressed: _navigateToCreateBot,
              icon: const Icon(Icons.add),
              label: const Text('Create Assistant'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Navigates to the bot creation screen and handles the result.
  ///
  /// If a new bot is created, refreshes the bot list.
  Future<void> _navigateToCreateBot() async {
    // Set creating flag to true
    setState(() {
      _isCreatingAssistant = true;
    });

    try {
      // Navigate to create assistant screen using GoRouter
      await context.pushNamed('createAssistant');

      // The refresh will happen when we return to this screen
      context.read<BotBloc>().add(const RefreshBotsEvent());
    } finally {
      // Set creating flag to false when we return
      setState(() {
        _isCreatingAssistant = false;
      });
    }
  }

  /// Shows a dialog to create a new assistant directly from this screen
  void _showCreateAssistantDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final instructionsController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<BotBloc>(),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Create New Assistant',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                      color: Colors.grey,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    child: _buildCreateAssistantForm(
                      nameController,
                      descriptionController,
                      instructionsController,
                      dialogContext,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Validate that name is not empty
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.warning_amber,
                                      color: Colors.white),
                                  SizedBox(width: 16),
                                  Text('Assistant name cannot be empty'),
                                ],
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // Set creating flag to true
                        setState(() {
                          _isCreatingAssistant = true;
                        });

                        // Dispatch the create event
                        BlocProvider.of<BotBloc>(dialogContext).add(
                          CreateAssistantEvent(
                            assistantName: name,
                            description:
                                descriptionController.text.trim().isNotEmpty
                                    ? descriptionController.text.trim()
                                    : null,
                            instructions:
                                instructionsController.text.trim().isNotEmpty
                                    ? instructionsController.text.trim()
                                    : null,
                          ),
                        );

                        // Close the dialog
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 8),
                          Text('CREATE'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a form for creating a new assistant
  Widget _buildCreateAssistantForm(
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController instructionsController,
    BuildContext dialogContext,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assistant name field
            TextField(
              controller: nameController,
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
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),

            // Description field
            TextField(
              controller: descriptionController,
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
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),

            // Instructions field
            TextField(
              controller: instructionsController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Instructions (Optional)',
                hintText: 'Enter specific instructions for the assistant',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 100),
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
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to the bot detail screen for editing.
  ///
  /// If the bot is updated, refreshes the bot list.
  void _editBot(AIBot bot) async {
    // Find the original AssistantModel for this bot
    final state = context.read<BotBloc>().state;
    if (state is BotsLoaded) {
      final assistantModel = state.bots.firstWhere(
        (assistant) => assistant.id == bot.id,
        orElse: () => throw Exception('Assistant not found'),
      );

      // Create controllers outside the dialog to avoid rebuilding them
      final nameController =
          TextEditingController(text: assistantModel.assistantName);
      final descriptionController =
          TextEditingController(text: assistantModel.description ?? '');
      final instructionsController =
          TextEditingController(text: assistantModel.instructions ?? '');

      // Show a dialog to edit the assistant
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BlocProvider.value(
          value: context.read<BotBloc>(),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Edit ${bot.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                        color: Colors.grey,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Divider(),
                  Flexible(
                    child: SingleChildScrollView(
                      child: _buildEditAssistantForm(
                        assistantModel,
                        nameController,
                        descriptionController,
                        instructionsController,
                        dialogContext,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('CANCEL'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Validate that name is not empty
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.warning_amber,
                                        color: Colors.white),
                                    SizedBox(width: 16),
                                    Text('Assistant name cannot be empty'),
                                  ],
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          // Dispatch the update event
                          BlocProvider.of<BotBloc>(dialogContext).add(
                            UpdateAssistantEvent(
                              assistantId: assistantModel.id,
                              assistantName: name,
                              description:
                                  descriptionController.text.trim().isNotEmpty
                                      ? descriptionController.text.trim()
                                      : null,
                              instructions:
                                  instructionsController.text.trim().isNotEmpty
                                      ? instructionsController.text.trim()
                                      : null,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save, size: 20),
                            SizedBox(width: 8),
                            Text('UPDATE'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot edit assistant right now')),
      );
    }
  }

  /// Builds a form for editing an assistant's properties
  Widget _buildEditAssistantForm(
    AssistantModel assistant,
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController instructionsController,
    BuildContext dialogContext,
  ) {
    return BlocListener<BotBloc, BotState>(
      listener: (context, state) {
        if (state is AssistantUpdating) {
          // Show loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Updating assistant...'),
                ],
              ),
              duration: Duration(seconds: 1),
            ),
          );
        } else if (state is AssistantUpdated) {
          // Close the dialog when update is successful
          Navigator.of(dialogContext).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                        '${state.assistant.assistantName} updated successfully'),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade700,
            ),
          );

          // Refresh the list
          context.read<BotBloc>().add(RefreshBotsEvent(
                searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
              ));
        } else if (state is AssistantUpdateFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('Update failed: ${state.message}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assistant name field
              TextField(
                controller: nameController,
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
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 20),

              // Description field
              TextField(
                controller: descriptionController,
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
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 20),

              // Instructions field
              TextField(
                controller: instructionsController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Instructions (Optional)',
                  hintText: 'Enter specific instructions for the assistant',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 100),
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
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles deleting a bot after confirmation.
  void _deleteBot(AIBot bot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assistant'),
        content: Text('Are you sure you want to delete "${bot.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Set deleting flag to true
              setState(() {
                _isDeletingAssistant = true;
              });
              // Dispatch the DeleteAssistantEvent to delete the assistant
              context.read<BotBloc>().add(DeleteAssistantEvent(
                    assistantId: bot.id,
                  ));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  /// Navigates to the chat screen to chat with the selected bot.
  void _chatWithBot(AIBot bot) {
    // In a real app, navigate to chat screen with this bot
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chat with ${bot.name}')),
    );
  }

  /// Updates the search query and triggers a search.
  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });

    // Trigger a search with the new query
    context.read<BotBloc>().add(FetchBotsEvent(
          searchQuery: query.isNotEmpty ? query : null,
        ));
  }

  /// Clears the search input and resets the search results.
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });

    // Reset search by fetching all bots
    context.read<BotBloc>().add(const FetchBotsEvent());
  }

  /// Builds the scrollable list of AI bots using data from BotBloc.
  ///
  /// Returns a BlocBuilder that handles different states of the bot list.
  Widget _buildBotList() {
    return BlocBuilder<BotBloc, BotState>(
      builder: (context, state) {
        if (state is BotInitial) {
          // Trigger initial load if not already done
          context.read<BotBloc>().add(FetchBotsEvent(
              searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null));
          return const Center(child: CircularProgressIndicator());
        } else if (state is BotsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BotsLoaded || state is BotsLoadingMore) {
          // Get the list of assistants to display
          final assistants = state is BotsLoaded
              ? state.bots
              : (state as BotsLoadingMore).bots;

          if (assistants.isEmpty) {
            return _buildEmptyState();
          }

          // Convert API assistant models to AIBot models for UI
          final bots = assistants.map(_convertToAIBot).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BotBloc>().add(RefreshBotsEvent(
                    searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
                  ));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
              itemCount: bots.length + (state is BotsLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == bots.length) {
                  // Show loading indicator at the end while loading more
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final bot = bots[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BotListItem(
                    bot: bot,
                    onEdit: () => _editBot(bot),
                    onChat: () => _chatWithBot(bot),
                    onDelete: () => _deleteBot(bot),
                  ),
                );
              },
            ),
          );
        } else if (state is BotsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading assistants: ${state.message}',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<BotBloc>().add(const FetchBotsEvent());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('Unknown state'));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create a new BotBloc instance for this screen
    return BlocProvider<BotBloc>(
      create: (context) {
        // Get a fresh instance of BotBloc from the dependency injection container
        final bloc = sl.get<BotBloc>();
        // Immediately fetch bots when the bloc is created
        bloc.add(FetchBotsEvent(
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        ));
        return bloc;
      },
      child: BlocListener<BotBloc, BotState>(
        listener: (context, state) {
          // Handle assistant deletion states
          if (state is AssistantDeleting) {
            // Show loading indicator for deletion
            // We're already using _isDeletingAssistant flag in the UI
            setState(() {
              _isDeletingAssistant = true;
            });
          } else if (state is AssistantDeleted) {
            // Reset deleting flag
            setState(() {
              _isDeletingAssistant = false;
            });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text('Assistant deleted successfully'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
              ),
            );

            // Refresh the assistants list after deletion - already handled in BotBloc
          } else if (state is AssistantDeleteFailed) {
            // Reset deleting flag
            setState(() {
              _isDeletingAssistant = false;
            });

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('Delete failed: ${state.message}'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }

          // Handle assistant creation states
          if (state is AssistantCreating) {
            // Show loading indicator for creation
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(
            //     content: Row(
            //       children: [
            //         SizedBox(
            //           width: 20,
            //           height: 20,
            //           child: CircularProgressIndicator(
            //             strokeWidth: 2,
            //             color: Colors.white,
            //           ),
            //         ),
            //         SizedBox(width: 16),
            //         Text('Creating assistant...'),
            //       ],
            //     ),
            //     duration: Duration(seconds: 2),
            //   ),
            // );

            setState(() {
              _isCreatingAssistant = true;
            });
          } else if (state is AssistantCreated) {
            // Reset creating flag
            setState(() {
              _isCreatingAssistant = false;
            });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                          '${state.assistant.assistantName} created successfully'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
              ),
            );

            // Refresh the list
            context.read<BotBloc>().add(const RefreshBotsEvent());
          } else if (state is AssistantCreationFailed) {
            // Reset creating flag
            setState(() {
              _isCreatingAssistant = false;
            });

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('Creation failed: ${state.message}'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('AI Assistants'),
            actions: [
              // Only show the add button if we're not currently creating an assistant
              if (!_isCreatingAssistant)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showCreateAssistantDialog,
                  tooltip: 'Create New Assistant',
                ),
            ],
          ),
          drawer: MainAppDrawer(
            currentIndex: 4, // Index for "Bots" tab
            onTabSelected: (index) => navigation_utils
                .handleDrawerNavigation(context, index, currentIndex: 4),
          ),
          body: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search assistants...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: _updateSearchQuery,
                ),
              ),
              // Bot list
              Expanded(
                child: _buildBotList(),
              ),
            ],
          ),
          floatingActionButton: _isCreatingAssistant
              ? const FloatingActionButton(
                  onPressed: null,
                  backgroundColor: Colors.grey,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : FloatingActionButton.extended(
                  onPressed: _navigateToCreateBot,
                  icon: const Icon(Icons.add),
                  label: const Text('New Assistant'),
                ),
        ),
      ),
    );
  }
}
