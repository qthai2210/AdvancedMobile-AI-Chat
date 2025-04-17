import 'package:aichatbot/data/models/chat/conversation_request_params.dart';

class ConversationHistoryParams {
  final String conversationId;
  final String? cursor;
  final int? limit;
  final AssistantId? assistantId;
  final AssistantModel assistantModel;

  ConversationHistoryParams({
    required this.conversationId,
    this.cursor,
    this.limit,
    this.assistantId,
    required this.assistantModel,
  });

  Map<String, dynamic> toQueryParams() {
    final queryParams = <String, dynamic>{
      'assistantModel': assistantModel.toString(),
    };

    if (cursor != null) queryParams['cursor'] = cursor;
    if (limit != null) queryParams['limit'] = limit;
    if (assistantId != null)
      queryParams['assistantId'] = assistantId.toString();

    return queryParams;
  }
}
