/// The Assistant ID enumeration representing different AI models
enum AssistantId {
  CLAUDE_35_SONNET_20240620,
  CLAUDE_3_HAIKU_20240307,
  GEMINI_15_FLASH_LATEST,
  GEMINI_15_PRO_LATEST,
  GPT_4_O,
  GPT_4_O_MINI;

  @override
  String toString() {
    switch (this) {
      case AssistantId.CLAUDE_35_SONNET_20240620:
        return 'claude-3-5-sonnet-20240620';
      case AssistantId.CLAUDE_3_HAIKU_20240307:
        return 'claude-3-haiku-20240307';
      case AssistantId.GEMINI_15_FLASH_LATEST:
        return 'gemini-1.5-flash-latest';
      case AssistantId.GEMINI_15_PRO_LATEST:
        return 'gemini-1.5-pro-latest';
      case AssistantId.GPT_4_O:
        return 'gpt-4o';
      case AssistantId.GPT_4_O_MINI:
        return 'gpt-4o-mini';
    }
  }
}

/// The Assistant Model type - currently only supports "dify"
enum AssistantModel {
  dify;

  @override
  String toString() {
    return 'dify';
  }
}

/// Request parameters for getting conversations
class ConversationRequestParams {
  /// The selected model's ID
  final AssistantId? assistantId;

  /// Always "dify" for the assistant model
  final AssistantModel assistantModel;

  /// Cursor for pagination
  final String? cursor;

  /// Limit for number of results to return
  final int? limit;

  ConversationRequestParams({
    this.assistantId,
    required this.assistantModel,
    this.cursor,
    this.limit,
  });

  /// Convert to query parameters for API request
  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {
      'assistant_model': assistantModel.toString(),
    };

    if (assistantId != null) {
      params['assistant_id'] = assistantId.toString();
    }

    if (cursor != null) {
      params['cursor'] = cursor;
    }

    if (limit != null) {
      params['limit'] = limit;
    }

    return params;
  }
}
