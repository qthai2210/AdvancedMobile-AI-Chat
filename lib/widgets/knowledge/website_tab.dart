import 'package:flutter/material.dart';

class WebsiteTab extends StatelessWidget {
  final bool isLoading;
  final TextEditingController nameCtl;
  final TextEditingController urlCtl;
  final VoidCallback onUpload;

  const WebsiteTab({
    super.key,
    required this.isLoading,
    required this.nameCtl,
    required this.urlCtl,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext c) {
    final canUpload =
        nameCtl.text.trim().isNotEmpty &&
        urlCtl.text.trim().isNotEmpty &&
        !isLoading;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            controller: nameCtl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: urlCtl,
            decoration: const InputDecoration(labelText: 'URL'),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canUpload ? onUpload : null,
              child: isLoading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Upload Website'),
            ),
          ),
        ],
      ),
    );
  }
}
