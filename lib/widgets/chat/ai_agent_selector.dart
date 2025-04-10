import 'package:flutter/material.dart';
import 'package:aichatbot/models/ai_agent_model.dart';
import 'package:aichatbot/screens/create_bot_screen.dart';

class AIAgentSelector extends StatelessWidget {
  final AIAgent selectedAgent;
  final Function(AIAgent) onAgentSelected;

  const AIAgentSelector({
    super.key,
    required this.selectedAgent,
    required this.onAgentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Chọn AI Agent',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: AIAgents.agents.length +
                  1, // Added 1 for the "Create Bot" option
              itemBuilder: (context, index) {
                if (index < AIAgents.agents.length) {
                  final agent = AIAgents.agents[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: agent.color,
                      child: Text(
                        agent.name.substring(0, 1),
                        style: TextStyle(
                          color: agent.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(agent.name),
                    subtitle: Text(agent.description),
                    trailing: selectedAgent.id == agent.id
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () => onAgentSelected(agent),
                  );
                } else {
                  // Create Custom Bot option
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: const Text('Tạo AI BOT mới'),
                    subtitle: const Text('Tùy chỉnh AI BOT riêng của bạn'),
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
              },
            ),
          ),
        ],
      ),
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
