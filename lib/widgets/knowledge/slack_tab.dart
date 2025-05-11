import 'package:flutter/material.dart';

class SlackTab extends StatelessWidget {
  final bool isLoading;
  final TextEditingController nameCtl;
  final TextEditingController tokenCtl;
  final VoidCallback onUpload;

  const SlackTab({
    Key? key,
    required this.isLoading,
    required this.nameCtl,
    required this.tokenCtl,
    required this.onUpload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canUpload = nameCtl.text.trim().isNotEmpty &&
        tokenCtl.text.trim().isNotEmpty &&
        !isLoading;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 16),
          TextField(controller: tokenCtl, decoration: const InputDecoration(labelText: 'Bot Token')),
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
                  : const Text('Import to Knowledge'),
            ),
          ),
        ],
      ),
    );
  }
}
