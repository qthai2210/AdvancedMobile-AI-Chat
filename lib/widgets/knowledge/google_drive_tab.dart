import 'package:flutter/material.dart';

class GoogleDriveTab extends StatelessWidget {
  final bool isLoading;
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onUpload;

  const GoogleDriveTab({
    Key? key,
    required this.isLoading,
    required this.fileName,
    required this.onPick,
    required this.onUpload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canUpload = fileName != null && !isLoading;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (fileName != null)
            Row(
              children: [
                Expanded(child: Text(fileName!)),
                IconButton(onPressed: onPick, icon: const Icon(Icons.edit)),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: isLoading ? null : onPick,
              icon: const Icon(Icons.drive_file_rename_outline),
              label: const Text('Select from Drive'),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canUpload ? onUpload : null,
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Upload to Knowledge'),
            ),
          ),
        ],
      ),
    );
  }
}
