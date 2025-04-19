import 'package:flutter/material.dart';

class PrivatePromptsEmptyState extends StatelessWidget {
  final VoidCallback onCreatePrompt;

  const PrivatePromptsEmptyState({
    Key? key,
    required this.onCreatePrompt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 48,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bạn chưa có Prompt riêng tư nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tạo prompt riêng tư cho nhu cầu của riêng bạn',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreatePrompt,
            icon: const Icon(Icons.add),
            label: const Text('Tạo Prompt Riêng Tư'),
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
}
