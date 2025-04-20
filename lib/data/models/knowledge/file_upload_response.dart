class FileUploadResponse {
  final String name;
  final String type;
  final int size;
  final String userId;
  final String knowledgeId;
  final List<String> openAiFileIds;
  final FileMetadata metadata;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final bool status;

  FileUploadResponse({
    required this.name,
    required this.type,
    required this.size,
    required this.userId,
    required this.knowledgeId,
    required this.openAiFileIds,
    required this.metadata,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.status,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      name: json['name'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
      userId: json['userId'] as String,
      knowledgeId: json['knowledgeId'] as String,
      openAiFileIds:
          (json['openAiFileIds'] as List).map((e) => e as String).toList(),
      metadata: FileMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      id: json['id'] as String,
      status: json['status'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'size': size,
      'userId': userId,
      'knowledgeId': knowledgeId,
      'openAiFileIds': openAiFileIds,
      'metadata': metadata.toJson(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'id': id,
      'status': status,
    };
  }
}

class FileMetadata {
  final String mimetype;
  final String name;

  FileMetadata({
    required this.mimetype,
    required this.name,
  });

  factory FileMetadata.fromJson(Map<String, dynamic> json) {
    return FileMetadata(
      mimetype: json['mimetype'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mimetype': mimetype,
      'name': name,
    };
  }
}
