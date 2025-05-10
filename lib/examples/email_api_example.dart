import 'package:aichatbot/data/datasources/remote/email_api_service.dart';
import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';
import 'package:flutter/material.dart';

/// Example widget that demonstrates how to use the AI Email API
class AiEmailApiExample extends StatefulWidget {
  const AiEmailApiExample({Key? key}) : super(key: key);

  @override
  State<AiEmailApiExample> createState() => _AiEmailApiExampleState();
}

class _AiEmailApiExampleState extends State<AiEmailApiExample> {
  final _emailApiService = EmailApiService();
  bool _isLoading = false;
  String _responseText = '';
  String _errorText = '';

  Future<void> _generateEmail() async {
    setState(() {
      _isLoading = true;
      _responseText = '';
      _errorText = '';
    });

    try {
      // Create a sample request based on the provided example
      final request = AiEmailRequest(
        mainIdea: "Xin cảm ơn thông tin về Ngày hội. Tôi sẽ đăng ký tham gia sớm.",
        action: "Reply to this email",
        email: "Các bạn sinh viên thân mến, Trung tâm Hỗ trợ Sinh viên giới thiệu tới các bạn "Ngày Hội Sinh viên và Doanh nghiệp - Năm 2024" - Ngày hội việc làm là dịp để cho Sinh viên gặp gỡ, giao lưu, kết nối và tìm kiếm cơ hội việc làm ở rất nhiều lĩnh vực ngành nghề. Chương trình được tổ chức bởi Trung tâm Hỗ trợ sinh viên Trường Đại học Khoa học tự nhiên, ĐHQG-HCM dưới sự chỉ đạo của BGH Nhà trường. Thời gian: 7g30 ngày 03/11/2024 (Chủ nhật) Địa điểm: Sân trường Đại học Khoa học Tự nhiên, ĐHQG-HCM cơ sở 2 – Linh Trung, Khu đô thị Đại học Quốc gia tại Thành phố Thủ Đức.",
        metadata: AiEmailMetadata(
          context: [],
          subject: "ĐĂNG KÝ "NGÀY HỘI SINH VIÊN VÀ DOANH NGHIỆP - NĂM 2024"",
          sender: "TT Hỗ trợ sinh viên Trường ĐH Khoa học Tự nhiên, ĐHQG-HCM",
          receiver: "tthotrosinhvien@hcmus.edu.vn",
          style: const EmailStyleConfig(
            length: "long",
            formality: "neutral",
            tone: "friendly",
          ),
          language: "vietnamese",
        ),
      );

      // Call the API
      final response = await _emailApiService.generateAiEmail(request: request);
      
      setState(() {
        _responseText = '''
Generated Email:
${response.email}

Remaining Usage: ${response.remainingUsage}

Improved Actions: ${response.improvedActions.join(', ')}
''';
      });
    } catch (e) {
      setState(() {
        _errorText = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Email Generation Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _generateEmail,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Generate Email Reply'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorText.isNotEmpty)
                      Text(_errorText, style: const TextStyle(color: Colors.red)),
                    if (_responseText.isNotEmpty)
                      Text(_responseText, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
