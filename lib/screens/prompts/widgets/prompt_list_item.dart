import 'package:flutter/material.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/domain/entities/prompt.dart';

class PromptListItem extends StatelessWidget {
  final PromptModel prompt;
  final bool isOwner;
  final Function(PromptModel) onViewDetails;
  final Function(PromptModel) onToggleFavorite;
  final Function(PromptModel) onEdit;
  final Function(BuildContext, PromptModel) onDelete;
  final Function(PromptModel) onUse;
  final String Function(DateTime) formatDate;

  const PromptListItem({
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onViewDetails(prompt),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            Icon(Icons.person_outline,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              prompt.userName ?? 'Unknown',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
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
                      color: prompt.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => onToggleFavorite(prompt),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              //if (prompt.description != null && prompt.description!.isNotEmpty)
              if (prompt.description.isNotEmpty)
                Text(
                  prompt.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (prompt.category != null)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Prompt.getCategoryColor(prompt.category!)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Prompt.getCategoryColor(prompt.category!)
                                  .withOpacity(0.3)),
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
                    if (prompt.language != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.5)),
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
                  ],
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Row(
                    children: [
                      // Edit button
                      if (isOwner)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            onPressed: () => onEdit(prompt),
                            backgroundColor: Colors.grey[100]!,
                            textColor: Colors.black87,
                          ),
                        ),

                      // Delete button
                      if (isOwner)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            onPressed: () => onDelete(context, prompt),
                            backgroundColor: Colors.red[50]!,
                            textColor: Colors.red,
                          ),
                        ),

                      // Use button
                      _buildActionButton(
                        context: context,
                        icon: Icons.chat,
                        label: 'Use',
                        onPressed: () => onUse(prompt),
                        backgroundColor: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                      ),
                    ],
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
    required BuildContext context,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
