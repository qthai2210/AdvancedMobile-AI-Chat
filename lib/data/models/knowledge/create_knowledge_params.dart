/// Parameters for creating a new knowledge base
class CreateKnowledgeParams {
  /// The name of the knowledge base (required)
  final String knowledgeName;

  /// Optional description for the knowledge base
  final String? description;

  /// Optional x-jarvis-guid header value
  final String? xJarvisGuid;

  /// Creates parameters for a new knowledge base creation request
  CreateKnowledgeParams({
    required this.knowledgeName,
    this.description,
    this.xJarvisGuid,
  });

  /// Converts the parameters to a map for the API request body
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'knowledgeName': knowledgeName,
    };

    if (description != null) {
      map['description'] = description;
    }

    return map;
  }
}
