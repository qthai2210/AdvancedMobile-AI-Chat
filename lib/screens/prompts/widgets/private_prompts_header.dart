import 'package:flutter/material.dart';

class PrivatePromptsHeader extends StatelessWidget {
  final int count;

  const PrivatePromptsHeader({
    Key? key,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  '$count Prompts riêng tư',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Có thể thêm buttons hoặc filters ở đây
        ],
      ),
    );
  }
}
