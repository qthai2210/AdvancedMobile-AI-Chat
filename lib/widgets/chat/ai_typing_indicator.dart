import 'package:flutter/material.dart';

class AITypingIndicator extends StatelessWidget {
  const AITypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Text('AI đang nhập'),
          SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}
