import 'package:flutter/material.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/base_source_form.dart';

class SlackSourceForm extends BaseSourceForm {
  final bool isConnected;
  final String? workspaceName;
  final List<String> selectedChannels;
  final VoidCallback onConnect;
  final VoidCallback? onDisconnect;
  final Function(List<String>) onChannelsSelected;

  const SlackSourceForm({
    super.key,
    this.isConnected = false,
    this.workspaceName,
    required this.selectedChannels,
    required this.onConnect,
    this.onDisconnect,
    required this.onChannelsSelected,
    required super.primaryColor,
  }) : super(
          title: 'Kết nối với Slack',
          description:
              'Thu thập dữ liệu từ các kênh và cuộc trò chuyện trong Slack',
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
          'assets/images/slack_logo.png',
          height: 80,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.forum, size: 80, color: Color(0xFF4A154B)),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onConnect,
          icon: const Icon(Icons.login),
          label: const Text('Kết nối với Slack'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A154B), // Slack purple
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Bạn cần kết nối với Slack để thu thập dữ liệu từ các kênh và cuộc trò chuyện',
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
        Text(
          'Đã kết nối với workspace: ${workspaceName ?? "Workspace"}',
          style:
              const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildChannelSelection(),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onDisconnect,
          icon: const Icon(Icons.logout),
          label: const Text('Ngắt kết nối Slack'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildChannelSelection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn các kênh cần thu thập dữ liệu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Mock channel selection - in a real app, this would be a proper multi-select
            const Text(
              'Chọn kênh:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Mock selected channels display
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChannelChip('#general', true),
                _buildChannelChip('#random', false),
                _buildChannelChip('#support', false),
                _buildChannelChip('#marketing', false),
                _buildChannelChip('#engineering', false),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              'Tùy chọn nâng cao:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),

            // Options for data collection
            CheckboxListTile(
              title: const Text('Thu thập tin nhắn riêng tư'),
              subtitle: const Text('Yêu cầu quyền truy cập bổ sung'),
              value: false,
              onChanged: (value) {},
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            CheckboxListTile(
              title: const Text('Thu thập các cuộc hội thoại trong thread'),
              value: true,
              onChanged: (value) {},
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            CheckboxListTile(
              title: const Text('Đồng bộ liên tục'),
              subtitle: const Text('Cập nhật dữ liệu khi có tin nhắn mới'),
              value: false,
              onChanged: (value) {},
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelChip(String channelName, bool isSelected) {
    return FilterChip(
      selected: isSelected,
      label: Text(channelName),
      onSelected: (selected) {
        // Update selected channels
      },
      selectedColor: const Color(0xFF4A154B).withOpacity(0.2),
    );
  }
}
