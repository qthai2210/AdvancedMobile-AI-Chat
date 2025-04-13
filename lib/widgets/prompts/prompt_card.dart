import 'package:flutter/material.dart';
import 'package:aichatbot/models/prompt_model.dart';

class PromptCard extends StatelessWidget {
  final Prompt prompt;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onUse;

  const PromptCard({
    Key? key,
    required this.prompt,
    required this.onTap,
    required this.onFavorite,
    required this.onUse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              Text(
                prompt.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              _buildCategoryChips(),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
        IconButton(
          icon: Icon(
            prompt.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: prompt.isFavorite ? Colors.red : Colors.grey,
            size: 24,
          ),
          onPressed: onFavorite,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.only(left: 12),
          tooltip:
              prompt.isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: prompt.category.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = prompt.category[index];
          final color = Prompt.getCategoryColor(category);
          return Chip(
            label: Text(
              category,
              style: TextStyle(color: color, fontSize: 12),
            ),
            backgroundColor: color.withOpacity(0.15),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Usage count
        Row(
          children: [
            const Icon(Icons.bar_chart, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${prompt.useCount} uses',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),

        // Use button
        ElevatedButton.icon(
          onPressed: onUse,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Use'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            visualDensity: VisualDensity.compact,
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
