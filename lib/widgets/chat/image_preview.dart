import 'package:flutter/material.dart';
import 'dart:io';

/// Widget for displaying a preview of an image before sending
class ImagePreview extends StatelessWidget {
  /// The image file to preview
  final File imageFile;

  /// Called when the image is removed
  final VoidCallback onRemove;

  /// Additional text message to be sent with the image
  final TextEditingController messageController;

  const ImagePreview({
    Key? key,
    required this.imageFile,
    required this.onRemove,
    required this.messageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.image, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Image preview',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildImagePreview(),
          const SizedBox(height: 8),
          const Text(
            'Add a message to send along with this image (optional)',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          // Image preview
          Image.file(
            imageFile,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // Gradient overlay at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                _getFileName(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFileName() {
    // Extract file name from path
    final filePath = imageFile.path;
    return filePath.substring(filePath.lastIndexOf('/') + 1);
  }
}
