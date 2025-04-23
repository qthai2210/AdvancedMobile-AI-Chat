import 'package:flutter/material.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_model.dart';
import 'package:aichatbot/widgets/knowledge/knowledge_base_card.dart';

class KnowledgeListView extends StatelessWidget {
  final List<KnowledgeModel> knowledges;
  final Function(KnowledgeModel) onTap;
  final Function(KnowledgeModel) onDelete;
  final bool isLoading;
  final Function(int) onLoadMore;
  final int currentOffset;
  final bool hasReachedMax;

  const KnowledgeListView({
    Key? key,
    required this.knowledges,
    required this.onTap,
    required this.onDelete,
    this.isLoading = false,
    required this.onLoadMore,
    required this.currentOffset,
    required this.hasReachedMax,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoading &&
            !hasReachedMax &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent * 0.8) {
          onLoadMore(currentOffset);
          return true;
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 80),
        itemCount: knowledges.length + (hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= knowledges.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final knowledge = knowledges[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: KnowledgeBaseCard(
              knowledge: knowledge,
              onTap: () => onTap(knowledge),
              onDelete: () => onDelete(knowledge),
            ),
          );
        },
      ),
    );
  }
}
