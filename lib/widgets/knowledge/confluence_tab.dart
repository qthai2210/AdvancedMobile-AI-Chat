import 'package:flutter/material.dart';

class ConfluenceTab extends StatelessWidget {
  final bool isLoading;
  final bool isConnected;
  final String? spaceName;
  final List<String> selectedPages;
  final VoidCallback onConnect;
  final VoidCallback onUpload;
  final ValueChanged<List<String>> onPagesSelected;

  const ConfluenceTab({
    Key? key,
    required this.isLoading,
    required this.isConnected,
    this.spaceName,
    required this.selectedPages,
    required this.onConnect,
    required this.onUpload,
    required this.onPagesSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canUpload = isConnected && selectedPages.isNotEmpty && !isLoading;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          isConnected
              ? Text('Space: $spaceName')
              : ElevatedButton(onPressed: onConnect, child: const Text('Connect to Confluence')),
          const SizedBox(height: 16),
          // Giả sử bạn có UI để chọn trang, gọi onPagesSelected khi chọn xong
          // …
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
                  : const Text('Upload Confluence Pages'),
            ),
          ),
        ],
      ),
    );
  }
}
