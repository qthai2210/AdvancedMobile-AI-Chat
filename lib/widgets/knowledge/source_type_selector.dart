import 'package:flutter/material.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';

class SourceTypeSelector extends StatelessWidget {
  final KnowledgeSourceType selectedType;
  final Function(KnowledgeSourceType) onTypeChanged;

  const SourceTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loại nguồn dữ liệu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildSourceTypeOption(
                  context,
                  KnowledgeSourceType.local_file,
                  'File',
                  Icons.insert_drive_file,
                  Colors.blue,
                ),
                _buildSourceTypeOption(
                  context,
                  KnowledgeSourceType.website,
                  'Website',
                  Icons.language,
                  Colors.green,
                ),
                _buildSourceTypeOption(
                  context,
                  KnowledgeSourceType.googleDrive,
                  'Google Drive',
                  Icons.drive_folder_upload,
                  Colors.orange,
                ),
                _buildSourceTypeOption(
                  context,
                  KnowledgeSourceType.slack,
                  'Slack',
                  Icons.messenger_outline,
                  Colors.purple,
                ),
                _buildSourceTypeOption(
                  context,
                  KnowledgeSourceType.confluence,
                  'Confluence',
                  Icons.article,
                  Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceTypeOption(
    BuildContext context,
    KnowledgeSourceType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () => onTypeChanged(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
