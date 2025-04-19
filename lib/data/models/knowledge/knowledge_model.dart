class KnowledgeModel {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? userId;
  final String knowledgeName;
  final String? description;

  KnowledgeModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.userId,
    required this.knowledgeName,
    this.description,
  });

  factory KnowledgeModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeModel(
      id: json['id'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      userId: json['userId'],
      knowledgeName: json['knowledgeName'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'userId': userId,
      'knowledgeName': knowledgeName,
      'description': description,
    };
  }
}
