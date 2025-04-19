import 'package:flutter/material.dart';

class PromptHeaderInfo extends StatelessWidget {
  final String title;
  final String id;

  const PromptHeaderInfo({
    Key? key,
    required this.title,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Chỉnh sửa: $title',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Text(
          'ID: $id',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
