import 'package:flutter/material.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/domain/entities/prompt.dart';

class ModernPromptGridItem extends StatelessWidget {
  final PromptModel prompt;
  final bool isOwner;
  final Function(PromptModel) onViewDetails;
  final Function(PromptModel) onToggleFavorite;
  final Function(PromptModel) onEdit;
  final Function(BuildContext, PromptModel) onDelete;
  final Function(PromptModel) onUse;
  final String Function(DateTime) formatDate;

  const ModernPromptGridItem({
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
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onViewDetails(prompt),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category color
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Prompt.getCategoryColor(prompt.category ?? 'Other'),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and favorite
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            prompt.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
                            size: 20,
                            color: prompt.isFavorite ? Colors.red : Colors.grey,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          onPressed: () => onToggleFavorite(prompt),
                        ),
                      ],
                    ),

                    // Author
                    Text(
                      'By: ${prompt.userName ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    if (prompt.description != null)
                      Expanded(
                        child: Text(
                          prompt.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Category chip
                    if (prompt.category != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Prompt.getCategoryColor(prompt.category!)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Prompt.getCategoryColor(prompt.category!)
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          prompt.category!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Prompt.getCategoryColor(prompt.category!),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Usage count
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.bar_chart,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${prompt.useCount}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                      onPressed: () => onEdit(prompt),
                    ),

                  IconButton(
                    icon: const Icon(Icons.chat, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    onPressed: () => onUse(prompt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
