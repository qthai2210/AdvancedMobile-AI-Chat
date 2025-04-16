import 'package:aichatbot/data/models/chat/conversation_request_params.dart';
import 'package:aichatbot/data/models/chat/message_request_model.dart'
    as message;
import 'package:aichatbot/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/domain/usecases/chat/get_conversations_usecase.dart';
import 'package:aichatbot/presentation/bloc/conversation/conversation_event.dart';
import 'package:aichatbot/presentation/bloc/conversation/conversation_state.dart';

/// ConversationBloc manages the state of conversations in the application
/// It handles fetching, creating, updating, and deleting conversations
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final GetConversationsUsecase getConversationsUsecase;

  ConversationBloc({
    required this.getConversationsUsecase,
  }) : super(ConversationInitial()) {
    on<FetchConversations>(_onFetchConversations);
    on<FetchMoreConversations>(_onFetchMoreConversations);
    on<ResetConversations>(_onResetConversations);
    on<CreateConversation>(_onCreateConversation);
    on<UpdateConversation>(_onUpdateConversation);
    on<DeleteConversation>(_onDeleteConversation);
  }

  /// Handles fetching conversations
  Future<void> _onFetchConversations(
    FetchConversations event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      final result = await getConversationsUsecase(
        assistantModel: AssistantModel.dify,
        assistantId: event.assistantId,
        cursor: event.cursor,
        limit: event.limit,
        xJarvisGuid: event.xJarvisGuid,
      );
      AppLogger.i("response from getConversations: $result");
      try {
        // Create list of conversations from the result
        final List<message.Conversation> conversations = [];
        for (var item in result.items) {
          try {
            // Now we know item is a ConversationModel, not a Map
            // Access its properties directly
            // let add 7 hours into createAt
            final conversation = message.Conversation(
                id: item.id,
                title: item.title,
                createdAt: DateTime.parse(item.createdAt)
                    .add(const Duration(hours: 7)));

            // Add the conversation to the list
            conversations.add(conversation);
          } catch (itemError) {
            // Log the error but continue processing other items
            AppLogger.e("Error processing conversation item: $itemError");
          }
        } // Emit loaded state with conversations and pagination info

        AppLogger.i("Conversations: $conversations");
        emit(ConversationLoaded(
          conversations: conversations,
          hasMore: result.hasMore, // Use has_more from API response
          nextCursor: result.cursor,
        ));
        AppLogger.e(
            "first conversation: ${conversations.first.title} - ${conversations.first.createdAt}");
      } catch (parseError) {
        AppLogger.e("Error parsing conversation data: $parseError");
        emit(ConversationError(
            message: "Failed to parse conversation data: $parseError"));
      }
    } catch (e) {
      AppLogger.e("Error fetching conversations: $e");
      emit(ConversationError(message: e.toString()));
    }
  }

  /// Handles fetching more conversations (pagination)
  Future<void> _onFetchMoreConversations(
    FetchMoreConversations event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConversationLoaded) {
      emit(ConversationLoadingMore(
        conversations: currentState.conversations,
        hasMore: currentState.hasMore,
      ));

      try {
        // final result = await getConversationsUsecase(
        //   accessToken: event.accessToken,
        //   limit: event.limit,
        //   cursor: event.cursor,
        // );

        // final updatedConversations =
        //     List<Conversation>.from(currentState.conversations)
        //       ..addAll(result.conversations);

        // emit(ConversationLoaded(
        //   conversations: updatedConversations,
        //   hasMore: result.hasMore,
        //   nextCursor: result.nextCursor,
        // ));
      } catch (e) {
        emit(ConversationError(message: e.toString()));
      }
    }
  }

  /// Handles resetting the conversations state
  void _onResetConversations(
    ResetConversations event,
    Emitter<ConversationState> emit,
  ) {
    emit(ConversationInitial());
  }

  /// Handles creating a new conversation
  Future<void> _onCreateConversation(
    CreateConversation event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationCreating());
    // TODO: Implement when CreateConversationUsecase is available
    emit(const ConversationError(message: "Not implemented yet"));
  }

  /// Handles updating a conversation
  Future<void> _onUpdateConversation(
    UpdateConversation event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationUpdating());
    // TODO: Implement when UpdateConversationUsecase is available
    emit(const ConversationError(message: "Not implemented yet"));
  }

  /// Handles deleting a conversation
  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationDeleting());
    // TODO: Implement when DeleteConversationUsecase is available
    emit(const ConversationError(message: "Not implemented yet"));
  }
}
