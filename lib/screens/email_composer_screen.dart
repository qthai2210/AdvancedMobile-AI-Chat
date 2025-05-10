import 'package:flutter/material.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class EmailComposerScreen extends StatefulWidget {
  const EmailComposerScreen({Key? key}) : super(key: key);

  @override
  State<EmailComposerScreen> createState() => _EmailComposerScreenState();
}

class _EmailComposerScreenState extends State<EmailComposerScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isGenerating = false;
  bool _showCc = false;
  String _selectedAction = '';
  String _selectedLanguage = 'english';
  final List<String> _availableLanguages = [
    'english',
    'vietnamese',
    'spanish',
    'french',
    'german',
    'chinese',
    'japanese'
  ];
  @override
  void dispose() {
    _toController.dispose();
    _ccController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Composer'),
        elevation: 0,
        actions: [
          // Demo button for the Vietnamese email example
          IconButton(
            icon: const Icon(Icons.science_outlined),
            onPressed: () => context.push('/email/reply-suggestions-demo'),
            tooltip: 'Try Demo with Vietnamese Email',
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendEmail,
            tooltip: 'Send Email',
          ),
        ],
      ),
      drawer: MainAppDrawer(
        currentIndex: 1,
        onTabSelected: (index) => navigation_utils.handleDrawerNavigation(
          context,
          index,
          currentIndex: 1,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          _buildEmailForm(),
          _buildAIActions(),
          Expanded(child: _buildEmailPreview()),
        ],
      ),
    );
  }

  Widget _buildEmailForm() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
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
                Expanded(
                  child: TextField(
                    controller: _toController,
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showCc
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                  tooltip: _showCc ? 'Hide CC' : 'Add CC',
                  onPressed: () {
                    setState(() {
                      _showCc = !_showCc;
                    });
                  },
                ),
              ],
            ),
            if (_showCc) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _ccController,
                decoration: const InputDecoration(
                  labelText: 'CC',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Language:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(),
                      isDense: true,
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIActions() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
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
                const Icon(Icons.auto_awesome, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'AI Email Assistant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Select a template:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: [
                _buildActionButton('Thanks', Icons.favorite, Colors.pink),
                _buildActionButton(
                    'Sorry', Icons.sentiment_neutral, Colors.orange),
                _buildActionButton('Yes', Icons.check_circle, Colors.green),
                _buildActionButton('No', Icons.cancel, Colors.red),
                _buildActionButton('Follow Up', Icons.update, Colors.blue),
                _buildActionButton(
                    'More Info', Icons.help_outline, Colors.purple),
              ],
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _getEmailReplySuggestions,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Get AI Reply Suggestions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String action, IconData icon, Color color) {
    bool isSelected = _selectedAction == action;

    return ElevatedButton.icon(
      icon: Icon(icon, color: isSelected ? Colors.white : color, size: 18),
      label: Text(action),
      onPressed: () => _generateEmail(action),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : color.withOpacity(0.1),
        foregroundColor: isSelected ? Colors.white : color,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.transparent : color.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildEmailPreview() {
    if (_isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Generating email content...'),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.email, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Email Content',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: _copyEmailContent,
                  tooltip: 'Copy Content',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _clearEmailContent,
                  tooltip: 'Clear Content',
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  hintText: 'Your email content will appear here...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generateEmail(String action) {
    setState(() {
      _isGenerating = true;
      _selectedAction = action;
    });

    // Request would go to API in a real implementation
    Future.delayed(const Duration(milliseconds: 800), () {
      String emailBody = '';
      String subject = '';

      // Get recipient name from To field, or use generic greeting
      String recipient = _toController.text.isNotEmpty
          ? _toController.text.split('@').first
          : 'Recipient';
      recipient = recipient.split(' ').first; // Use first name only

      switch (action) {
        case 'Thanks':
          subject = 'Thank you for your message';
          emailBody = '''Dear $recipient,

Thank you for your email. I appreciate you taking the time to reach out.

I've received your message and will review the materials you sent. Your input is valuable to our progress.

Best regards,
[Your Name]''';
          break;

        case 'Sorry':
          subject = 'Apologies regarding our recent communication';
          emailBody = '''Dear $recipient,

I wanted to apologize for the delay in our response to your inquiry.

We're working to address the concerns you raised and will have a comprehensive update for you shortly.

Sincerely,
[Your Name]''';
          break;

        case 'Yes':
          subject = 'Confirmation: Project Approval';
          emailBody = '''Dear $recipient,

I'm writing to confirm that we can proceed with the project as discussed.

We're looking forward to moving ahead with the next steps and will meet all agreed deadlines.

Best regards,
[Your Name]''';
          break;

        case 'No':
          subject = 'Regarding your recent request';
          emailBody = '''Dear $recipient,

After careful consideration, we regret to inform you that we won't be able to proceed with the request as outlined.

This decision was made due to [reason]. We'd be happy to discuss alternative approaches that might better meet our mutual goals.

Regards,
[Your Name]''';
          break;

        case 'Follow Up':
          subject = 'Follow-up on our discussion';
          emailBody = '''Dear $recipient,

I'm following up on our previous conversation about the project.

Have you had a chance to review the materials I sent? I'm available to discuss any questions you might have.

Looking forward to your response,
[Your Name]''';
          break;

        case 'More Info':
          subject = 'Additional information needed';
          emailBody = '''Dear $recipient,

Regarding our ongoing project, I need some additional information before we can proceed:

1. [Specific question 1]
2. [Specific question 2]
3. [Specific question 3]

This information will help us ensure we meet all project requirements and deadlines.

Thanks in advance,
[Your Name]''';
          break;
      }

      setState(() {
        _isGenerating = false;
        _subjectController.text = subject;
        _bodyController.text = emailBody;
      });
    });
  }

  void _copyEmailContent() {
    if (_bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No content to copy'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: _bodyController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Email content copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearEmailContent() {
    setState(() {
      _bodyController.text = '';
    });
  }

  void _sendEmail() {
    if (_toController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in recipient, subject and email content'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // In a real app, this would send the email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 16),
            Text('Email sent successfully'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Clear form
    _toController.clear();
    _ccController.clear();
    _subjectController.clear();
    _bodyController.clear();
    setState(() {
      _selectedAction = '';
    });
  }

  /// Navigate to the Email Reply Suggestions screen to get ideas for replying
  void _getEmailReplySuggestions() {
    // Make sure we have an email body to analyze
    if (_bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter an email content first'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    // Prepare parameters for the suggestions screen
    final params = {
      'email': _bodyController.text,
      'subject': _subjectController.text.isNotEmpty
          ? _subjectController.text
          : 'No subject',
      'sender': 'me@example.com', // In a real app, get from user profile
      'receiver': _toController.text.isNotEmpty
          ? _toController.text
          : 'recipient@example.com',
      'language': _selectedLanguage, // Using the selected language
    };

    // Navigate to suggestions screen and wait for result
    context
        .push('/email/reply-suggestions', extra: params)
        .then((selectedIdea) {
      // If user selected an idea, use it as the email body
      if (selectedIdea != null && selectedIdea is String) {
        setState(() {
          _bodyController.text = selectedIdea;
        });
      }
    });
  }
}
