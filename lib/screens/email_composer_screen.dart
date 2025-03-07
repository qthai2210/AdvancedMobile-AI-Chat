import 'package:flutter/material.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;

class EmailComposerScreen extends StatefulWidget {
  const EmailComposerScreen({Key? key}) : super(key: key);

  @override
  State<EmailComposerScreen> createState() => _EmailComposerScreenState();
}

class _EmailComposerScreenState extends State<EmailComposerScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool _isGenerating = false;
  String _selectedAction = '';

  // Mock data for context
  final Map<String, String> _emailContext = {
    'recipientName': 'Alex Johnson',
    'lastEmail': 'Please review the project proposal I sent last week.',
    'project': 'Marketing Campaign',
    'deadline': 'October 15th',
  };

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Composer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendEmail,
            tooltip: 'Send Email',
          ),
        ],
      ),
      drawer: MainAppDrawer(
        currentIndex: 4, // Replace History with Email Composer (index 4)
        onTabSelected: (index) => navigation_utils.handleDrawerNavigation(
          context,
          index,
          currentIndex: 4,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildEmailForm(),
        _buildAIActions(),
        Expanded(child: _buildEmailPreview()),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _toController,
            decoration: const InputDecoration(
              labelText: 'To',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.subject),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIActions() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Draft with AI',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String action, IconData icon, Color color) {
    bool isSelected = _selectedAction == action;

    return ElevatedButton.icon(
      icon: Icon(icon, color: isSelected ? Colors.white : color, size: 16),
      label: Text(action),
      onPressed: () => _generateEmail(action),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : color.withOpacity(0.1),
        foregroundColor: isSelected ? Colors.white : color,
      ),
    );
  }

  Widget _buildEmailPreview() {
    if (_isGenerating) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Icon(Icons.email, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Email Preview',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: _editEmailContent,
                  tooltip: 'Edit Content',
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _bodyController,
                maxLines: null,
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

    // In a real app, this would call an AI service
    // For now, we'll use mock responses
    Future.delayed(const Duration(seconds: 1), () {
      String emailBody = '';
      String subject = '';

      switch (action) {
        case 'Thanks':
          subject = 'Thank you for your message';
          emailBody = '''Dear ${_emailContext['recipientName']},

Thank you for your email regarding the ${_emailContext['project']}. I appreciate you taking the time to reach out.

I've received your message and will review the materials you sent. Your input is valuable to our progress.

Best regards,
[Your Name]''';
          break;

        case 'Sorry':
          subject = 'Apologies regarding our recent communication';
          emailBody = '''Dear ${_emailContext['recipientName']},

I wanted to apologize regarding the delay in our response to your inquiry about the ${_emailContext['project']}.

We're working to address the concerns you raised and will have a comprehensive update for you shortly.

Sincerely,
[Your Name]''';
          break;

        case 'Yes':
          subject = 'Confirmation: ${_emailContext['project']}';
          emailBody = '''Dear ${_emailContext['recipientName']},

I'm writing to confirm that we can proceed with the ${_emailContext['project']} as discussed.

We're looking forward to moving ahead with the next steps and will meet the deadline of ${_emailContext['deadline']}.

Best regards,
[Your Name]''';
          break;

        case 'No':
          subject = 'Regarding your request: ${_emailContext['project']}';
          emailBody = '''Dear ${_emailContext['recipientName']},

After careful consideration, we regret to inform you that we won't be able to proceed with the ${_emailContext['project']} as requested.

This decision was made due to [reason]. We'd be happy to discuss alternative approaches that might better meet our mutual goals.

Regards,
[Your Name]''';
          break;

        case 'Follow Up':
          subject = 'Follow-up: ${_emailContext['project']}';
          emailBody = '''Dear ${_emailContext['recipientName']},

I'm following up on our previous conversation about the ${_emailContext['project']}.

Have you had a chance to review the materials I sent? I'm available to discuss any questions you might have, especially considering our deadline of ${_emailContext['deadline']}.

Looking forward to your response,
[Your Name]''';
          break;

        case 'More Info':
          subject =
              'Additional information needed for ${_emailContext['project']}';
          emailBody = '''Dear ${_emailContext['recipientName']},

Regarding the ${_emailContext['project']}, I need some additional information before we can proceed:

1. [Specific question 1]
2. [Specific question 2]
3. [Specific question 3]

This information will help us ensure we meet the deadline of ${_emailContext['deadline']}.

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

  void _editEmailContent() {
    // This method could be expanded to provide formatting tools
    // Currently, the email is already editable via the TextField
  }

  void _sendEmail() {
    // In a real app, this would send the email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email sent successfully')),
    );

    // Clear form
    _toController.clear();
    _subjectController.clear();
    _bodyController.clear();
    setState(() {
      _selectedAction = '';
    });
  }
}
