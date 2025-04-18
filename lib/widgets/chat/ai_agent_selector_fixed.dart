import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/models/ai_agent_model.dart';
import 'package:aichatbot/screens/create_bot_screen.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_event.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_state.dart';
import 'package:aichatbot/data/models/assistant/assistant_model.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/domain/usecases/assistant/get_assistants_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/create_assistant_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/update_assistant_usecase.dart';
import 'package:aichatbot/domain/usecases/assistant/delete_assistant_usecase.dart';
import 'package:aichatbot/core/di/injection_container.dart' as di;

class AIAgentSelector extends StatefulWidget {
  final AIAgent selectedAgent;
  final Function(AIAgent) onAgentSelected;

  const AIAgentSelector({
    super.key,
    required this.selectedAgent,
    required this.onAgentSelected,
  });

  @override
  State<AIAgentSelector> createState() => _AIAgentSelectorState();
}

class _AIAgentSelectorState extends State<AIAgentSelector> {
  List<AIAgent> _customAgents = [];
  bool _isLoading = true;

  // No need for initState with postFrameCallback since we're using BlocProvider now

  // Convert AssistantModel to AIAgent
  AIAgent _convertToAIAgent(AssistantModel assistant) {
    // Create a consistent color based on the assistant ID
    final colors = [
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300,
      Colors.teal.shade300,
      Colors.pink.shade300,
      Colors.indigo.shade300
    ];

    // Use a hash of the ID to determine the color
    final colorIndex = assistant.id.hashCode.abs() % colors.length;

    return AIAgent(
      id: assistant.id, // Store the actual ID
      name: assistant.assistantName,
      description: assistant.description ?? 'Custom assistant',
      color: colors[colorIndex],
      isCustom: true, // Mark as custom assistant
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create a fresh BotBloc that will live only for the duration of this widget
    return BlocProvider<BotBloc>(
      create: (context) {
        try {
          return BotBloc(
            getAssistantsUseCase: di.sl<GetAssistantsUseCase>(),
            createAssistantUseCase: di.sl<CreateAssistantUseCase>(),
            updateAssistantUseCase: di.sl<UpdateAssistantUseCase>(),
            deleteAssistantUseCase: di.sl<DeleteAssistantUseCase>(),
          )..add(
              const FetchBotsEvent()); // Fetch bots immediately upon creation
        } catch (e) {
          AppLogger.e("Failed to create BotBloc: $e");
          // Return a minimal BotBloc that will just show empty state
          return BotBloc(
            getAssistantsUseCase: di.sl<GetAssistantsUseCase>(),
            createAssistantUseCase: di.sl<CreateAssistantUseCase>(),
            updateAssistantUseCase: di.sl<UpdateAssistantUseCase>(),
            deleteAssistantUseCase: di.sl<DeleteAssistantUseCase>(),
          );
        }
      },
      child: BlocConsumer<BotBloc, BotState>(
        listener: (context, state) {
          if (state is BotsLoaded) {
            setState(() {
              _customAgents = state.bots.map(_convertToAIAgent).toList();
              _isLoading = false;
            });
            AppLogger.i("Loaded ${_customAgents.length} custom assistants");
          } else if (state is BotsError) {
            setState(() {
              _isLoading = false;
              _customAgents = []; // Use empty list on error
            });
            AppLogger.e("Error loading bots: ${state.message}");
          }
        },
        builder: (context, state) {
          // Set loading state based on BotState
          if (state is BotInitial || state is BotsLoading) {
            _isLoading = true;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose AI Assistant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        if (AIAgents.agents.isNotEmpty)
                          _buildSectionHeader('Built-in Models'),
                        ..._buildAgentList(AIAgents.agents),
                        if (_customAgents.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildSectionHeader('Your Custom Assistants'),
                          ..._buildAgentList(_customAgents),
                        ],
                        const SizedBox(height: 16),
                        _buildCreateBotTile(),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  List<Widget> _buildAgentList(List<AIAgent> agents) {
    return agents
        .map((agent) => ListTile(
              leading: CircleAvatar(
                backgroundColor: agent.color,
                child: Text(
                  agent.name.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(agent.name),
              subtitle: Text(agent.description),
              trailing: widget.selectedAgent.id == agent.id
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () => widget.onAgentSelected(agent),
            ))
        .toList();
  }

  Widget _buildCreateBotTile() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
        child: Icon(
          Icons.add,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: const Text('Create New Assistant'),
      subtitle: const Text('Customize your own AI assistant'),
      onTap: () {
        // Close the current sheet
        Navigator.pop(context);

        // Navigate to CreateBotScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateBotScreen(),
          ),
        );
      },
    );
  }
}

class AgentSelectorButton extends StatelessWidget {
  final AIAgent agent;
  final VoidCallback onTap;

  const AgentSelectorButton({
    super.key,
    required this.agent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            agent.name,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
