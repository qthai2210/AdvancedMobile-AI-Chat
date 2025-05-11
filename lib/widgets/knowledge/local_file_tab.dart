import 'package:flutter/material.dart';
import 'package:aichatbot/data/models/knowledge/uploaded_file_model.dart';

class LocalFileTab extends StatelessWidget {
  final bool isLoading;
  final List<UploadedFile> files;
  final VoidCallback onPick;
  final VoidCallback onImport;
  final ValueChanged<UploadedFile> onRemove;

  const LocalFileTab({
    super.key,
    required this.isLoading,
    required this.files,
    required this.onPick,
    required this.onRemove,
    required this.onImport,
  });

  @override
  Widget build(BuildContext c) {
    final canImport = files.isNotEmpty && !isLoading;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: isLoading ? null : onPick,
            icon: const Icon(Icons.upload_file),
            label: isLoading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(files.isEmpty ? 'Select file' : 'Change file'),
          ),

          // thêm phần hiển thị file đã chọn
          if (files.isNotEmpty) 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: files.map((f) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(f.name),
                        avatar: const Icon(Icons.insert_drive_file, size: 20),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => onRemove(f),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canImport ? onImport : null,
              child: isLoading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Import to Knowledge'),
            ),
          ),
        ],
      ),
    );
  }
}
