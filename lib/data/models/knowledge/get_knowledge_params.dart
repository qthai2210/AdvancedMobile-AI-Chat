/// Parameters for fetching knowledge items from the API
class GetKnowledgeParams {
  final String? query;
  final String? order;
  final String? orderField;
  final int offset;
  final int limit;

  /// Creates a new instance of [GetKnowledgeParams]
  ///
  /// [query] - Optional search query string
  /// [order] - Sort order (ASC or DESC)
  /// [orderField] - Field to order by (e.g., "createdAt")
  /// [offset] - Starting position for pagination
  /// [limit] - Maximum number of results to return (1-50)
  GetKnowledgeParams({
    this.query,
    this.order = 'DESC',
    this.orderField,
    this.offset = 0,
    this.limit = 10,
  });

  /// Converts the parameters to a map for use in API requests
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (query != null && query!.isNotEmpty) {
      params['q'] = query;
    }

    if (order != null) {
      params['order'] = order;
    }

    if (orderField != null && orderField!.isNotEmpty) {
      params['order_field'] = orderField;
    }

    params['offset'] = offset.toString();
    params['limit'] = limit.toString();

    return params;
  }
}
