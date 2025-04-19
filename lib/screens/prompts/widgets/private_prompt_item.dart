import 'package:flutter/material.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:aichatbot/screens/prompts/widgets/prompt_action_button.dart';

class PrivatePromptItem extends StatelessWidget {
  final PromptModel prompt;
  final Function(PromptModel) onViewDetails;
  final Function(PromptModel) onToggleFavorite;
  final Function(PromptModel) onEdit;
  final Function(PromptModel) onUsePrompt;
  final Function(BuildContext, PromptModel) onDeletePrompt;
  final String Function(DateTime) formatDate;

  const PrivatePromptItem({
    Key? key,
    required this.prompt,
    required this.onViewDetails,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onUsePrompt,
    required this.onDeletePrompt,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with color
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Prompt.getCategoryColor(prompt.category ?? 'other'),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and favorite button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lock icon and title
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                prompt.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Favorite button
                      IconButton(
                        icon: Icon(
                          prompt.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: prompt.isFavorite ? Colors.red : null,
                          size: 20,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: EdgeInsets.zero,
                        onPressed: () => onToggleFavorite(prompt),
                      ),
                    ],
                  ),

                  // Description
                  if (prompt.description != null &&
                      prompt.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Text(
                        prompt.description!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Creation date and other info
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        formatDate(prompt.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      if (prompt.category != null) ...[
                        Icon(Icons.category, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          prompt.category!,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),

                  const Divider(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PromptActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Sửa',
                        onPressed: () => onEdit(prompt),
                        backgroundColor: Colors.grey[100]!,
                        textColor: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      PromptActionButton(
                        icon: Icons.delete_outline,
                        label: 'Xóa',
                        onPressed: () => onDeletePrompt(context, prompt),
                        backgroundColor: Colors.red[50]!,
                        textColor: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      PromptActionButton(
                        icon: Icons.chat,
                        label: 'Sử dụng',
                        onPressed: () => onUsePrompt(prompt),
                        backgroundColor: Theme.of(context).primaryColor,
                        textColor: Colors.white,
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
}
