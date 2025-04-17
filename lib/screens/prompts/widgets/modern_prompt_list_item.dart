import 'package:flutter/material.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/domain/entities/prompt.dart';

class ModernPromptListItem extends StatelessWidget {
  final PromptModel prompt;
  final bool isOwner;
  final Function(PromptModel) onViewDetails;
  final Function(PromptModel) onToggleFavorite;
  final Function(PromptModel) onEdit;
  final Function(BuildContext, PromptModel) onDelete;
  final Function(PromptModel) onUse;
  final String Function(DateTime) formatDate;

  const ModernPromptListItem({
    Key? key,
    required this.prompt,
    required this.isOwner,
    required this.onViewDetails,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onDelete,
    required this.onUse,
    required this.formatDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onViewDetails(prompt),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and favorite button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prompt.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              prompt.userName ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.access_time,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              formatDate(prompt.createdAt),
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
                  IconButton(
                    icon: Icon(
                      prompt.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: prompt.isFavorite ? Colors.red : Colors.grey,
                      size: 22,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                    onPressed: () => onToggleFavorite(prompt),
                  ),
                ],
              ),

              // Description
              if (prompt.description != null && prompt.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: Text(
                    prompt.description!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Tags and category
              Row(
                children: [
                  // Category chip
                  if (prompt.category != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Prompt.getCategoryColor(prompt.category!)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Prompt.getCategoryColor(prompt.category!)
                              .withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        prompt.category!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Prompt.getCategoryColor(prompt.category!),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Language chip
                  if (prompt.language != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.5)),
                      ),
                      child: Text(
                        prompt.language!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Usage count
                  Row(
                    children: [
                      Icon(Icons.bar_chart, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${prompt.useCount} uses',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),

              const Divider(height: 24),

              // Action buttons
              Row(
                children: [
                  if (isOwner) ...[
                    _buildActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onPressed: () => onEdit(prompt),
                      backgroundColor: Colors.grey[100]!,
                      textColor: Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      onPressed: () => onDelete(context, prompt),
                      backgroundColor: Colors.red[50]!,
                      textColor: Colors.red,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.chat,
                      label: 'Use in Chat',
                      onPressed: () => onUse(prompt),
                      backgroundColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
