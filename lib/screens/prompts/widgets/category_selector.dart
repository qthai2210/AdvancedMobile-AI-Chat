import 'package:flutter/material.dart';
import 'package:aichatbot/domain/entities/prompt.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Danh sách các danh mục có sẵn
    final List<String> categories = [
      'business',
      'career',
      'chatbot',
      'coding',
      'education',
      'fun',
      'marketing',
      'productivity',
      'seo',
      'writing',
      'other',
    ];

    // Map hiển thị tên đẹp hơn
    final Map<String, String> categoryDisplayNames = {
      'business': 'Business',
      'career': 'Career',
      'chatbot': 'Chatbot',
      'coding': 'Coding',
      'education': 'Education',
      'fun': 'Fun',
      'marketing': 'Marketing',
      'productivity': 'Productivity',
      'seo': 'SEO',
      'writing': 'Writing',
      'other': 'Other'
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        return ChoiceChip(
          label: Text(categoryDisplayNames[category] ?? category),
          selected: selectedCategory == category,
          onSelected: (selected) {
            if (selected) {
              onCategorySelected(category);
            }
          },
          selectedColor: Prompt.getCategoryColor(category).withOpacity(0.2),
          backgroundColor: Colors.grey[100],
          labelStyle: TextStyle(
            color: selectedCategory == category
                ? Prompt.getCategoryColor(category)
                : Colors.black87,
            fontWeight: selectedCategory == category
                ? FontWeight.bold
                : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: selectedCategory == category
                  ? Prompt.getCategoryColor(category)
                  : Colors.grey[300]!,
            ),
          ),
        );
      }).toList(),
    );
  }
}
