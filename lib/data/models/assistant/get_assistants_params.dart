/// Enum for sort order options in API requests
enum SortOrder {
  ASC,
  DESC;

  @override
  String toString() => name;
}

/// Request parameters for retrieving AI assistants
class GetAssistantsParams {
  /// Search query string
  final String? q;

  /// Sort order (ASC or DESC)
  final SortOrder? order;

  /// Field to order by (e.g., "createdAt")
  final String? orderField;

  /// Starting offset for pagination
  final int? offset;

  /// Maximum number of results to return
  final int? limit;

  /// Filter by favorite status
  final bool? isFavorite;

  /// Filter by published status
  final bool? isPublished;

  /// Optional GUID for tracking
  final String? xJarvisGuid;

  GetAssistantsParams({
    this.q,
    this.order,
    this.orderField,
    this.offset,
    this.limit,
    this.isFavorite,
    this.isPublished,
    this.xJarvisGuid,
  });

  /// Converts parameters to query parameters map for API request
  Map<String, dynamic> toQueryParameters() {
    final queryParams = <String, dynamic>{};

    if (q != null && q!.isNotEmpty) {
      queryParams['q'] = q;
    }
    if (order != null) {
      queryParams['order'] = order.toString();
    }
    if (orderField != null && orderField!.isNotEmpty) {
      queryParams['order_field'] = orderField;
    }
    if (offset != null) {
      queryParams['offset'] = offset.toString();
    }
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }
    if (isFavorite != null) {
      queryParams['is_favorite'] = isFavorite.toString();
    }
    if (isPublished != null) {
      queryParams['is_published'] = isPublished.toString();
    }

    return queryParams;
  }
}
