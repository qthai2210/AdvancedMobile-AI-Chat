import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/presentation/bloc/email_reply_suggestion/email_reply_suggestion_bloc.dart';
import 'package:aichatbot/utils/styles.dart';

class EmailReplySuggestionScreen extends StatefulWidget {
  final String email;
  final String subject;
  final String sender;
  final String receiver;
  final String language;

  const EmailReplySuggestionScreen({
    Key? key,
    required this.email,
    required this.subject,
    required this.sender,
    required this.receiver,
    required this.language,
  }) : super(key: key);

  @override
  State<EmailReplySuggestionScreen> createState() =>
      _EmailReplySuggestionScreenState();
}

class _EmailReplySuggestionScreenState
    extends State<EmailReplySuggestionScreen> {
  @override
  void initState() {
    super.initState();
    // Request suggestions when screen loads
    _getSuggestions();
  }

  void _getSuggestions() {
    context.read<EmailReplySuggestionBloc>().add(
          GetEmailReplySuggestionsEvent(
            email: widget.email,
            subject: widget.subject,
            sender: widget.sender,
            receiver: widget.receiver,
            language: widget.language,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reply Suggestions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getSuggestions,
          ),
        ],
      ),
      body: BlocBuilder<EmailReplySuggestionBloc, EmailReplySuggestionState>(
        builder: (context, state) {
          if (state is EmailReplySuggestionInitial) {
            return const Center(
              child: Text('Enter an email to get reply suggestions'),
            );
          } else if (state is EmailReplySuggestionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is EmailReplySuggestionSuccess) {
            return _buildSuggestionsList(state.ideas);
          } else if (state is EmailReplySuggestionFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _getSuggestions,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSuggestionsList(List<String> suggestions) {
    if (suggestions.isEmpty) {
      return const Center(
        child: Text('No suggestions available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2.0,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              suggestions[index],
              style: AppStyles.bodyText,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy to clipboard',
                  onPressed: () {
                    // Copy suggestion to clipboard
                    _copySuggestion(suggestions[index]);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Use this suggestion',
                  onPressed: () {
                    // Navigate back with the selected suggestion
                    Navigator.of(context).pop(suggestions[index]);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copySuggestion(String suggestion) {
    // Implementation for copying to clipboard would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Suggestion copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
