import 'package:flutter/material.dart';
import 'package:aichatbot/models/ai_bot_model.dart';

class BotListItem extends StatelessWidget {
  final AIBot bot;
  final VoidCallback onEdit;
  final VoidCallback onChat;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final bool isSelected;

  const BotListItem({
    super.key,
    required this.bot,
    required this.onEdit,
    required this.onChat,
    required this.onDelete,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: bot.color, width: 2.0)
              : BorderSide.none,
        ),
        color: isSelected ? Colors.grey.shade50 : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bot header with color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bot.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'bot-avatar-${bot.id}',
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        bot.iconData,
                        color: bot.color,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bot information
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bot.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bot.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Created ${_formatDate(bot.createdAt)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          _buildActionButton(Icons.edit_outlined, onEdit),
                          const SizedBox(width: 16),
                          _buildActionButton(Icons.chat_outlined, onChat),
                          const SizedBox(width: 16),
                          _buildActionButton(Icons.delete_outline, onDelete,
                              color: Colors.red),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed,
      {Color? color}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          icon,
          size: 20,
          color: color ?? Colors.grey[700],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
