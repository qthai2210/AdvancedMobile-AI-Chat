import 'package:flutter/material.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';

class KnowledgeDetailHeader extends StatelessWidget {
  final KnowledgeBase knowledgeBase;
  final VoidCallback onRefresh;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KnowledgeDetailHeader({
    Key? key,
    required this.knowledgeBase,
    required this.onRefresh,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card with knowledge base info
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          knowledgeBase.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: knowledgeBase.isEnabled
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              knowledgeBase.isEnabled
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 16,
                              color: knowledgeBase.isEnabled
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              knowledgeBase.isEnabled
                                  ? 'Hoạt động'
                                  : 'Vô hiệu hóa',
                              style: TextStyle(
                                color: knowledgeBase.isEnabled
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  if (knowledgeBase.description.isNotEmpty) ...[
                    Text(
                      knowledgeBase.description,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        context,
                        Icons.description,
                        'Tổng nguồn',
                        '${knowledgeBase.totalSourcesCount}',
                      ),
                      _buildStatItem(
                        context,
                        Icons.check_circle_outline,
                        'Nguồn hoạt động',
                        '${knowledgeBase.activeSourcesCount}',
                      ),
                      _buildStatItem(
                        context,
                        Icons.calendar_today,
                        'Ngày tạo',
                        _formatDate(knowledgeBase.createdAt),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        label: const Text('Chỉnh sửa'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      // OutlinedButton.icon(
                      //   onPressed: onRefresh,
                      //   icon: const Icon(Icons.refresh),
                      //   label: const Text('Làm mới'),
                      //   style: OutlinedButton.styleFrom(
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(20),
                      //     ),
                      //   ),
                      // ),
                      OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Xóa',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
