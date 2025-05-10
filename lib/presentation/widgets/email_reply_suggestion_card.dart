import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aichatbot/utils/styles.dart';

class EmailReplySuggestionCard extends StatelessWidget {
  final String suggestion;
  final Function(String) onSelect;

  const EmailReplySuggestionCard({
    Key? key,
    required this.suggestion,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => onSelect(suggestion),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                suggestion,
                style: AppStyles.bodyText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    onTap: () => _copyToClipboard(context, suggestion),
                  ),
                  const SizedBox(width: 16.0),
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'Use',
                    onTap: () => onSelect(suggestion),
                    isPrimary: true,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16.0,
              color: isPrimary ? Colors.blue : Colors.grey[700],
            ),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.blue : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Suggestion copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
