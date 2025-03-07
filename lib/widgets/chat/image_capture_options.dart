import 'package:flutter/material.dart';

/// A widget that displays options for capturing or selecting images for chat
class ImageCaptureOptions extends StatelessWidget {
  /// Function called when user wants to pick an image from gallery
  final VoidCallback onPickFromGallery;

  /// Function called when user wants to take a photo with camera
  final VoidCallback onTakePhoto;

  /// Function called when user wants to capture a screenshot
  final VoidCallback onCaptureScreenshot;

  /// Function called to close the options panel
  final VoidCallback onClose;

  const ImageCaptureOptions({
    Key? key,
    required this.onPickFromGallery,
    required this.onTakePhoto,
    required this.onCaptureScreenshot,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildOptionButtons(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Add image to conversation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildOptionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildOptionItem(
          icon: Icons.photo_library,
          label: 'Gallery',
          color: Colors.blue,
          onTap: onPickFromGallery,
        ),
        _buildOptionItem(
          icon: Icons.camera_alt,
          label: 'Camera',
          color: Colors.green,
          onTap: onTakePhoto,
        ),
        _buildOptionItem(
          icon: Icons.screenshot,
          label: 'Screenshot',
          color: Colors.purple,
          onTap: onCaptureScreenshot,
        ),
      ],
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
