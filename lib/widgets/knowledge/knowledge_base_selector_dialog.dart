import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_bloc.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_event.dart';
import 'package:aichatbot/presentation/bloc/knowledge/knowledge_state.dart';
import 'package:aichatbot/core/di/injection_container.dart';

/// A dialog that shows a list of knowledge bases for selection.
/// This dialog is used when linking knowledge bases to an assistant.
class KnowledgeBaseSelectorDialog extends StatefulWidget {
  final Function(String knowledgeId, String knowledgeName) onKnowledgeSelected;
  final String? assistantId;

  const KnowledgeBaseSelectorDialog({
    Key? key,
    required this.onKnowledgeSelected,
    this.assistantId,
  }) : super(key: key);

  @override
  State<KnowledgeBaseSelectorDialog> createState() =>
      _KnowledgeBaseSelectorDialogState();
}

class _KnowledgeBaseSelectorDialogState
    extends State<KnowledgeBaseSelectorDialog> {
  late KnowledgeBloc _knowledgeBloc;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _knowledgeBloc = sl<KnowledgeBloc>();
    _fetchKnowledgeBases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch knowledge bases from the server
  void _fetchKnowledgeBases() {
    if (widget.assistantId != null) {
      // If an assistantId is provided, fetch knowledge bases for that assistant
      _knowledgeBloc.add(
        FetchAssistantKnowledgesEvent(
          assistantId: widget.assistantId!,
          searchQuery: _searchQuery,
          offset: 0,
          limit: 20,
        ),
      );
    } else {
      // Otherwise fetch all knowledge bases
      _knowledgeBloc.add(
        FetchKnowledgesEvent(
          searchQuery: _searchQuery,
          offset: 0,
          limit: 20,
        ),
      );
    }
  }

  /// Search for knowledge bases with the current query
  void _searchKnowledgeBases() {
    if (widget.assistantId != null) {
      // If an assistantId is provided, search knowledge bases for that assistant
      _knowledgeBloc.add(
        FetchAssistantKnowledgesEvent(
          assistantId: widget.assistantId!,
          searchQuery: _searchQuery,
          offset: 0,
          limit: 20,
        ),
      );
    } else {
      // Otherwise search all knowledge bases
      _knowledgeBloc.add(
        RefreshKnowledgesEvent(
          searchQuery: _searchQuery,
          limit: 20,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<KnowledgeBloc>.value(
      value: _knowledgeBloc,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Knowledge Base',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search knowledge bases...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              _fetchKnowledgeBases();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (_) {
                    _searchKnowledgeBases();
                  },
                ),
              ),

              // Knowledge List
              Expanded(
                child: BlocBuilder<KnowledgeBloc, KnowledgeState>(
                  builder: (context, state) {
                    if (state is KnowledgeInitial ||
                        state is KnowledgeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is KnowledgeError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error loading knowledge bases: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    if (state is KnowledgeLoaded) {
                      if (state.knowledges.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No knowledge bases found.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: state.knowledges.length,
                        itemBuilder: (context, index) {
                          final knowledge = state.knowledges[index];
                          return InkWell(
                            onTap: () {
                              if (knowledge.id != null) {
                                widget.onKnowledgeSelected(
                                  knowledge.id!,
                                  knowledge.knowledgeName,
                                );
                                Navigator.of(context).pop();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        knowledge.knowledgeName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (knowledge.description != null &&
                                          knowledge.description!.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            knowledge.description!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      if (knowledge.id != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            'ID: ${knowledge.id}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const Center(
                      child: Text('No data available'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
