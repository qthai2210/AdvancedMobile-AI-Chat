import 'package:aichatbot/widgets/chat/ai_agent_selector.dart';
import 'package:aichatbot/widgets/chat/chat_dialogs.dart';
import 'package:aichatbot/widgets/chat/chat_message_list.dart';
import 'package:aichatbot/widgets/chat/chat_history_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/models/message_model.dart';
import 'package:aichatbot/models/ai_agent_model.dart';
import 'package:aichatbot/models/chat_thread.dart';
import 'package:aichatbot/widgets/chat/message_bubble.dart';
import 'package:aichatbot/widgets/chat/chat_input_field.dart';
import 'package:aichatbot/widgets/chat/chat_history_overlay.dart';
import 'package:aichatbot/widgets/chat/ai_typing_indicator.dart';

class ChatDetailScreen extends StatefulWidget {
  final String? threadId;
  final bool isNewChat;

  const ChatDetailScreen({
    super.key,
    this.threadId,
    required this.isNewChat,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _currentThreadTitle = '';
  AIAgent _selectedAgent = AIAgents.agents.first;
  List<Message> _messages = [];
  bool _isTyping = false;
  bool _showHistory = false;

  // Sample history for demo purposes
  final List<ChatThread> _chatHistory = [
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
  }

  void _loadChatThread() {
    if (widget.isNewChat) {
      _currentThreadTitle = 'New Conversation';
      _messages = [];
      _messages.add(Message(
        text: "Xin chào! Tôi là ${_selectedAgent.name}. Bạn cần giúp gì?",
        isUser: false,
        timestamp: DateTime.now(),
        agent: _selectedAgent,
      ));
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

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isTyping = false;
        String response = _generateAIResponse(text);
        _messages.add(Message(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
          agent: _selectedAgent,
        ));
      });
      _scrollToBottom();
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
      _messages.add(Message(
        text: "Xin chào! Tôi là ${_selectedAgent.name}. Bạn cần giúp gì?",
        isUser: false,
        timestamp: DateTime.now(),
        agent: _selectedAgent,
      ));
    });

    // Close drawer if it's open
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ChatHistoryDrawer(
        chatHistory: _chatHistory,
        onThreadSelected: _selectThreadFromHistory,
        onNewChatRequested: _startNewChat,
      ),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              // Messages list
              Expanded(
                child: ChatMessageList(
                  messages: _messages,
                  scrollController: _scrollController,
                ),
              ),

              // AI typing indicator
              if (_isTyping) const AITypingIndicator(),

              // Input field
              ChatInputField(
                controller: _messageController,
                onSendMessage: _sendMessage,
              ),
            ],
          ),

          // History overlay when visible
          if (_showHistory)
            ChatHistoryOverlay(
              chatHistory: _chatHistory,
              onClose: _toggleHistoryView,
              onThreadSelected: _selectThreadFromHistory,
            ),
        ],
      ),
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
          AgentSelectorButton(
            agent: _selectedAgent,
            onTap: _changeAIAgent,
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(_showHistory ? Icons.history : Icons.history_outlined),
          color: _showHistory ? Theme.of(context).primaryColor : null,
          onPressed: _toggleHistoryView,
        ),
        ChatOptionsMenu(
          onRename: _showRenameDialog,
          onDelete: _showDeleteConfirmation,
        ),
      ],
    );
  }

  void _showRenameDialog() {
    final TextEditingController controller =
        TextEditingController(text: _currentThreadTitle);
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
