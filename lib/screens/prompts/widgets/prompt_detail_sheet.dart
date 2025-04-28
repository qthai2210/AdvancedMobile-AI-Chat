import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aichatbot/data/models/prompt/prompt_model.dart';
import 'package:aichatbot/domain/entities/prompt.dart';
import 'package:go_router/go_router.dart';

class PromptDetailSheet extends StatelessWidget {
  final PromptModel prompt;
  final bool isOwner;
  final Function(PromptModel) onToggleFavorite;
  final Function(PromptModel) onEdit;
  final Function(PromptModel) onSaveAsPrivate;
  final Function(PromptModel) onUse;
  final Function(BuildContext, PromptModel) onDelete;

  const PromptDetailSheet({
    Key? key,
    required this.prompt,
    required this.isOwner,
    required this.onToggleFavorite,
    required this.onEdit,
    required this.onSaveAsPrivate,
    required this.onUse,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with drag handle
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prompt.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),

              // Divider
              const Divider(height: 1),

              // Content scrollable area
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Description
                    if (prompt.description.isNotEmpty) ...[
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prompt.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Tags section
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Category chip
                        if (prompt.category != null)
                          Chip(
                            label: Text(prompt.category!),
                            backgroundColor:
                                Prompt.getCategoryColor(prompt.category!)
                                    .withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: Prompt.getCategoryColor(prompt.category!),
                            ),
                          ),

                        // Language chip
                        if (prompt.language != null)
                          Chip(
                            label: Text(prompt.language!.toUpperCase()),
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            labelStyle: const TextStyle(color: Colors.blue),
                          ),

                        // Public/Private status
                        Chip(
                          label: Text(prompt.isPublic ? 'Public' : 'Private'),
                          backgroundColor: prompt.isPublic
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color:
                                prompt.isPublic ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Prompt content
                    const Text(
                      'Prompt Content',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prompt.content,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.copy, size: 16),
                                label: const Text('Copy'),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: prompt.content));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Prompt copied to clipboard'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Additional info
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                              'Created', _formatDate(prompt.createdAt)),
                          _buildInfoRow(
                              'Last Updated', _formatDate(prompt.updatedAt)),
                          _buildInfoRow(
                              'Times Used', '${prompt.useCount} times'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Favorite button
                      Expanded(
                        flex: 1,
                        child: _buildActionButton(
                          context: context,
                          icon: prompt.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: prompt.isFavorite ? 'Remove' : 'Favorite',
                          onPressed: () {
                            onToggleFavorite(prompt);
                            context.pop();
                          },
                          backgroundColor: prompt.isFavorite
                              ? Colors.red[50]!
                              : Colors.grey[100]!,
                          textColor:
                              prompt.isFavorite ? Colors.red : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Save as private button (if not owner)
                      if (!isOwner)
                        Expanded(
                          flex: 1,
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.save_alt,
                            label: 'Save Copy',
                            onPressed: () {
                              onSaveAsPrivate(prompt);
                              context.pop();
                            },
                            backgroundColor: Colors.blue[50]!,
                            textColor: Colors.blue,
                          ),
                        ),

                      // Edit button (if owner)
                      if (isOwner)
                        Expanded(
                          flex: 1,
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            onPressed: () {
                              context.pop();
                              onEdit(prompt);
                            },
                            backgroundColor: Colors.blue[50]!,
                            textColor: Colors.blue,
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (isOwner)
                        // Delete button
                        Expanded(
                          flex: 1,
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            onPressed: () {
                              context.pop();
                              onDelete(context, prompt);
                            },
                            backgroundColor: Colors.red[50]!,
                            textColor: Colors.red,
                          ),
                        ),

                      const SizedBox(width: 8),

                      // Use in chat button
                      Expanded(
                        flex: 2,
                        child: _buildActionButton(
                          context: context,
                          icon: Icons.chat,
                          label: 'Use in Chat',
                          onPressed: () => onUse(prompt),
                          backgroundColor: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format to a user-friendly date like "10 Apr 2023"
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
