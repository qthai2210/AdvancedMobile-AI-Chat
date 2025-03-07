import 'package:flutter/material.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/base_source_form.dart';

class FileSourceForm extends BaseSourceForm {
  final KnowledgeSourceType selectedType;
  final TextEditingController contentController;
  final String? selectedFileName;
  final ValueChanged<KnowledgeSourceType> onTypeChanged;
  final VoidCallback onSelectFile;
  final VoidCallback? onClearFile;

  const FileSourceForm({
    super.key,
    required this.selectedType,
    required this.contentController,
    this.selectedFileName,
    required this.onTypeChanged,
    required this.onSelectFile,
    this.onClearFile,
    required super.primaryColor,
  }) : super(
          title: 'Tải lên tệp',
          description: 'Hỗ trợ các định dạng: PDF, DOCX, TXT, CSV, JSON',
        );

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
