import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/ai_bot_model.dart';
import '../../data/models/assistant/assistant_model.dart';

enum BotPlatform {
  none,
  telegram,
  slack,
  // Add more platforms here in the future
}

class BotDetailsTab extends StatefulWidget {
  final AIBot bot;
  final AssistantModel assistantModel;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController instructionsController;
  final TextEditingController telegramBotTokenController;
  final TextEditingController slackBotTokenController;
  final TextEditingController slackClientIdController;
  final TextEditingController slackClientSecretController;
  final TextEditingController slackSigningSecretController;
  final bool isValidatingTelegramBot;
  final bool isPublishingToTelegram;
  final bool isValidatingSlackBot;
  final Map<String, dynamic>? validatedBotInfo;
  final Map<String, dynamic>? validatedSlackBotInfo;
  final String? telegramBotUrl;
  final Function() validateTelegramBot;
  final Function() publishTelegramBot;
  final Function() validateSlackBot;
  final Function() publishSlackBot;
  final bool isPublishingToSlack;
  final String? slackBotUrl;
  const BotDetailsTab({
    Key? key,
    required this.bot,
    required this.assistantModel,
    required this.nameController,
    required this.descriptionController,
    required this.instructionsController,
    required this.telegramBotTokenController,
    required this.slackBotTokenController,
    required this.slackClientIdController,
    required this.slackClientSecretController,
    required this.slackSigningSecretController,
    required this.isValidatingTelegramBot,
    required this.isPublishingToTelegram,
    required this.isValidatingSlackBot,
    required this.isPublishingToSlack,
    required this.validatedBotInfo,
    required this.validatedSlackBotInfo,
    required this.telegramBotUrl,
    required this.slackBotUrl,
    required this.validateTelegramBot,
    required this.publishTelegramBot,
    required this.validateSlackBot,
    required this.publishSlackBot,
  }) : super(key: key);

  @override
  State<BotDetailsTab> createState() => _BotDetailsTabState();
}

class _BotDetailsTabState extends State<BotDetailsTab> {
  BotPlatform _selectedPlatform = BotPlatform.none;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot header with icon and color
          Center(
            child: Column(
              children: [
                Hero(
                  tag: 'bot-avatar-${widget.bot.id}',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: widget.bot.color.withOpacity(0.2),
                    child: Icon(
                      widget.bot.iconData,
                      color: widget.bot.color,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bot ID: ${widget.bot.id.substring(0, 8)}...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Name field
          TextField(
            controller: widget.nameController,
            decoration: InputDecoration(
              labelText: 'Assistant Name',
              hintText: 'Enter assistant name',
              prefixIcon: const Icon(Icons.smart_toy),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 24),

          // Description field
          TextField(
            controller: widget.descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Enter assistant description',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 64),
                child: Icon(Icons.description),
              ),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 24),

          // Instructions field
          TextField(
            controller: widget.instructionsController,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Instructions (Optional)',
              hintText: 'Enter specific instructions for the assistant',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 120),
                child: Icon(Icons.psychology),
              ),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 32),

          // Platform Integration Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Platform Integrations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect your assistant to messaging platforms:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Platform cards
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildPlatformCard(
                    BotPlatform.telegram,
                    'Telegram',
                    Icons.telegram,
                    Colors.blue.shade700,
                    'Connect your bot to Telegram',
                  ),
                  _buildPlatformCard(
                    BotPlatform.slack,
                    'Slack',
                    Icons.workspaces_outlined,
                    Colors.purple.shade700,
                    'Connect your bot to Slack workspaces',
                  ),
                  // Add more platform cards here in the future
                ],
              ),

              const SizedBox(height: 24),

              // Platform-specific configuration UI
              if (_selectedPlatform != BotPlatform.none)
                _buildPlatformConfigurationUI(),
            ],
          ),

          const SizedBox(height: 24),

          // Created date info
          Text(
            'Created on: ${_formatDate(widget.bot.createdAt)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Individual platform card widget
  Widget _buildPlatformCard(
    BotPlatform platform,
    String name,
    IconData icon,
    Color color,
    String description,
  ) {
    final isSelected = _selectedPlatform == platform;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPlatform =
              _selectedPlatform == platform ? BotPlatform.none : platform;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width > 600
            ? (MediaQuery.of(context).size.width - 64) / 3
            : (MediaQuery.of(context).size.width - 44) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : Colors.black87,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Platform-specific configuration UI
  Widget _buildPlatformConfigurationUI() {
    switch (_selectedPlatform) {
      case BotPlatform.telegram:
        return _buildTelegramConfiguration();
      case BotPlatform.slack:
        return _buildSlackConfiguration();
      case BotPlatform.none:
        return const SizedBox.shrink();
    }
  }

  // Telegram configuration UI
  Widget _buildTelegramConfiguration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Configuration header
        Row(
          children: [
            const Icon(Icons.telegram, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            Text(
              'Telegram Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedPlatform = BotPlatform.none;
                });
              },
              icon: const Icon(Icons.close),
              tooltip: 'Close Telegram configuration',
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your Telegram bot token to validate and publish your assistant.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),

        // Telegram Bot Token field
        TextField(
          controller: widget.telegramBotTokenController,
          decoration: InputDecoration(
            labelText: 'Telegram Bot Token',
            hintText: 'Enter your Telegram bot token',
            prefixIcon: const Icon(Icons.key),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            helperText: 'Get a token from @BotFather on Telegram',
          ),
        ),
        const SizedBox(height: 16),

        // Show validation status if available
        if (widget.validatedBotInfo != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Bot Successfully Validated',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Validate and Publish to Telegram button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (widget.isValidatingTelegramBot ||
                    widget.isPublishingToTelegram)
                ? null
                : (widget.validatedBotInfo != null
                    ? widget.publishTelegramBot
                    : widget.validateTelegramBot),
            icon: const Icon(Icons.send),
            label: widget.isValidatingTelegramBot
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Validating...'),
                    ],
                  )
                : widget.isPublishingToTelegram
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Publishing...'),
                        ],
                      )
                    : widget.validatedBotInfo != null
                        ? const Text('Publish to Telegram')
                        : const Text('Validate & Publish'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.validatedBotInfo != null ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: widget.validatedBotInfo != null ? 3 : 2,
            ),
          ),
        ),

        // Display Telegram bot URL if available
        if (widget.telegramBotUrl != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Telegram Bot Published Successfully',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Telegram Bot URL:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  widget.telegramBotUrl!,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // Copy to clipboard
                        Clipboard.setData(
                            ClipboardData(text: widget.telegramBotUrl!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('URL copied to clipboard'),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy URL'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Slack configuration UI
  Widget _buildSlackConfiguration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Configuration header
        Row(
          children: [
            const Icon(Icons.workspaces_outlined,
                color: Colors.purple, size: 24),
            const SizedBox(width: 8),
            Text(
              'Slack Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedPlatform = BotPlatform.none;
                });
              },
              icon: const Icon(Icons.close),
              tooltip: 'Close Slack configuration',
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your Slack credentials to validate and connect your assistant.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),

        // Slack Bot Token Field
        TextField(
          controller: widget.slackBotTokenController,
          decoration: InputDecoration(
            labelText: 'Slack Bot Token',
            hintText: 'Enter your Slack bot token',
            prefixIcon: const Icon(Icons.key),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),

        // Slack Client ID Field
        TextField(
          controller: widget.slackClientIdController,
          decoration: InputDecoration(
            labelText: 'Client ID',
            hintText: 'Enter your Slack client ID',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),

        // Slack Client Secret Field
        TextField(
          controller: widget.slackClientSecretController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Client Secret',
            hintText: 'Enter your Slack client secret',
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),

        // Slack Signing Secret Field
        TextField(
          controller: widget.slackSigningSecretController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Signing Secret',
            hintText: 'Enter your Slack signing secret',
            prefixIcon: const Icon(Icons.security),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),

        // Show validation status if available
        if (widget.validatedSlackBotInfo != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Slack Bot Successfully Validated',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ], // Validate/Publish Slack Bot Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                (widget.isValidatingSlackBot || widget.isPublishingToSlack)
                    ? null
                    : (widget.validatedSlackBotInfo != null
                        ? widget.publishSlackBot
                        : widget.validateSlackBot),
            icon: widget.validatedSlackBotInfo != null
                ? const Icon(Icons.send)
                : const Icon(Icons.check_circle),
            label: widget.isValidatingSlackBot
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Validating...'),
                    ],
                  )
                : widget.isPublishingToSlack
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Publishing...'),
                        ],
                      )
                    : widget.validatedSlackBotInfo != null
                        ? const Text('Publish to Slack')
                        : const Text('Validate Slack Configuration'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.validatedSlackBotInfo != null
                  ? Colors.green
                  : Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: widget.validatedSlackBotInfo != null ? 3 : 2,
            ),
          ),
        ),

        // Display Slack bot URL if available
        if (widget.slackBotUrl != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Slack Bot Published Successfully',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Slack Authorization URL:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  widget.slackBotUrl!,
                  style: const TextStyle(
                    color: Colors.purple,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // Copy to clipboard
                        Clipboard.setData(
                            ClipboardData(text: widget.slackBotUrl!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('URL copied to clipboard'),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy URL'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
