import 'package:flutter/material.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';

class FileSourceForm extends StatelessWidget {
  final KnowledgeSourceType selectedType;
  final TextEditingController contentController;
  final String? selectedFileName;
  final ValueChanged<KnowledgeSourceType> onTypeChanged;
  final VoidCallback onSelectFile;
  final VoidCallback? onClearFile;
  final Color primaryColor;

  const FileSourceForm({
    super.key,
    required this.selectedType,
    required this.contentController,
    this.selectedFileName,
    required this.onTypeChanged,
    required this.onSelectFile,
    this.onClearFile,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tải lên tệp',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hỗ trợ các định dạng: PDF, DOCX, TXT, CSV, JSON',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // File type selection dropdown
        DropdownButtonFormField<KnowledgeSourceType>(
          value: selectedType,
          decoration: const InputDecoration(
            labelText: 'Loại tệp *',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: KnowledgeSourceType.pdf,
              child: Text('PDF'),
            ),
            DropdownMenuItem(
              value: KnowledgeSourceType.docx,
              child: Text('Word Document (DOCX)'),
            ),
            DropdownMenuItem(
              value: KnowledgeSourceType.text,
              child: Text('Text (TXT)'),
            ),
            DropdownMenuItem(
              value: KnowledgeSourceType.csv,
              child: Text('CSV'),
            ),
            DropdownMenuItem(
              value: KnowledgeSourceType.json,
              child: Text('JSON'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onTypeChanged(value);
            }
          },
        ),
        const SizedBox(height: 16),

        // File selection or text input based on file type
        if (selectedType != KnowledgeSourceType.text)
          _buildFileUploader(context)
        else
          _buildTextEditor(),
      ],
    );
  }

  Widget _buildFileUploader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: onSelectFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('Chọn tệp'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          if (selectedFileName != null)
            Chip(
              label: Text(selectedFileName!),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: onClearFile,
            ),
        ],
      ),
    );
  }

  Widget _buildTextEditor() {
    return TextFormField(
      controller: contentController,
      decoration: const InputDecoration(
        labelText: 'Nội dung văn bản *',
        hintText: 'Nhập nội dung văn bản ở đây...',
        border: OutlineInputBorder(),
      ),
      maxLines: 10,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập nội dung';
        }
        return null;
      },
    );
  }
}
