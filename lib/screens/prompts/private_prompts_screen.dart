import 'package:flutter/material.dart';

class PrivatePromptsScreen extends StatefulWidget {
  const PrivatePromptsScreen({Key? key}) : super(key: key);

  @override
  State<PrivatePromptsScreen> createState() => _PrivatePromptsScreenState();
}

class _PrivatePromptsScreenState extends State<PrivatePromptsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Private Prompts'),
      ),
      body: const Center(
        child: Text('Private Prompts will be implemented soon'),
      ),
    );
  }
}
