import 'package:flutter/material.dart';
import 'package:aichatbot/widgets/knowledge/source_forms/base_source_form.dart';

class UrlSourceForm extends BaseSourceForm {
  final TextEditingController urlController;
  final bool shouldCrawlLinks;
  final int maxPagesToCrawl;
  final int crawlDepth;
  final ValueChanged<bool> onCrawlLinksChanged;
  final ValueChanged<double> onMaxPagesChanged;
  final ValueChanged<double> onCrawlDepthChanged;

  const UrlSourceForm({
    super.key,
    required this.urlController,
    required this.shouldCrawlLinks,
    required this.maxPagesToCrawl,
    required this.crawlDepth,
    required this.onCrawlLinksChanged,
    required this.onMaxPagesChanged,
    required this.onCrawlDepthChanged,
    required super.primaryColor,
  }) : super(
          title: 'Thêm từ URL Website',
          description: 'Hệ thống sẽ thu thập nội dung từ URL cung cấp',
        );

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUrlInput(),
        const SizedBox(height: 24),
        _buildCrawlerOptions(),
      ],
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
        buildSectionTitle('Tùy chọn thu thập dữ liệu'),
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
