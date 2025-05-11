import 'package:equatable/equatable.dart';

/// Event to link a knowledge base to an assistant
class LinkKnowledgeToAssistantEvent extends Equatable {
  final String assistantId;
  final String knowledgeId;
  final String? accessToken;
  final String? xJarvisGuid;

  const LinkKnowledgeToAssistantEvent({
    required this.assistantId,
    required this.knowledgeId,
    this.accessToken,
    this.xJarvisGuid,
  });

  @override
  List<Object?> get props =>
      [assistantId, knowledgeId, accessToken, xJarvisGuid];
}
