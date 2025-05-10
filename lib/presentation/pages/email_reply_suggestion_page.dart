import 'package:aichatbot/core/di/core_injection.dart';
import 'package:aichatbot/presentation/bloc/email_reply_suggestion/email_reply_suggestion_bloc.dart';
import 'package:aichatbot/presentation/screens/email_reply_suggestion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailReplySuggestionPage extends StatelessWidget {
  final String email;
  final String subject;
  final String sender;
  final String receiver;
  final String language;

  const EmailReplySuggestionPage({
    Key? key,
    required this.email,
    required this.subject,
    required this.sender,
    required this.receiver,
    required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmailReplySuggestionBloc>(
      create: (_) => sl<EmailReplySuggestionBloc>(),
      child: EmailReplySuggestionScreen(
        email: email,
        subject: subject,
        sender: sender,
        receiver: receiver,
        language: language,
      ),
    );
  }
}
