import 'package:aichatbot/screens/knowledge_management/knowledge_management_screen.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/widgets/chat/ai_agent_selector.dart';
import 'package:aichatbot/widgets/chat/chat_dialogs.dart';
import 'package:aichatbot/widgets/chat/chat_message_list.dart';
import 'package:aichatbot/widgets/main_app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aichatbot/models/message_model.dart';
import 'package:aichatbot/models/ai_agent_model.dart';
import 'package:aichatbot/models/chat_thread.dart';
import 'package:aichatbot/domain/usecases/chat/send_message_usecase.dart';
import 'package:aichatbot/domain/usecases/chat/get_conversations_usecase.dart';
import 'package:aichatbot/data/models/chat/message_request_model.dart'
    as msg_model;
import 'package:aichatbot/data/models/chat/custom_bot_message_model.dart';

import 'package:aichatbot/data/models/chat/conversation_model.dart';

import 'package:aichatbot/presentation/bloc/auth/auth_bloc.dart';
import 'package:aichatbot/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:aichatbot/presentation/bloc/conversation/conversation_event.dart';
import 'package:aichatbot/presentation/bloc/conversation/conversation_state.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_bloc.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_event.dart';
import 'package:aichatbot/presentation/bloc/chat/chat_state.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_bloc.dart';
import 'package:aichatbot/presentation/bloc/bot/bot_event.dart';
import 'package:aichatbot/data/models/chat/conversation_request_params.dart';
import 'package:aichatbot/data/models/chat/conversation_history_model.dart';

import 'package:aichatbot/core/di/injection_container.dart' as di;

import 'package:aichatbot/widgets/chat/image_capture_options.dart';
import 'package:aichatbot/widgets/chat/image_preview.dart';
import 'package:aichatbot/services/prompt_service.dart';
import 'package:aichatbot/models/prompt_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:aichatbot/utils/navigation_utils.dart' as navigation_utils;

class ChatDetailScreen extends StatefulWidget {
  final bool isNewChat;
  final String? threadId;
  final String? initialPrompt;

  const ChatDetailScreen({
    Key? key,
    this.isNewChat = false,
    this.threadId,
    this.initialPrompt,
  }) : super(key: key);

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

  // API communication use cases
  late final SendMessageUseCase _sendMessageUseCase;
  late final GetConversationsUsecase _getConversationsUseCase;

  // Conversation data
  final List<ConversationModel> _conversations = [];
  final bool _isLoadingConversations = false;
  String? _nextCursor;

  final int _selectedTabIndex =
      0; // Track the currently selected tab for the drawer
  String _currentThreadTitle = '';
  AIAgent _selectedAgent = AIAgents.agents.first;
  List<Message> _messages = [];
  bool _isTyping = false;
  bool _showHistory = false;
  final bool _isLoadingHistory = false;

  // Conversation history will be fetched from the API
  List<ChatThread> _chatThreads = [];

  @override
  void initState() {
    super.initState();
    print("ChatDetailScreen initialized");
    try {
      // Initialize use cases from dependency injection with error handling
      _sendMessageUseCase = di.sl<SendMessageUseCase>();

      // Safely get conversations usecase, handle if not registered in DI
      try {
        _getConversationsUseCase = di.sl<GetConversationsUsecase>();
      } catch (e) {
        print('Error getting GetConversationsUsecase: $e');
        // Create a fallback or mock implementation if needed
      }

      // For new chat or if DI fails, just load the chat thread with mock data
      _loadChatThread();
      print("Chat thread loaded: $_currentThreadTitle");
      // Only try to fetch conversations if we have a valid threadId and the usecase
      if (!widget.isNewChat && widget.threadId != null) {
        try {
          // Safely try to load existing conversation with the given threadId
          final bloc = context.read<ConversationBloc>();
          bloc.add(
            FetchConversations(
              cursor: _nextCursor,
              limit: 100,
              xJarvisGuid: '',
            ),
          );
        } catch (e) {
          print('Error loading conversation: $e');
          // Fallback to empty conversation with welcome message if the bloc operation fails
          _loadExistingConversation();
        }
      }
    } catch (e) {
      print('Error in ChatDetailScreen initialization: $e');
      // Handle initialization errors gracefully
    }

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
      // Load existing conversation from API
      _loadExistingConversation();
    }
  }

  void _loadExistingConversation() {
    // This will be replaced with actual API call implementation
    _currentThreadTitle = widget.threadId ?? 'Conversation';

    // Show loading state initially
    setState(() {
      _messages = [];
      _isTyping = true;
    });

    // Try to load conversation data using the ConversationBloc
    try {
      if (widget.threadId != null) {
        final bloc = context.read<ConversationBloc>();
        bloc.add(
          FetchConversations(
            //threadId: widget.threadId,
            cursor: _nextCursor,
            limit: 100,
            xJarvisGuid: '',
          ),
        );
      }
    } catch (e) {
      print('Error loading conversation data: $e');
      // Add a fallback welcome message if conversation loading fails
      setState(() {
        _isTyping = false;
        _messages.add(
          Message(
            text: "Xin chào! Tôi là ${_selectedAgent.name}. Bạn cần giúp gì?",
            isUser: false,
            timestamp: DateTime.now(),
            agent: _selectedAgent,
          ),
        );
      });
    }
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

  Future<void> _sendMessage() async {
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

      // Clear the input field immediately after sending
      _messageController.clear();

      // Add user message to the chat
      setState(() {
        _messages.add(
          Message(text: message, isUser: true, timestamp: DateTime.now()),
        );
        _isTyping = true;
      });

      _scrollToBottom();

      try {
        // Get authentication token (you might need to adjust this based on your auth system)
        final authState = di.sl<AuthBloc>().state;
        final accessToken = authState.user?.accessToken ?? '';

        if (accessToken.isEmpty) {
          throw Exception('User not authenticated');
        }

        // Create conversation history for the API request
        // create conversationHIstory empty
        List<msg_model.ChatMessage> conversationHistory = [];
        // List<msg_model.ChatMessage> conversationHistory = _messages.map((msg) {
        //   return msg_model.ChatMessage(
        //       role: msg.isUser ? 'user' : 'model',
        //       content: msg.text,
        //       files: [],
        //       assistant: msg.isUser
        //           ? null
        //           : msg_model.AssistantModel(
        //               model: "dify",
        //               name: _selectedAgent.name,
        //               id: _selectedAgent.id,
        //             ));
        // }).toList();        // Create API request

        if (_selectedAgent.isCustom) {
          // Create a custom bot request
          // Convert existing messages to CustomBotMessage format
          // Exclude the most recent user message (which was just added to _messages)
          AppLogger.w("CustombotResquest2: $_messages");
          // Get all messages except the last one (which is the current user message)
          final messagesToInclude = _messages.length > 1
              ? _messages.sublist(0, _messages.length - 1)
              : [];
          List<CustomBotMessage> messageHistory = messagesToInclude.map((msg) {
            return CustomBotMessage(
              role: msg.isUser ? 'user' : 'assistant',
              content: msg.text,
              files: const [],
              assistant: !msg.isUser
                  ? CustomBotAssistantReference(
                      model: "knowledge-base",
                      name: _selectedAgent.name,
                      id: _selectedAgent.id,
                    )
                  : null,
            );
          }).toList();

          AppLogger.w("CustombotResquest1: $messageHistory");
          final customBotRequest = CustomBotMessageRequest(
            content: message,
            files: const [],
            metadata: CustomBotMetadata(
              conversation: CustomBotConversation(
                id: widget.threadId ?? 'new_conversation',
                title: _currentThreadTitle,
                createdAt: DateTime.now(),
                messages: messageHistory,
              ),
            ),
            assistant: CustomBotAssistant(
              model: "knowledge-base",
              name: _selectedAgent.name,
              id: _selectedAgent
                  .idString, // Use idString instead of id directly
            ),
          );
          AppLogger.w("Custom bot request: $customBotRequest");
          // Use CustomBotMessageEvent instead
          context
              .read<ChatBloc>()
              .add(SendCustomBotMessageEvent(request: customBotRequest));
        } else {
          // Use regular ChatBloc to send the message for standard bots
          final requestModel = msg_model.MessageRequestModel(
            content: message,
            files: [],
            metadata: msg_model.MessageMetadata(
              conversation: msg_model.Conversation(
                id: widget.threadId ?? 'new_conversation',
                title: _currentThreadTitle,
                createdAt: DateTime.now(),
              ),
            ),
            assistant: msg_model.AssistantModel(
              model: "dify",
              name: _selectedAgent.name,
              id: _selectedAgent.id,
            ),
          ); // Check if we're using a custom bot
          AppLogger.w("Selected agent: $_selectedAgent");
          AppLogger.w("Regular bot request: $requestModel");
          context.read<ChatBloc>().add(SendMessageEvent(request: requestModel));
        }
      } catch (error) {
        // Handle initial errors (like not authenticated)
        AppLogger.e("Error sending message: $error");
        AppLogger.e("Error sending message: ${error.toString()}");

        setState(() {
          _isTyping = false;
          // Add error message
          _messages.add(
            Message(
              text:
                  "Sorry, there was an error processing your request: ${error.toString()}",
              isUser: false,
              timestamp: DateTime.now(),
              agent: _selectedAgent,
            ),
          );
        });

        print('Error preparing message: $error');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );

        _scrollToBottom();
      }
    }
  }

  void _toggleImageOptions() {
    setState(() {
      _showImageOptions = !_showImageOptions;
    });
  }
  // We're no longer using mock AI responses since we're using the ChatBloc for real API responses

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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => BlocProvider(
        create: (context) => di.sl<BotBloc>(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: AIAgentSelector(
            selectedAgent: _selectedAgent,
            onAgentSelected: (agent) {
              // Only refresh if agent changed
              if (agent.id != _selectedAgent.id) {
                setState(() {
                  _selectedAgent = agent;
                  _messages = [];
                  // Clear current chat
                  // if (widget.isNewChat || _messages.isEmpty) {
                  //   // For new or empty chats, start a new conversation
                  //   _messages = [];
                  // } else {
                  //   // For existing conversations, add a transition message
                  //   _messages.add(
                  //     Message(
                  //       text:
                  //           "Tôi đã chuyển sang ${agent.name}. Tôi có thể giúp gì cho bạn?",
                  //       isUser: false,
                  //       timestamp: DateTime.now(),
                  //       agent: agent,
                  //     ),
                  //   );
                  // }
                });

                // Scroll to the latest message
                _scrollToBottom();
              }
              Navigator.pop(context);
            },
          ),
        ),
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
      _messages = []; // Clear existing messages
      _isTyping = true; // Show loading state
    });

    // Fetch conversation history for the selected thread
    context.read<ConversationBloc>().add(
          FetchConversationHistory(
            conversationId: thread.id,
            limit: 100,
            assistantId: _selectedAgent.id == 'claude-3-haiku-20240307'
                ? AssistantId.CLAUDE_3_HAIKU_20240307
                : _selectedAgent.id == 'claude-3-5-sonnet-20240620'
                    ? AssistantId.CLAUDE_35_SONNET_20240620
                    : _selectedAgent.id == 'gemini-1.5-flash-latest'
                        ? AssistantId.GEMINI_15_FLASH_LATEST
                        : _selectedAgent.id == 'gemini-1.5-pro-latest'
                            ? AssistantId.GEMINI_15_PRO_LATEST
                            : _selectedAgent.id == 'gpt-4o'
                                ? AssistantId.GPT_4_O
                                : _selectedAgent.id == 'gpt-4o-mini'
                                    ? AssistantId.GPT_4_O_MINI
                                    : null,
            xJarvisGuid: '',
          ),
        );
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

  void _handleChatState(ChatState state) {
    if (state.status == ChatStatus.loading) {
      // The message is already shown as "typing" from the _sendMessage method
      // Nothing to do here as we've already updated the UI to show typing status
    } else if (state.status == ChatStatus.success) {
      // Handle successful message response from API
      if (state.response != null) {
        setState(() {
          _isTyping = false;
          _messages.add(
            Message(
              text: state.response!.message,
              isUser: false,
              timestamp: DateTime.now(),
              agent: _selectedAgent,
            ),
          );
        });

        _scrollToBottom();
      }
    } else if (state.status == ChatStatus.error) {
      // Handle error state
      setState(() {
        _isTyping = false;
        _messages.add(
          Message(
            text:
                "Sorry, there was an error processing your request: ${state.errorMessage ?? 'Unknown error'}",
            isUser: false,
            timestamp: DateTime.now(),
            agent: _selectedAgent,
          ),
        );
      });

      // Show error in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${state.errorMessage ?? 'Unknown error'}')),
      );

      _scrollToBottom();
    }
  }

  void _handleConversationState(ConversationState state) {
    if (state is ConversationLoading) {
      setState(() {
        _isTyping = true;
      });
    } else if (state is ConversationLoaded) {
      setState(() {
        _isTyping = false;
        AppLogger.e("Conversation loaded: ${state.conversations}");
        AppLogger.e("Conversations length: ${state.conversations.length}");

        // Update chat threads for history panel if available
        if (state.conversations.isNotEmpty) {
          _chatThreads = state.conversations
              .map((conv) => ChatThread(
                    id: conv.id,
                    // id: conv.id,
                    // title: conv.title ?? 'Untitled Conversation',
                    title: conv.title,
                    lastMessage: 'No messages',
                    timestamp: conv.createdAt,
                    agentType: 'AI Assistant',
                  ))
              .toList();

          // If there's a specific conversation to display
          if (widget.threadId != null && state.conversations.isNotEmpty) {
            final conversation = state.conversations.firstWhere(
              (conv) => conv.id == widget.threadId,
              orElse: () => state.conversations.first,
            );
            // final conversation = state.conversations.firstWhere(
            //   (conv) => conv.id == widget.threadId,
            //   orElse: () => state.conversations.first,
            // );

            //_currentThreadTitle = conversation.title ?? 'Conversation';
            _currentThreadTitle = 'Conversation';

            // Convert conversation messages to UI Message model
            _messages = [];

            // for (var msg in conversation.messages) {
            //   _messages.add(
            //     Message(
            //       text: msg.content ?? '',
            //       isUser: msg.role == 'user',
            //       //   timestamp: msg.createdAt ?? DateTime.now(),
            //       timestamp: DateTime.now(),

            //       agent: msg.role == 'user' ? null : _selectedAgent,
            //     ),
            //   );
            // }

            // Scroll to bottom after loading messages
            _scrollToBottom();
          }

          // Store cursor for pagination if available
          _nextCursor = state.nextCursor;
        }
      });
    } else if (state is ConversationError) {
      setState(() {
        _isTyping = false;

        // Add an error message if there's no content to display
        if (_messages.isEmpty) {
          _messages.add(
            Message(
              text:
                  "Sorry, there was an error loading this conversation: ${state.message}",
              isUser: false,
              timestamp: DateTime.now(),
              agent: _selectedAgent,
            ),
          );
        }
      });

      // Show error in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.message}')),
      );
    } else if (state is MessageSent) {
      // Handle when a message is sent and response received
      setState(() {
        _isTyping = false;

        // Add AI response to chat if it's not already added by ChatBloc
        // This is a safeguard in case both blocs handle the same message
        final responseExists = _messages
            .any((msg) => !msg.isUser && msg.text == state.responseMessage);

        if (!responseExists) {
          _messages.add(
            Message(
              text: state.responseMessage,
              isUser: false,
              timestamp: DateTime.now(),
              agent: _selectedAgent,
            ),
          );
        }
      });

      _scrollToBottom();
    } else if (state is MessageGenerating) {
      // Handle when AI is generating a message
      setState(() {
        _isTyping = true;
      });
    } else if (state is ConversationHistoryLoading) {
      setState(() {
        _isTyping = true;
      });
    } else if (state is ConversationHistoryLoaded) {
      setState(() {
        _isTyping = false;

        // Convert history items to UI Message model
        _messages = [];
        for (var item in state.historyItems) {
          if (item.query != null) {
            _messages.add(
              Message(
                text: item.query!,
                isUser: true,
                timestamp: item.createdAt != null
                    ? DateTime.fromMillisecondsSinceEpoch(item.createdAt!)
                    : DateTime.now(),
              ),
            );
          }

          if (item.answer != null) {
            _messages.add(
              Message(
                text: item.answer!,
                isUser: false,
                timestamp: item.createdAt != null
                    ? DateTime.fromMillisecondsSinceEpoch(item.createdAt!)
                    : DateTime.now(),
                agent: _selectedAgent,
              ),
            );
          }
        }

        // Scroll to bottom after loading messages
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<ConversationBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<ChatBloc>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ConversationBloc, ConversationState>(
            listener: (context, state) {
              _handleConversationState(state);
            },
          ),
          BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {
              _handleChatState(state);
            },
          ),
        ],
        child: Builder(
          builder: (context) {
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
          },
        ),
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
                                // subtitle: Text(
                                //   thread.lastMessage,
                                //   maxLines: 1,
                                //   overflow: TextOverflow.ellipsis,
                                // ),
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
