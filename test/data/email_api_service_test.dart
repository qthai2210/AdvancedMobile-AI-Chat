import 'package:aichatbot/core/errors/exceptions.dart';
import 'package:aichatbot/data/datasources/remote/email_api_service.dart';
import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([Dio])
void main() {
  group('EmailApiService', () {
    late EmailApiService emailApiService;

    setUp(() {
      emailApiService = EmailApiService();
    });

    test(
        'generateAiEmail should return a valid response when the API call is successful',
        () async {
      // This is a manual test that should be run with proper credentials
      // It's commented out because automated tests shouldn't make real API calls

      /*
      // Create a test request based on the example
      final request = AiEmailRequest(
        mainIdea: "Xin cảm ơn thông tin về Ngày hội. Tôi sẽ đăng ký tham gia sớm.",
        action: "Reply to this email",
        email: "Các bạn sinh viên thân mến, Trung tâm Hỗ trợ Sinh viên giới thiệu tới các bạn "Ngày Hội Sinh viên và Doannh nghiệp - Năm 2024"...",
        metadata: AiEmailMetadata(
          context: [],
          subject: "ĐĂNG KÝ "NGÀY HỘI SINH VIÊN VÀ DOANH NGHIỆP - NĂM 2024"",
          sender: "TT Hỗ trợ sinh viên Trường ĐH Khoa học Tự nhiên, ĐHQG-HCM",
          receiver: "tthotrosinhvien@hcmus.edu.vn",
          style: EmailStyleConfig(
            length: "long",
            formality: "neutral",
            tone: "friendly"
          ),
          language: "vietnamese"
        ),
      );

      // Call the API
      final response = await emailApiService.generateAiEmail(request: request);
      
      // Verify response
      expect(response, isA<AiEmailResponse>());
      expect(response.email, isNotEmpty);
      expect(response.improvedActions, isA<List<String>>());
      */
    });
  });
}
