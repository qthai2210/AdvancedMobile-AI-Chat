import 'package:flutter/material.dart';

class UrlSourceForm extends StatelessWidget {
  final TextEditingController urlController;
  final bool shouldCrawlLinks;
  final int maxPagesToCrawl;
  final int crawlDepth;
  final ValueChanged<bool> onCrawlLinksChanged;
  final ValueChanged<double> onMaxPagesChanged;
  final ValueChanged<double> onCrawlDepthChanged;
  final Color primaryColor;

  const UrlSourceForm({
    super.key,
    required this.urlController,
    required this.shouldCrawlLinks,
    required this.maxPagesToCrawl,
    required this.crawlDepth,
    required this.onCrawlLinksChanged,
    required this.onMaxPagesChanged,
    required this.onCrawlDepthChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thêm từ URL Website'),
        const SizedBox(height: 8),
        const Text(
          'Hệ thống sẽ thu thập nội dung từ URL cung cấp',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        _buildUrlInput(),
        const SizedBox(height: 24),
        _buildCrawlerOptions(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
    );
  }

  Widget _buildUrlInput() {
    return TextFormField(
      controller: urlController,
      decoration: const InputDecoration(
        labelText: 'URL Website *',
        hintText: 'https://example.com/page',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.link),
      ),
      keyboardType: TextInputType.url,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập URL';
        }
        if (!value.startsWith('http://') && !value.startsWith('https://')) {
          return 'URL phải bắt đầu bằng http:// hoặc https://';
        }
        return null;
      },
    );
  }

  Widget _buildCrawlerOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tùy chọn thu thập dữ liệu'),
        const SizedBox(height: 8),
        _buildCrawlerToggle(),
        if (shouldCrawlLinks) _buildAdvancedCrawlerOptions(),
      ],
    );
  }

  Widget _buildCrawlerToggle() {
    return SwitchListTile(
      title: const Text('Thu thập các liên kết'),
      subtitle: const Text('Thu thập nội dung từ các liên kết trong trang'),
      value: shouldCrawlLinks,
      onChanged: onCrawlLinksChanged,
    );
  }

  Widget _buildAdvancedCrawlerOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSliderOption(
          'Số trang tối đa thu thập',
          maxPagesToCrawl.toDouble(),
          1,
          50,
          49,
          onMaxPagesChanged,
          'Giá trị: $maxPagesToCrawl trang',
        ),
        const SizedBox(height: 16),
        _buildSliderOption(
          'Độ sâu thu thập',
          crawlDepth.toDouble(),
          1,
          5,
          4,
          onCrawlDepthChanged,
          'Giá trị: $crawlDepth',
        ),
      ],
    );
  }

  Widget _buildSliderOption(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
    String valueText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toInt().toString(),
          onChanged: onChanged,
        ),
        Text(
          valueText,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
