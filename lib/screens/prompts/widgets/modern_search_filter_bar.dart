import 'package:aichatbot/presentation/bloc/prompt/prompt_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_bloc.dart';
import 'package:aichatbot/presentation/bloc/prompt/prompt_state.dart';

class ModernSearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final List<String> categories;
  final Map<String, String> categoryDisplayNames;
  final Function(String) onToggleCategory;

  const ModernSearchFilterBar({
    Key? key,
    required this.searchController,
    required this.categories,
    required this.categoryDisplayNames,
    required this.onToggleCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          // Search bar với thiết kế mới
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm prompt...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          searchController.clear();
                          context
                              .read<PromptBloc>()
                              .add(SearchQueryChanged(''));
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Category filter chips với thiết kế mới
          SizedBox(
            height: 40,
            child: BlocBuilder<PromptBloc, PromptState>(
              builder: (context, state) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final displayName =
                        categoryDisplayNames[category] ?? category;
                    final isSelected =
                        state.selectedCategories.contains(category);
                    final color = _getCategoryColor(category);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(
                          displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        backgroundColor: Colors.grey[100],
                        selectedColor: color,
                        checkmarkColor: Colors.white,
                        onSelected: (_) => onToggleCategory(category),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'business':
        return Colors.blue;
      case 'career':
        return Colors.deepPurple;
      case 'chatbot':
        return Colors.teal;
      case 'coding':
        return Colors.indigo;
      case 'education':
        return Colors.green;
      case 'fun':
        return Colors.orange;
      case 'marketing':
        return Colors.red;
      case 'productivity':
        return Colors.amber;
      case 'seo':
        return Colors.lightBlue;
      case 'writing':
        return Colors.pink;
      case 'all':
        return Colors.grey.shade600;
      default:
        return Colors.blueGrey;
    }
  }
}
