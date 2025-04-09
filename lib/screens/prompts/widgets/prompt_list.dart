import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/screens/prompts/widgets/prompt_card.dart';

class PromptList extends StatefulWidget {
  final ScrollController? scrollController;
  final bool isGridView;

  const PromptList({
    Key? key,
    this.scrollController,
    this.isGridView = false,
  }) : super(key: key);

  @override
  State<PromptList> createState() => _PromptListState();
}

class _PromptListState extends State<PromptList> {
  ScrollController? _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController!.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController?.removeListener(_onScroll);
      _scrollController?.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController!.position.maxScrollExtent;
    final currentScroll = _scrollController!.position.pixels;
    final state = context.read<PromptBloc>().state;

    // Load more when we're at 80% of the list
    if (currentScroll >= maxScroll * 0.8 &&
        state.status != PromptStatus.loadingMore &&
        state.status != PromptStatus.loading &&
        state.promptListResponse?.hasNext == true) {
      _isLoadingMore = true;

      final authState = context.read<AuthBloc>().state;
      if (authState.user?.accessToken == null) return;

      // Calculate the next offset based on the current items count
      final nextOffset = state.prompts.length;

      context.read<PromptBloc>().add(
            LoadMorePrompts(
              accessToken: authState.user!.accessToken!,
              offset: nextOffset,
              limit: 20,
              category: state.selectedCategory,
              isFavorite: state.isFavoriteFilter,
            ),
          );

      // Reset loading flag after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PromptBloc, PromptState>(
      listener: (context, state) {
        // Handle errors or success messages if needed
        if (state.status == PromptStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error: ${state.errorMessage ?? "Unknown error"}')),
          );
        }
      },
      builder: (context, state) {
        // Log state for debugging
        debugPrint(
            'PromptList: Status = ${state.status}, Prompts count = ${state.prompts.length}');

        if (state.status == PromptStatus.initial ||
            (state.status == PromptStatus.loading && state.prompts.isEmpty)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.prompts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  state.status == PromptStatus.failure
                      ? 'Error: ${state.errorMessage ?? "Failed to load prompts"}'
                      : 'No prompts found',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (state.status != PromptStatus.failure)
                  ElevatedButton(
                    onPressed: () => _refreshPrompts(),
                    child: const Text('Refresh'),
                  ),
              ],
            ),
          );
        }

        // Choose between ListView and GridView based on isGridView prop
        return widget.isGridView
            ? _buildGridView(
                state.prompts, state.promptListResponse?.hasNext == true)
            : _buildListView(
                state.prompts, state.promptListResponse?.hasNext == true);
      },
    );
  }

  Widget _buildListView(List<PromptModel> prompts, bool hasMore) {
    return RefreshIndicator(
      onRefresh: () async => _refreshPrompts(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: prompts.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= prompts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final prompt = prompts[index];
          return PromptCard(
            prompt: prompt,
            onTap: () => _handlePromptTap(prompt),
            onFavoriteToggle: () => _toggleFavorite(prompt),
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<PromptModel> prompts, bool hasMore) {
    return RefreshIndicator(
      onRefresh: () async => _refreshPrompts(),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: prompts.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= prompts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final prompt = prompts[index];
          return PromptCard(
            prompt: prompt,
            isGrid: true,
            onTap: () => _handlePromptTap(prompt),
            onFavoriteToggle: () => _toggleFavorite(prompt),
          );
        },
      ),
    );
  }

  void _refreshPrompts() {
    final authState = context.read<AuthBloc>().state;
    if (authState.user?.accessToken == null) return;

    final state = context.read<PromptBloc>().state;

    context.read<PromptBloc>().add(
          FetchPrompts(
            accessToken: authState.user!.accessToken!,
            offset: 0,
            limit: 20,
            category: state.selectedCategory,
            isFavorite: state.isFavoriteFilter,
          ),
        );
  }

  void _handlePromptTap(PromptModel prompt) {
    // Implement prompt tap handler
    debugPrint('Prompt tapped: ${prompt.title}');
    // Navigator.pushNamed(context, '/prompt/detail', arguments: prompt);
  }

  void _toggleFavorite(PromptModel prompt) {
    final authState = context.read<AuthBloc>().state;
    if (authState.user?.accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You need to be logged in to favorite prompts')),
      );
      return;
    }

    context.read<PromptBloc>().add(
          ToggleFavoriteRequested(
            promptId: prompt.id,
            accessToken: authState.user!.accessToken!,
          ),
        );
  }
}
