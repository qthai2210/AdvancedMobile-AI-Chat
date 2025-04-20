class GetKnowledgeUnitsParams {
  final String knowledgeId;
  final String? query;
  final String order;
  final String orderField;
  final int offset;
  final int limit;
  final String? accessToken;
  final String? xJarvisGuid;

  GetKnowledgeUnitsParams({
    required this.knowledgeId,
    this.query,
    this.order = 'DESC',
    this.orderField = 'createdAt',
    this.offset = 0,
    this.limit = 20,
    this.accessToken,
    this.xJarvisGuid,
  });

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {
      'order': order,
      'order_field': orderField,
      'offset': offset.toString(),
      'limit': limit.toString(),
    };

    if (query != null && query!.isNotEmpty) {
      params['q'] = query;
    }

    return params;
  }
}
