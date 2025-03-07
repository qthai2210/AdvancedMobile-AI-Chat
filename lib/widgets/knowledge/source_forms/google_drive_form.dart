import 'package:flutter/material.dart';

class GoogleDriveForm extends StatelessWidget {
  final String? selectedDriveFileName;
  final VoidCallback onConnectDrive;
  final VoidCallback? onClearSelection;
  final VoidCallback? onSelectDifferent;
  final Color primaryColor;

  const GoogleDriveForm({
    super.key,
    this.selectedDriveFileName,
    required this.onConnectDrive,
    this.onClearSelection,
    this.onSelectDifferent,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kết nối với Google Drive',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nhập dữ liệu từ tài khoản Google Drive của bạn',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Google Drive connection
        Center(
          child: Column(
            children: [
              if (selectedDriveFileName == null) ...[
                _buildNotConnectedState(context),
              ] else ...[
                _buildConnectedState(context),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotConnectedState(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/google_drive.png',
          height: 80,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.cloud, size: 80, color: Colors.blue),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onConnectDrive,
          icon: const Icon(Icons.login),
          label: const Text('Kết nối Google Drive'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4285F4), // Google blue
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedState(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
        const SizedBox(height: 8),
        const Text('Đã kết nối với Google Drive',
            style: TextStyle(color: Colors.green)),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading:
                const Icon(Icons.insert_drive_file, color: Color(0xFF4285F4)),
            title: Text(selectedDriveFileName!),
            subtitle: const Text('Google Drive Document'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClearSelection,
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onSelectDifferent ?? onConnectDrive,
          icon: const Icon(Icons.refresh),
          label: const Text('Chọn tệp khác'),
        ),
      ],
    );
  }
}
