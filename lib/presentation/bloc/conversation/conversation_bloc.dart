import 'package:aichatbot/data/models/chat/conversation_request_params.dart';
import 'package:aichatbot/data/models/chat/message_request_model.dart'
    as message;
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
      print("results: ${result.items}");
      // convert results.items to List<Conversation>
      // final conversations =
      //     result.items.map((item) => Conversation.fromJson(item)).toList();

      // emit(ConversationLoaded(
      //   conversations: conversations,
      //   hasMore: result.hasMore,
      //   //nextCursor: result.nextCursor,
      // ));
    } catch (e) {
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
