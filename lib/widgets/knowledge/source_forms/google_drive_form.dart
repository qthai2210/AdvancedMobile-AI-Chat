import 'package:flutter/material.dart';

// Update the GoogleDriveForm to include fileId
class GoogleDriveForm extends StatelessWidget {
  final String? selectedDriveFileName;
  final String? selectedDriveFileId;
  final VoidCallback onConnectDrive;
  final VoidCallback onClearSelection;
  final VoidCallback onSelectDifferent;
  final Color primaryColor;

  const GoogleDriveForm({
    Key? key,
    this.selectedDriveFileName,
    this.selectedDriveFileId,
    required this.onConnectDrive,
    required this.onClearSelection,
    required this.onSelectDifferent,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add your Google Drive form UI here
          // Title and description
          _buildSectionHeader(
            context,
            "Google Drive Connection",
            "Link documents from your Google Drive account",
            Icons.cloud,
          ),
          const SizedBox(height: 24),

          // Display selected file or connect button
          if (selectedDriveFileName != null)
            _buildSelectedGDriveFile(context)
          else
            _buildConnectGDriveButton(context),

          const SizedBox(height: 24),

          // Additional instructions
          _buildInstructions(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  Widget _buildSelectedGDriveFile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.description, color: Colors.blue[700]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedDriveFileName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Google Drive File',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClearSelection,
                tooltip: 'Remove selection',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onSelectDifferent,
                icon: const Icon(Icons.refresh),
                label: const Text('Select Different File'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectGDriveButton(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud,
              size: 40,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Connect to your Google Drive',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Import files directly from your Google Drive account',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onConnectDrive,
            icon: const Icon(Icons.login),
            label: const Text('Connect Google Drive'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                "Google Drive Integration",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "• Connects to your Google Drive account securely",
            style: TextStyle(fontSize: 14),
          ),
          const Text(
            "• Select documents, spreadsheets, PDFs and more",
            style: TextStyle(fontSize: 14),
          ),
          const Text(
            "• Permissions are limited to file access only",
            style: TextStyle(fontSize: 14),
          ),
          const Text(
            "• Your Google account credentials are never stored",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
