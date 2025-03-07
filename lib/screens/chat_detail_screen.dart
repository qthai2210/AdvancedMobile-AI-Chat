import 'package:aichatbot/screens/knowledge_management/knowledge_management_screen.dart';
import 'package:aichatbot/widgets/chat/ai_agent_selector.dart';
import 'package:aichatbot/widgets/chat/chat_dialogs.dart';
import 'package:aichatbot/widgets/chat/chat_message_list.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart'; // Changed import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/models/message_model.dart';
import 'package:aichatbot/models/ai_agent_model.dart';
import 'package:aichatbot/models/chat_thread.dart';
import 'package:aichatbot/widgets/chat/message_bubble.dart';
import 'package:aichatbot/widgets/chat/chat_input_field.dart';
import 'package:aichatbot/widgets/chat/chat_history_overlay.dart';
import 'package:aichatbot/widgets/chat/ai_typing_indicator.dart';
import 'package:aichatbot/widgets/chat/image_capture_options.dart';
import 'package:aichatbot/widgets/chat/image_preview.dart';
import 'package:aichatbot/services/prompt_service.dart';
import 'package:aichatbot/models/prompt_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;

class ChatDetailScreen extends StatefulWidget {
  final String? threadId;
  final bool isNewChat;
  final String? initialPrompt;

  const ChatDetailScreen(
      {super.key, this.threadId, required this.isNewChat, this.initialPrompt});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _showImageOptions = false;
  bool _isLoadingPrompts = false;
  List<Prompt> _recentPrompts = [];

  final int _selectedTabIndex =
      0; // Track the currently selected tab for the drawer
  String _currentThreadTitle = '';
  AIAgent _selectedAgent = AIAgents.agents.first;
  List<Message> _messages = [];
  bool _isTyping = false;
  bool _showHistory = false;
  final bool _isLoadingHistory = false;

  // Sample history for demo purposes
  final List<ChatThread> _chatThreads = [
    ChatThread(
      id: '1',
      title: 'Tìm hiểu về Machine Learning',
      lastMessage: 'Machine Learning là một phần của...',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      agentType: 'GPT-4',
    ),
    ChatThread(
      id: '2',
      title: 'Giải bài toán phức tạp',
      lastMessage: 'Để giải bài toán này, ta cần áp dụng...',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      agentType: 'Claude',
    ),
    ChatThread(
      id: '3',
      title: 'Lập trình Flutter',
      lastMessage: 'Flutter là framework phát triển ứng dụng...',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      agentType: 'GPT-3.5',
    ),
    ChatThread(
      id: '4',
      title: 'Tư vấn dự án',
      lastMessage: 'Để quản lý dự án hiệu quả, bạn nên...',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      agentType: 'GPT-4',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadChatThread();
    _loadRecentPrompts();

    // Set the initial prompt if provided
    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      _messageController.text = widget.initialPrompt!;
    }
  }

  void _loadChatThread() {
    if (widget.isNewChat) {
      _currentThreadTitle = 'New Conversation';
      _messages = [];
      _messages.add(
        Message(
          text: "Xin chào! Tôi là ${_selectedAgent.name}. Bạn cần giúp gì?",
          isUser: false,
          timestamp: DateTime.now(),
          agent: _selectedAgent,
        ),
      );
    } else {
      _mockLoadExistingThread();
    }
  }

  void _mockLoadExistingThread() {
    _currentThreadTitle = 'Tìm hiểu về Machine Learning';

    _messages = [
      Message(
        text: "Xin chào! Tôi là ${_selectedAgent.name}. Bạn cần giúp gì?",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        agent: _selectedAgent,
      ),
      Message(
        text: "Machine Learning là gì?",
        isUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 29)),
      ),
      Message(
        text:
            "Machine Learning (học máy) là một nhánh của trí tuệ nhân tạo (AI) tập trung vào việc phát triển các thuật toán và mô hình cho phép máy tính học từ dữ liệu và đưa ra dự đoán hoặc quyết định mà không cần lập trình cụ thể.\n\nCác phương pháp học máy được chia thành nhiều loại:\n1. Học có giám sát (Supervised Learning)\n2. Học không giám sát (Unsupervised Learning)\n3. Học bán giám sát (Semi-supervised Learning)\n4. Học tăng cường (Reinforcement Learning)",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
        agent: _selectedAgent,
      ),
    ];
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showImageOptions = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
        _showImageOptions = false;
      });
    }
  }

  void _captureScreenshot() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Screenshot feature will be implemented soon')),
    );
    setState(() {
      _showImageOptions = false;
    });
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();

    if (message.isEmpty && _selectedImage == null) return;

    if (_selectedImage != null) {
      print('Sending message: $message with image: ${_selectedImage!.path}');

      _messageController.clear();
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sending message with image...')),
      );
    } else {
      if (message.trim().isEmpty) return;

      setState(() {
        _messages.add(
          Message(text: message, isUser: true, timestamp: DateTime.now()),
        );
        _isTyping = true;
      });

      _scrollToBottom();

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isTyping = false;
          String response = _generateAIResponse(message);
          _messages.add(
            Message(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
              agent: _selectedAgent,
            ),
          );
        });
        _scrollToBottom();
      });
    }
  }

  void _toggleImageOptions() {
    setState(() {
      _showImageOptions = !_showImageOptions;
    });
  }

  String _generateAIResponse(String userMessage) {
    if (userMessage.toLowerCase().contains('flutter')) {
      return "Flutter là một framework UI mã nguồn mở được phát triển bởi Google. Nó cho phép bạn xây dựng ứng dụng đẹp, nhanh chóng cho mobile, web, và desktop từ một codebase duy nhất. Flutter sử dụng ngôn ngữ Dart và có một hệ sinh thái package phong phú.";
    } else if (userMessage.toLowerCase().contains('ai')) {
      return "Trí tuệ nhân tạo (AI) là lĩnh vực nghiên cứu về việc làm cho máy tính thể hiện hành vi thông minh. AI hiện đại tập trung vào machine learning, deep learning, và các kỹ thuật cho phép máy tính học từ dữ liệu.";
    } else if (userMessage.contains('?')) {
      return "Đó là một câu hỏi thú vị. Để trả lời chính xác, tôi cần thêm thông tin. Bạn có thể nêu rõ hơn hoặc cung cấp thêm ngữ cảnh được không?";
    } else {
      return "Cảm ơn thông tin của bạn. Tôi có thể giúp gì thêm cho bạn? Bạn có thể hỏi tôi về bất kỳ chủ đề nào và tôi sẽ cố gắng hỗ trợ bạn tốt nhất có thể.";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _changeAIAgent() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => AIAgentSelector(
        selectedAgent: _selectedAgent,
        onAgentSelected: (agent) {
          setState(() {
            _selectedAgent = agent;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _toggleHistoryView() {
    setState(() {
      _showHistory = !_showHistory;
    });
  }

  void _selectThreadFromHistory(ChatThread thread) {
    setState(() {
      _showHistory = false;
      _currentThreadTitle = thread.title;
      _mockLoadExistingThread();
    });
  }

  // Start a new chat conversation
  void _startNewChat() {
    setState(() {
      _currentThreadTitle = 'New Conversation';
      _messages = [];
      _messages.add(
        Message(
          text: "Xin chào! Tôi là ${_selectedAgent.name}. Bạn cần giúp gì?",
          isUser: false,
          timestamp: DateTime.now(),
          agent: _selectedAgent,
        ),
      );
    });

    // Close drawer if it's open
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  void _navigateToTab(int index) {
    // Navigate to the selected tab
    if (index == 0) {
      // Chat tab
      context.go('/chat');
    } else if (index == 1) {
      // Bots tab
      context.go('/chat');
      // Need to set the current index in the ChatAIScreen
      // This will require state management like Provider/Bloc
    } else if (index == 2) {
      // Knowledge Base tab
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KnowledgeManagementScreen(),
        ),
      );
    } else if (index == 3) {
      // History tab
      context.go('/chat');
    } else if (index == 4) {
      // Profile tab
      context.go('/chat');
    } else if (index == 5) {
      // Settings tab
      context.go('/chat');
    }
  }

  Future<void> _loadRecentPrompts() async {
    setState(() => _isLoadingPrompts = true);
    try {
      // Load recent prompts in background
      _recentPrompts = await PromptService.getPrompts();
      // Sort by most recently used
      _recentPrompts.sort((a, b) => b.useCount.compareTo(a.useCount));
      // Take only top 5
      if (_recentPrompts.length > 5) {
        _recentPrompts = _recentPrompts.sublist(0, 5);
      }
    } catch (e) {
      debugPrint('Error loading prompts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPrompts = false);
      }
    }
  }

  // Show prompt selector dialog
  void _showPromptSelector() async {
    final selectedPrompt = await showDialog<Prompt>(
      context: context,
      builder: (context) => _buildPromptSelectorDialog(),
    );

    if (selectedPrompt != null) {
      // Insert selected prompt into message input
      _insertPromptToInput(selectedPrompt);
    }
  }

  // Build the prompt selector dialog
  Widget _buildPromptSelectorDialog() {
    return AlertDialog(
      title: const Text('Select Prompt'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoadingPrompts
            ? const Center(child: CircularProgressIndicator())
            : _recentPrompts.isEmpty
                ? const Center(child: Text('No prompts available'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _recentPrompts.length,
                    itemBuilder: (context, index) {
                      final prompt = _recentPrompts[index];
                      return ListTile(
                        title: Text(prompt.title),
                        subtitle: Text(
                          prompt.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.pop(context, prompt),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Navigate to the prompts screen to browse all prompts
            Navigator.pop(context);
            context.push('/prompts');
          },
          child: const Text('Browse All Prompts'),
        ),
      ],
    );
  }

  // Insert the selected prompt into the message input
  void _insertPromptToInput(Prompt prompt) {
    // Update the prompt's usage count
    PromptService.incrementPromptUseCount(prompt.id);

    // Insert the prompt content into the message input
    _messageController.text = prompt.content;

    // Position cursor at the end
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added "${prompt.title}" to chat')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // Replace ChatHistoryDrawer with MainAppDrawer
      drawer: MainAppDrawer(
        currentIndex: _selectedTabIndex,
        onTabSelected: (index) => navigation_utils
            .handleDrawerNavigation(context, index, currentIndex: 0),
      ),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Main chat content
          Column(
            children: [
              // Messages list
              Expanded(
                child: ChatMessageList(
                  messages: _messages,
                  scrollController: _scrollController,
                ),
              ),

              // Image preview if an image is selected
              if (_selectedImage != null)
                ImagePreview(
                  imageFile: _selectedImage!,
                  onRemove: _removeSelectedImage,
                  messageController: _messageController,
                ),

              // Input area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Prompt button
                    IconButton(
                      icon: const Icon(Icons.psychology_outlined),
                      onPressed: _showPromptSelector,
                      tooltip: 'Use a prompt',
                    ),

                    // Image button
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _toggleImageOptions,
                      tooltip: 'Add image',
                    ),

                    // Text field
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),

                    // Send button
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // History panel - shown conditionally
          if (_showHistory) _buildHistoryPanel(),
        ],
      ),

      // Image options bottom sheet
      bottomSheet: _showImageOptions
          ? ImageCaptureOptions(
              onPickFromGallery: _pickImageFromGallery,
              onTakePhoto: _takePhoto,
              onCaptureScreenshot: _captureScreenshot,
              onClose: () => setState(() => _showImageOptions = false),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _currentThreadTitle,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          AgentSelectorButton(agent: _selectedAgent, onTap: _changeAIAgent),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(_showHistory ? Icons.history : Icons.history_outlined),
          color: _showHistory ? Theme.of(context).primaryColor : null,
          onPressed: _toggleHistoryView,
        ),
        // Add a new action button to create a new chat thread
        IconButton(
          icon: const Icon(Icons.add_comment),
          tooltip: 'New Chat',
          onPressed: () {
            // Navigate to a new chat thread
            // context.go('/chat/detail/new');
            _startNewChat();
          },
        ),
        ChatOptionsMenu(
          onRename: _showRenameDialog,
          onDelete: _showDeleteConfirmation,
        ),
      ],
    );
  }

  Widget _buildHistoryPanel() {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 16,
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // History header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.history),
                    const SizedBox(width: 8),
                    const Text(
                      'Chat History',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _toggleHistoryView,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // History list
              Expanded(
                child: _isLoadingHistory
                    ? const Center(child: CircularProgressIndicator())
                    : _chatThreads.isEmpty
                        ? const Center(child: Text('No chat history yet'))
                        : ListView.builder(
                            itemCount: _chatThreads.length,
                            itemBuilder: (context, index) {
                              final thread = _chatThreads[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: const Icon(Icons.chat,
                                      color: Colors.blue),
                                ),
                                title: Text(
                                  thread.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  thread.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  _formatDate(thread.timestamp),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                onTap: () => _selectThreadFromHistory(thread),
                              );
                            },
                          ),
              ),

              // "New Chat" button at bottom of history
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Start New Chat'),
                    onPressed: () {
                      _startNewChat();
                      setState(() => _showHistory = false);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays < 1) {
      // Today - show time
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(date).inDays < 7) {
      // This week - show day name
      final weekday =
          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
      return weekday;
    } else {
      // Older - show date
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showRenameDialog() {
    final TextEditingController controller = TextEditingController(
      text: _currentThreadTitle,
    );
    showDialog(
      context: context,
      builder: (context) => RenameDialogWidget(
        controller: controller,
        onSave: (newName) {
          setState(() {
            _currentThreadTitle = newName;
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        onConfirm: () {
          Navigator.pop(context);
          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          } else {
            context.go('/chat');
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
