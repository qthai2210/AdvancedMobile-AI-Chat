import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart' as di;
import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/models/ai_bot_model.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_event.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_state.dart';
import 'package:aichatbot/screens/create_bot_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

  /// This method is no longer needed as filtering is handled by the API
  /// through the BotBloc. Keeping this as a comment for reference.
  ///
  /// List<AIBot> get _filteredBots {
  ///   if (_searchQuery.isEmpty) return _bots;
  ///   return _bots
  ///       .where(
  ///         (bot) =>
  ///             bot.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
  ///             bot.description.toLowerCase().contains(
  ///                  _searchQuery.toLowerCase(),
  ///                ),
  ///       )
  ///       .toList();
  /// }

  /// Navigates to the bot creation screen and handles the result.
  ///
  /// If a new bot is created, refreshes the bot list.
  Future<void> _navigateToCreateBot() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateBotScreen()),
    );

    if (result != null && result is AIBot) {
      // Refresh the list to include the new bot
      context.read<BotBloc>().add(const RefreshBotsEvent());
    }
  }

  /// Navigates to the bot detail screen for editing.
  ///
  /// If the bot is updated, refreshes the bot list.
  void _editBot(AIBot bot) async {
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CreateBotScreen(
    //       editMode: true,
    //       bot: bot,
    //     ),
    //   ),
    // );

    // if (result != null && result is AIBot) {
    //   // Refresh the list to reflect the updated bot
    //   context.read<BotBloc>().add(const RefreshBotsEvent());
    // }
  }

  /// Handles deleting a bot after confirmation.
  void _deleteBot(AIBot bot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bot'),
        content: Text('Are you sure you want to delete "${bot.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, call the delete API here
              // For now we just refresh the list
              context.read<BotBloc>().add(const RefreshBotsEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${bot.name} deleted')),
              );
            },
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
    return BlocProvider(
      create: (context) => di.sl<BotBloc>()..add(const FetchBotsEvent()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('AI Assistants'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _navigateToCreateBot,
                ),
              ],
            ),
            drawer: MainAppDrawer(
              currentIndex: 1, // Index for "Bots" tab
              onTabSelected: (index) => navigation_utils
                  .handleDrawerNavigation(context, index, currentIndex: 1),
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
            floatingActionButton: FloatingActionButton(
              onPressed: _navigateToCreateBot,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
