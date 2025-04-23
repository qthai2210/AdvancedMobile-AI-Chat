import 'package:flutter/material.dart';
import 'package:aichatbot/data/models/knowledge/knowledge_unit_model.dart';

class KnowledgeUnitCard extends StatelessWidget {
  final KnowledgeUnitModel unit;
  final VoidCallback onViewDetails;
  final VoidCallback onDelete;
  final bool isExpanded;
  final Function(bool) onExpansionChanged;

  const KnowledgeUnitCard({
    Key? key,
    required this.unit,
    required this.onViewDetails,
    required this.onDelete,
    this.isExpanded = false,
    required this.onExpansionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        leading: _buildUnitIcon(unit, context),
        title: Text(
          unit.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${unit.type}, Size: ${_formatFileSize(unit.size)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Created: ${_formatDate(unit.createdAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              onPressed: onViewDetails,
              tooltip: 'View Details',
            ),
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Delete Unit',
            ),
          ],
        ),
        children: [
          if (unit.metadata.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Metadata:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...unit.metadata.entries
                      .map((entry) =>
                          _buildDetailItem(entry.key, entry.value.toString()))
                      .toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnitIcon(KnowledgeUnitModel unit, BuildContext context) {
    IconData iconData;
    Color iconColor;

    // Determine icon based on type and metadata
    switch (unit.type) {
      case 'local_file':
        final fileName = unit.name.toLowerCase();
        if (fileName.endsWith('.pdf')) {
          iconData = Icons.picture_as_pdf;
          iconColor = Colors.red;
        } else if (fileName.endsWith('.docx') || fileName.endsWith('.doc')) {
          iconData = Icons.description;
          iconColor = Colors.blue;
        } else if (fileName.endsWith('.txt')) {
          iconData = Icons.text_snippet;
          iconColor = Colors.orange;
        } else {
          iconData = Icons.insert_drive_file;
          iconColor = Colors.grey;
        }
        break;
      default:
        iconData = Icons.file_present;
        iconColor = Theme.of(context).primaryColor;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
