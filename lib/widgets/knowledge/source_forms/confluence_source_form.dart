import 'package:flutter/material.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/base_source_form.dart';

class ConfluenceSourceForm extends BaseSourceForm {
  final bool isConnected;
  final String? spaceName;
  final String? domainUrl;
  final List<String> selectedPages;
  final VoidCallback onConnect;
  final VoidCallback? onDisconnect;
  final Function(List<String>) onPagesSelected;

  const ConfluenceSourceForm({
    super.key,
    this.isConnected = false,
    this.spaceName,
    this.domainUrl,
    required this.selectedPages,
    required this.onConnect,
    this.onDisconnect,
    required this.onPagesSelected,
    required super.primaryColor,
  }) : super(
          title: 'Kết nối với Confluence',
          description: 'Thu thập dữ liệu từ trang Confluence của tổ chức bạn',
        );

  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: isConnected ? _buildConnectedState() : _buildNotConnectedState(),
    );
  }

  Widget _buildNotConnectedState() {
    return Column(
      children: [
        Image.asset(
          'assets/images/confluence_logo.png',
          height: 80,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.book_online, size: 80, color: Color(0xFF0052CC)),
        ),
        const SizedBox(height: 16),

        // Domain input for Confluence
        const TextField(
          decoration: InputDecoration(
            labelText: 'Confluence Domain',
            hintText: 'your-company.atlassian.net',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
        ),

        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onConnect,
          icon: const Icon(Icons.login),
          label: const Text('Kết nối với Confluence'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0052CC), // Confluence blue
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Bạn cần kết nối với Confluence để thu thập dữ liệu từ các không gian và trang',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildConnectedState() {
    return Column(
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
        const SizedBox(height: 8),
        Column(
          children: [
            const Text(
              'Đã kết nối với Confluence',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            if (domainUrl != null)
              Text(
                domainUrl!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSpaceAndPageSelection(),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onDisconnect,
          icon: const Icon(Icons.logout),
          label: const Text('Ngắt kết nối Confluence'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSpaceAndPageSelection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn không gian và trang',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Space selection
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Chọn không gian Confluence',
                border: OutlineInputBorder(),
              ),
              value: spaceName ?? 'Documentation',
              items: const [
                DropdownMenuItem(
                    value: 'Documentation', child: Text('Documentation')),
                DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                DropdownMenuItem(
                    value: 'Engineering', child: Text('Engineering')),
                DropdownMenuItem(value: 'HR', child: Text('HR')),
              ],
              onChanged: (value) {},
            ),

            const SizedBox(height: 16),

            // Page selection options
            const Text(
              'Tùy chọn thu thập trang:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            // Options for page collection
            RadioListTile<int>(
              title: const Text('Thu thập toàn bộ không gian'),
              value: 1,
              groupValue: 1,
              onChanged: (value) {},
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            RadioListTile<int>(
              title: const Text('Chỉ thu thập các trang được chọn'),
              value: 2,
              groupValue: 1,
              onChanged: (value) {},
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 8),
            const Text('Tùy chọn nâng cao:'),

            CheckboxListTile(
              title: const Text('Thu thập các trang con'),
              value: true,
              onChanged: (value) {},
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            CheckboxListTile(
              title: const Text('Thu thập tệp đính kèm'),
              value: false,
              onChanged: (value) {},
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            CheckboxListTile(
              title: const Text('Đồng bộ khi trang được cập nhật'),
              value: true,
              onChanged: (value) {},
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
