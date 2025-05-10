import 'package:aichatbot/domain/models/email_reply_suggestion_models.dart';
import 'package:aichatbot/presentation/bloc/ai_email/ai_email_bloc.dart';
import 'package:aichatbot/presentation/bloc/ai_email/ai_email_event.dart';
import 'package:aichatbot/presentation/bloc/ai_email/ai_email_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/core/di/injection_container.dart';

class AiEmailScreen extends StatefulWidget {
  const AiEmailScreen({Key? key}) : super(key: key);

  @override
  State<AiEmailScreen> createState() => _AiEmailScreenState();
}

class _AiEmailScreenState extends State<AiEmailScreen>
    with SingleTickerProviderStateMixin {
  final _mainIdeaController = TextEditingController();
  final _actionController = TextEditingController(text: "Reply to this email");
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _senderController = TextEditingController();
  final _receiverController = TextEditingController();
  final _languageController = TextEditingController(text: "vietnamese");

  final _lengthOptions = ["short", "medium", "long"];
  final _formalityOptions = ["casual", "neutral", "formal"];
  final _toneOptions = ["friendly", "professional", "empathetic"];

  String _selectedLength = "medium";
  String _selectedFormality = "neutral";
  String _selectedTone = "friendly";

  late TabController _tabController;
  late AiEmailBloc _aiEmailBloc;

  // Scroll controller for the form
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _aiEmailBloc = sl<AiEmailBloc>();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainIdeaController.dispose();
    _actionController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _senderController.dispose();
    _receiverController.dispose();
    _languageController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Method to copy generated email to clipboard
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Email copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _generateEmail() {
    if (_mainIdeaController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Main idea and original email are required')),
      );
      return;
    }

    final style = EmailStyleConfig(
      length: _selectedLength,
      formality: _selectedFormality,
      tone: _selectedTone,
    );

    _aiEmailBloc.add(GenerateAiEmailEvent(
      mainIdea: _mainIdeaController.text,
      action: _actionController.text,
      email: _emailController.text,
      subject: _subjectController.text.isNotEmpty
          ? _subjectController.text
          : "No Subject",
      sender: _senderController.text.isNotEmpty
          ? _senderController.text
          : "sender@example.com",
      receiver: _receiverController.text.isNotEmpty
          ? _receiverController.text
          : "receiver@example.com",
      style: style,
      language: _languageController.text,
    ));

    // If we're on the input tab, switch to the result tab once generation starts
    if (_tabController.index == 0) {
      _tabController.animateTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Email Generator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Input', icon: Icon(Icons.edit)),
            Tab(text: 'Result', icon: Icon(Icons.email)),
          ],
        ),
      ),
      body: BlocProvider(
        create: (context) => _aiEmailBloc,
        child: BlocConsumer<AiEmailBloc, AiEmailState>(
          listener: (context, state) {
            if (state is AiEmailFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Error: ${state.error}')),
                    ],
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AiEmailSuccess) {
              // Automatically switch to the result tab when generation is successful
              _tabController.animateTo(1);
            }
          },
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              children: [
                // Input Tab
                _buildInputTab(),

                // Result Tab
                _buildResultTab(state),
              ],
            );
          },
        ),
      ),
    );
  }

  // Input form tab
  Widget _buildInputTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        controller: _scrollController,
        children: [
          _buildSectionHeader('Email Context', Icons.info_outline),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _mainIdeaController,
                    decoration: InputDecoration(
                      labelText: 'Main Idea*',
                      hintText: 'E.g., Thank you for the event information',
                      prefixIcon: const Icon(Icons.lightbulb_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _actionController,
                    decoration: InputDecoration(
                      labelText: 'Action*',
                      hintText: 'E.g., Reply to this email',
                      prefixIcon: const Icon(Icons.play_arrow),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subjectController,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            hintText: 'Email subject',
                            prefixIcon: const Icon(Icons.subject),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _languageController,
                          decoration: InputDecoration(
                            labelText: 'Language*',
                            hintText: 'E.g., english, vietnamese',
                            prefixIcon: const Icon(Icons.language),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Email Style', Icons.style),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStyleSelector('Length', _selectedLength, _lengthOptions,
                      Icons.format_size, (value) {
                    setState(() => _selectedLength = value);
                  }),
                  const SizedBox(height: 16),
                  _buildStyleSelector('Formality', _selectedFormality,
                      _formalityOptions, Icons.business, (value) {
                    setState(() => _selectedFormality = value);
                  }),
                  const SizedBox(height: 16),
                  _buildStyleSelector(
                      'Tone', _selectedTone, _toneOptions, Icons.mood, (value) {
                    setState(() => _selectedTone = value);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Original Email', Icons.email),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _senderController,
                          decoration: InputDecoration(
                            labelText: 'Sender',
                            hintText: 'Email sender',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _receiverController,
                          decoration: InputDecoration(
                            labelText: 'Receiver',
                            hintText: 'Email receiver',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Original Email Content*',
                      hintText: 'Paste the original email content here',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 10,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Email', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _generateEmail,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('* Required fields',
                style: TextStyle(fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Results tab
  Widget _buildResultTab(AiEmailState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state is AiEmailLoading) ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 24),
                    Text('Generating your email...',
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('This may take a few seconds',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ] else if (state is AiEmailSuccess) ...[
            _buildSuccessResult(state),
          ] else ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 24),
                    Text('Generate an email to see the result',
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text(
                        'Fill out the form in the Input tab and click Generate',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],

          // Always show the generate button at the bottom of result tab too
          if (!(state is AiEmailLoading)) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                _tabController.animateTo(0); // Go back to input tab
              },
            ),
          ],
        ],
      ),
    );
  }

  // Success result widget
  Widget _buildSuccessResult(AiEmailSuccess state) {
    return Expanded(
      child: ListView(
        children: [
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_email_read, color: Colors.green),
                      const SizedBox(width: 10),
                      const Text(
                        'Generated Email',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy to clipboard',
                        onPressed: () => _copyToClipboard(state.email),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    state.email,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Remaining usage card
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bar_chart, color: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remaining Usage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${state.remainingUsage} emails left',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Improved actions card
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_fix_high,
                            color: Colors.purple),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Improvements Applied',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...state.improvedActions.map((action) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(action)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for section headers
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  // Helper widget for style selection
  Widget _buildStyleSelector(String label, String selectedValue,
      List<String> options, IconData icon, Function(String) onChanged) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 16),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                icon: const Icon(Icons.arrow_drop_down),
                isExpanded: true,
                items: options
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.substring(0, 1).toUpperCase() +
                                value.substring(1),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
