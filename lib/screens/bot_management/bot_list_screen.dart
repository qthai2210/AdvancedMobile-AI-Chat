import 'package:aichatbot/utils/logger.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/models/ai_bot_model.dart';
import 'package:aichatbot/models/ai_agent_model.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_event.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_state.dart';

import 'package:aichatbot/widgets/bots/bot_list_item.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;

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

  /// Selected bot for detail views (needed for onTap functionality)
  AIBot? _selectedBot;

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
  // Removed unused _buildCreateAssistantForm method

  /// Navigates to the bot detail screen for editing.
  ///
  /// If the bot is updated, refreshes the bot list.
  void _editBot(AIBot bot) async {
    // Find the original AssistantModel for this bot
    final state = context.read<BotBloc>().state;
    if (state is BotsLoaded) {
      try {
        final assistantModel = state.bots.firstWhere(
          (assistant) => assistant.id == bot.id,
        );

        // Navigate to the edit screen using GoRouter
        await context.pushNamed(
          'editAssistant',
          pathParameters: {'botId': bot.id},
          extra: {
            'bot': bot,
            'assistantModel': assistantModel,
          },
        );

        // Refresh the list when returning from the edit screen
        if (context.mounted) {
          context.read<BotBloc>().add(RefreshBotsEvent(
                searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
              ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assistant not found')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot edit assistant right now')),
      );
    }
  }
  // Method removed - Using BotEditScreen instead

  /// Handles deleting a bot after confirmation.
  void _deleteBot(AIBot bot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assistant'),
        content: Text('Are you sure you want to delete "${bot.name}"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
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
    // Create a custom AIAgent from this bot
    final customAgent = AIAgent(
      id: bot.id,
      name: bot.name,
      description: bot.description,
      color: bot.color,
      isCustom: true, // Mark as custom assistant
    );

    // Navigate to chat detail screen with this bot
    context.pushNamed(
      'chatDetail',
      pathParameters: {'threadId': 'new'},
      extra: {
        'initialAgent': customAgent,
      },
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
          AppLogger.e(
              'Loaded ${assistants.length} assistants with query: $_searchQuery');
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
                    isSelected: bot.id == _selectedBot?.id,
                    onTap: () {
                      setState(() {
                        _selectedBot =
                            bot; // Find the corresponding AssistantModel if needed for future use
                        // AssistantModel lookup removed as it was unused
                      });
                    },
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
  // Knowledge tab functionality moved to BotEditScreen
  // Knowledge base management functionality moved to BotEditScreen
  // Preview functionality moved to BotEditScreen
  // Chat functionality moved to BotEditScreen

  @override
  Widget build(BuildContext context) {
    // Get the BotBloc from the context
    final botBloc = context.read<BotBloc>();

    // Trigger bot fetch with current search query
    botBloc.add(FetchBotsEvent(
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
    ));
    return BlocProvider<BotBloc>.value(
      value: botBloc,
      child: BlocListener<BotBloc, BotState>(
        listener: (context, state) {
          // Handle assistant deletion states
          if (state is AssistantDeleting) {
            // Show loading indicator for deletion

            // We're already using _isDeletingAssistant flag in the UI
            AppLogger.e('Deleting assistant...111');
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
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            centerTitle: false,
            title: Text(
              'AI Assistants',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            iconTheme:
                IconThemeData(color: Theme.of(context).colorScheme.primary),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: 'Help',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help coming soon')),
                  );
                },
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
              // Bot list (full screen width)
              Expanded(
                child: Stack(
                  children: [
                    _buildBotList(),
                    if (_isDeletingAssistant)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              constraints: const BoxConstraints(maxWidth: 350),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Custom animated progress indicator
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "Deleting Assistant",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Please wait while we process your request",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
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
