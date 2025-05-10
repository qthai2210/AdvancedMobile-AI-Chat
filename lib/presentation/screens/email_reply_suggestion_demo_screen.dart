import 'package:aichatbot/core/di/injection_container.dart';
import 'package:aichatbot/data/datasources/remote/email_api_service.dart';
import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A screen to test the email reply suggestion API with direct API implementation
///
/// This implementation allows users to input all required parameters and test
/// the API with various inputs matching the expected structure:
/// {
///   "action": "Suggest 3 ideas for this email",
///   "email": "Email content...",
///   "metadata": {
///     "context": [],
///     "subject": "Email subject",
///     "sender": "Sender email",
///     "receiver": "Receiver email",
///     "language": "vietnamese"
///   }
/// }
class EmailReplySuggestionDemoScreen extends StatefulWidget {
  const EmailReplySuggestionDemoScreen({Key? key}) : super(key: key);

  @override
  State<EmailReplySuggestionDemoScreen> createState() =>
      _EmailReplySuggestionDemoScreenState();
}

class _EmailReplySuggestionDemoScreenState
    extends State<EmailReplySuggestionDemoScreen> {
  final _emailApiService = sl<EmailApiService>();
  // Form controllers
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _senderController = TextEditingController();
  final _receiverController = TextEditingController();
  // Language selection
  final List<String> _availableLanguages = [
    'vietnamese',
    'english',
    'spanish',
    'french',
    'german',
    'chinese',
    'japanese'
  ];
  String _selectedLanguage = 'vietnamese';

  // Action options
  final List<String> _availableActions = [
    'Suggest 3 ideas for this email',
    'Suggest 5 ideas for this email',
    'Create a professional response',
    'Create a friendly response',
    'Draft a detailed reply',
    'Write a concise reply',
    'Create a polite rejection',
  ];
  String _selectedAction = 'Suggest 3 ideas for this email';

  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  bool _isLoading = false;
  String _resultMessage = '';
  List<String> _suggestions = [];
  @override
  void initState() {
    super.initState();
    // Initialize with the Vietnamese email example
    _loadVietnameseExample();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _senderController.dispose();
    _receiverController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Load the Vietnamese email example
  void _loadVietnameseExample() {
    _subjectController.text =
        'ĐĂNG KÝ "NGÀY HỘI SINH VIÊN VÀ DOANH NGHIỆP - NĂM 2024"';
    _senderController.text =
        'TT Hỗ trợ sinh viên Trường ĐH Khoa học Tự nhiên, ĐHQG-HCM';
    _receiverController.text = 'tthotrosinhvien@hcmus.edu.vn';
    _selectedLanguage = 'vietnamese';
    _selectedAction = 'Suggest 3 ideas for this email';

    _emailController.text = '''Các bạn sinh viên thân mến,

Trung tâm Hỗ trợ Sinh viên giới thiệu tới các bạn "Ngày Hội Sinh viên và Doanh nghiệp - Năm 2024" - Ngày hội việc làm là dịp để cho Sinh viên gặp gỡ, giao lưu, kết nối và tìm kiếm cơ hội việc làm ở rất nhiều lĩnh vực ngành nghề.

Chương trình được tổ chức bởi Trung tâm Hỗ trợ sinh viên Trường Đại học Khoa học tự nhiên, ĐHQG-HCM dưới sự chỉ đạo của BGH Nhà trường.

Thời gian: 7g30 ngày 03/11/2024 (Chủ nhật)
Địa điểm: Sân trường Đại học Khoa học Tự nhiên, ĐHQG-HCM cơ sở 2 – Linh Trung, Khu đô thị Đại học Quốc gia tại Thành phố Thủ Đức.

______________________

Năm nay, "Ngày hội Sinh viên và Doanh nghiệp năm 2024" mang đến cho bạn:
28 Doanh nghiệp tham gia;
30 Sàn dịch vụ - việc làm;
200 Công việc full time/part time;
17 Gian hàng dịch vụ thầy cô, sinh viên, CLB – Đội – Nhóm;
02 Chương trình, hội thảo kỹ năng - hướng nghiệp dành cho các bạn sinh viên;
10 Địa điểm phỏng vấn cực HOT.

Bên cạnh đó, Ngày hội mang tới hơn 1000 món quà hấp dẫn như: balo, túi xách, áo polo,...

Để đăng ký tham gia:
Bước 1: Đăng kí theo link: https://docs.google.com/forms/d/e/1FAIpQLSc1uJXxOaXyEVs0YIj6pnWT0DM6b4dvlBGx89SCgAuAvF1KgA/viewform
Bước 2: Nhận vé mời tại Trung tâm ở hai cơ sở. Nếu bạn không có thời gian có thể nhận tại cổng Ngày hội, ngày 03/11/2024

!!! Đây là hoạt động có tính điểm rèn luyện nhé!!!

Chi tiết ngày Hội xem tại:

Hẹn gặp các bạn ở "Ngày hội Sinh viên và Doanh nghiệp - Năm 2024" vào ngày 03/11/2024

________________________________
Mọi thông tin liên hệ
TRUNG TÂM HỖ TRỢ SINH VIÊN
Email: tthotrosinhvien@hcmus.edu.vn
Website: sacus.vn
Tel: 028 38 320 287''';
  }

  // Clear form fields
  void _clearForm() {
    setState(() {
      _subjectController.clear();
      _senderController.clear();
      _receiverController.clear();
      _selectedLanguage = 'vietnamese';
      _selectedAction = 'Suggest 3 ideas for this email';
      _emailController.clear();
      _resultMessage = '';
      _suggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Reply API'),
        actions: [
          // Reload Vietnamese example button
          IconButton(
            onPressed: _loadVietnameseExample,
            icon: const Icon(Icons.refresh),
            tooltip: 'Load Vietnamese Example',
          ),
          // Clear form button
          IconButton(
            onPressed: _clearForm,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use different layouts based on available width
          if (constraints.maxWidth > 800 && _suggestions.isNotEmpty) {
            // Wide layout: Form and suggestions side by side
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.5,
                  child: _buildForm(),
                ),
                if (_isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Expanded(
                    child: _buildSuggestionsList(),
                  ),
              ],
            );
          } else {
            // Narrow layout: Form and suggestions stacked
            return Column(
              children: [
                Expanded(
                  child: _buildForm(),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_suggestions.isNotEmpty)
                  SizedBox(
                    height: constraints.maxHeight * 0.4,
                    child: _buildSuggestionsList(),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject field (part of metadata)
              _buildFormSection(
                title: 'Subject',
                child: TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    hintText:
                        'ĐĂNG KÝ "NGÀY HỘI SINH VIÊN VÀ DOANH NGHIỆP - NĂM 2024"',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),

              // Sender field (part of metadata)
              _buildFormSection(
                title: 'Sender',
                child: TextFormField(
                  controller: _senderController,
                  decoration: const InputDecoration(
                    labelText: 'Sender',
                    hintText:
                        'TT Hỗ trợ sinh viên Trường ĐH Khoa học Tự nhiên, ĐHQG-HCM',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),

              // Receiver field (part of metadata)
              _buildFormSection(
                title: 'Receiver',
                child: TextFormField(
                  controller: _receiverController,
                  decoration: const InputDecoration(
                    labelText: 'Receiver',
                    hintText: 'tthotrosinhvien@hcmus.edu.vn',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),

              // Language field (part of metadata)
              _buildFormSection(
                title: 'Language',
                child: DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableLanguages.map((language) {
                    return DropdownMenuItem(
                      value: language,
                      child: Text(
                        language.substring(0, 1).toUpperCase() +
                            language.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                  validator: (value) => value == null ? 'Required' : null,
                ),
              ),
              // Action field
              _buildFormSection(
                title: 'Action',
                child: DropdownButtonFormField<String>(
                  value: _selectedAction,
                  decoration: const InputDecoration(
                    labelText: 'Action',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableActions.map((action) {
                    return DropdownMenuItem(
                      value: action,
                      child: Text(action),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAction = value!;
                    });
                  },
                  validator: (value) => value == null ? 'Required' : null,
                ),
              ),

              // Email content field
              _buildFormSection(
                title: 'Email Content',
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Content',
                    hintText: 'Paste your email content here...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 10,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),

              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _fetchSuggestions,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isLoading
                        ? 'Getting Suggestions...'
                        : 'Get Reply Suggestions',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              if (_resultMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _suggestions.isNotEmpty
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            _suggestions.isNotEmpty ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(_resultMessage),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Suggested Replies',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _fetchSuggestions,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return _buildSuggestionCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Idea ${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(_suggestions[index]),
                  tooltip: 'Copy to clipboard',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _suggestions[index],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchSuggestions() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _resultMessage = '';
      _suggestions = [];
    });

    try {
      // Create metadata directly
      final metadata = AiEmailReplyIdeasMetadata(
        context: [], // Empty context as per request
        subject: _subjectController.text,
        sender: _senderController.text,
        receiver: _receiverController.text,
        language: _selectedLanguage,
      );
      // Create request directly
      final request = EmailReplySuggestionRequest(
        email: _emailController.text,
        action: _selectedAction,
        metadata: metadata,
        model: 'dify', // Default model
      );

      // Call the API service directly
      final response = await _emailApiService.getSuggestionReplies(
        request: request,
      );

      // Update the state with the results
      setState(() {
        _isLoading = false;
        _suggestions = response.ideas;
        if (response.ideas.isEmpty) {
          _resultMessage = 'No suggestions returned from the API';
        } else {
          _resultMessage =
              'Successfully fetched ${response.ideas.length} suggestions';

          // Scroll to see results if there are suggestions
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;

        // Format error message for better display
        String errorMessage;
        if (e.toString().contains('UnauthorizedException')) {
          errorMessage =
              'Authentication failed. Please check your credentials.';
        } else if (e.toString().contains('ServerException')) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }

        _resultMessage = errorMessage;
      });

      // Show a snackbar with the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to get suggestions: ${e.toString().split(':').last}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reply copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
