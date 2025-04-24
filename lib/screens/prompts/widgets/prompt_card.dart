import 'package:flutter/material.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class PromptCard extends StatelessWidget {
  final PromptModel prompt;
  final bool isGrid;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const PromptCard({
    Key? key,
    required this.prompt,
    this.isGrid = false,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isGrid ? _buildGridCard(context) : _buildListCard(context);
  }

  Widget _buildListCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      prompt.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      prompt.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: prompt.isFavorite ? Colors.red : Colors.grey,
                      size: 22,
                    ),
                    onPressed: onFavoriteToggle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (prompt.description.isNotEmpty) ...[
                Text(
                  prompt.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  // Category chip
                  if (prompt.category?.isNotEmpty ?? false)
                    _buildCategoryChip(prompt.category!),
                  const Spacer(),
                  // Created date
                  //if (prompt.createdAt != null)
                  Text(
                    _formatDate(prompt.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and favorite icon
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      prompt.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      prompt.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: prompt.isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    onPressed: onFavoriteToggle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Description
            if (prompt.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  prompt.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const Spacer(),

            // Footer with category and date
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prompt.category?.isNotEmpty ?? false)
                    _buildCategoryChip(prompt.category!),
                  const SizedBox(height: 4),
                  if (prompt.createdAt != null)
                    Text(
                      _formatDate(prompt.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final color = _getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        category.capitalize(),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 7) {
      return timeago.format(date);
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  Color _getCategoryColor(String category) {
    // Handle null or empty
    if (category.isEmpty) {
      return Colors.blueGrey;
    }

    // Map categories to colors
    final lowercaseCategory = category.toLowerCase();

    switch (lowercaseCategory) {
      case 'writing':
        return Colors.blue;
      case 'coding':
        return Colors.indigo;
      case 'business':
        return Colors.amber.shade800;
      case 'marketing':
        return Colors.green;
      case 'education':
        return Colors.purple;
      case 'creative':
        return Colors.pink;
      case 'personal':
        return Colors.teal;
      case 'career':
        return Colors.deepOrange;
      case 'chatbot':
        return Colors.cyan;
      case 'fun':
        return Colors.red;
      case 'productivity':
        return Colors.lightBlue;
      case 'seo':
        return Colors.lightGreen;
      case 'other':
      default:
        return Colors.blueGrey;
    }
  }
}

// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
