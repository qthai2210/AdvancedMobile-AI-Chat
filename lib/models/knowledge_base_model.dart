import 'package:flutter/material.dart';

/// Enum defining the different types of knowledge sources
enum KnowledgeSourceType {
  text, // Plain text content
  url, // Web content via URL
  pdf, // PDF document
  docx, // Word document
  csv, // CSV data file
  json, // JSON structured data
  markdown, // Markdown formatted text
  html, // HTML content
  googleDrive, // Google Drive file or folder
  slack, // Slack channel or message thread
  confluence, // Confluence page or space
}

/// Enum for integration status
enum IntegrationStatus { notConnected, connecting, connected, failed, expired }

/// Enum for indexing status
enum IndexingStatus { notIndexed, indexing, indexed, failed, updating }

/// Class representing a single knowledge source
class KnowledgeSource {
  final String id;
  final String title;
  final String description;
  final KnowledgeSourceType type;
  final String content; // Text content or reference path/URL
  final DateTime addedAt;
  final DateTime? lastUpdated;
  final DateTime? lastSynced;
  final bool isEnabled;
  final String? filePath; // Local file path if applicable
  final int? tokenCount; // Approximate token count for this source
  final IconData icon;
  final List<String>? tags; // Optional tags for categorization
  final Map<String, dynamic>? metadata; // Additional source-specific metadata
  final IndexingStatus indexingStatus; // Status of indexing for this source
  final IntegrationCredential? credential; // Credential for external sources
  final String? sourceId; // ID for external sources (like Google Drive file ID)

  KnowledgeSource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    required this.addedAt,
    this.lastUpdated,
    this.lastSynced,
    this.isEnabled = true,
    this.filePath,
    this.tokenCount,
    IconData? icon,
    this.tags,
    this.metadata,
    this.indexingStatus = IndexingStatus.notIndexed,
    this.credential,
    this.sourceId,
  }) : icon = icon ?? getDefaultIcon(type);

  /// Get a default icon based on the knowledge source type
  static IconData getDefaultIcon(KnowledgeSourceType type) {
    switch (type) {
      case KnowledgeSourceType.text:
        return Icons.text_snippet;
      case KnowledgeSourceType.url:
        return Icons.link;
      case KnowledgeSourceType.pdf:
        return Icons.picture_as_pdf;
      case KnowledgeSourceType.docx:
        return Icons.description;
      case KnowledgeSourceType.csv:
        return Icons.table_chart;
      case KnowledgeSourceType.json:
        return Icons.data_object;
      case KnowledgeSourceType.markdown:
        return Icons.notes;
      case KnowledgeSourceType.html:
        return Icons.html;
      case KnowledgeSourceType.googleDrive:
        return Icons.drive_folder_upload;
      case KnowledgeSourceType.slack:
        return Icons.forum;
      case KnowledgeSourceType.confluence:
        return Icons.book_online;
    }
  }

  /// Create a copy of this source with modified parameters
  KnowledgeSource copyWith({
    String? id,
    String? title,
    String? description,
    KnowledgeSourceType? type,
    String? content,
    DateTime? addedAt,
    DateTime? lastUpdated,
    DateTime? lastSynced,
    bool? isEnabled,
    String? filePath,
    int? tokenCount,
    IconData? icon,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    IndexingStatus? indexingStatus,
    IntegrationCredential? credential,
    String? sourceId,
  }) {
    return KnowledgeSource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      content: content ?? this.content,
      addedAt: addedAt ?? this.addedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastSynced: lastSynced ?? this.lastSynced,
      isEnabled: isEnabled ?? this.isEnabled,
      filePath: filePath ?? this.filePath,
      tokenCount: tokenCount ?? this.tokenCount,
      icon: icon ?? this.icon,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      indexingStatus: indexingStatus ?? this.indexingStatus,
      credential: credential ?? this.credential,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  /// Get an appropriate color for the knowledge source type
  static Color getColorForType(KnowledgeSourceType type) {
    switch (type) {
      case KnowledgeSourceType.text:
        return Colors.blue;
      case KnowledgeSourceType.url:
        return Colors.green;
      case KnowledgeSourceType.pdf:
        return Colors.red;
      case KnowledgeSourceType.docx:
        return Colors.blue.shade800;
      case KnowledgeSourceType.csv:
        return Colors.orange;
      case KnowledgeSourceType.json:
        return Colors.purple;
      case KnowledgeSourceType.markdown:
        return Colors.teal;
      case KnowledgeSourceType.html:
        return Colors.amber;
      case KnowledgeSourceType.googleDrive:
        return const Color(0xFF0F9D58); // Google Drive green
      case KnowledgeSourceType.slack:
        return const Color(0xFF4A154B); // Slack purple
      case KnowledgeSourceType.confluence:
        return const Color(0xFF0052CC); // Confluence blue
    }
  }

  /// Get a human-readable name for the knowledge source type
  static String getTypeName(KnowledgeSourceType type) {
    switch (type) {
      case KnowledgeSourceType.text:
        return 'Text';
      case KnowledgeSourceType.url:
        return 'Website URL';
      case KnowledgeSourceType.pdf:
        return 'PDF File';
      case KnowledgeSourceType.docx:
        return 'Word Document';
      case KnowledgeSourceType.csv:
        return 'CSV File';
      case KnowledgeSourceType.json:
        return 'JSON Data';
      case KnowledgeSourceType.markdown:
        return 'Markdown';
      case KnowledgeSourceType.html:
        return 'HTML';
      case KnowledgeSourceType.googleDrive:
        return 'Google Drive';
      case KnowledgeSourceType.slack:
        return 'Slack';
      case KnowledgeSourceType.confluence:
        return 'Confluence';
    }
  }

  /// Check if this source has file content
  bool get isFileType {
    return type == KnowledgeSourceType.pdf ||
        type == KnowledgeSourceType.csv ||
        type == KnowledgeSourceType.json ||
        type == KnowledgeSourceType.docx;
  }

  /// Check if this source requires external authentication
  bool get requiresAuthentication {
    return type == KnowledgeSourceType.googleDrive ||
        type == KnowledgeSourceType.slack ||
        type == KnowledgeSourceType.confluence;
  }

  /// Check if the source supports automatic syncing
  bool get supportsSyncing {
    return type == KnowledgeSourceType.url ||
        type == KnowledgeSourceType.googleDrive ||
        type == KnowledgeSourceType.slack ||
        type == KnowledgeSourceType.confluence;
  }
}

/// Base class for integration credentials
abstract class IntegrationCredential {
  final String id;
  final String name;
  final IntegrationStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;

  IntegrationCredential({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Map<String, dynamic> toJson();
}

/// Google Drive credentials
class GoogleDriveCredential extends IntegrationCredential {
  final String accessToken;
  final String refreshToken;
  final String email;

  GoogleDriveCredential({
    required super.id,
    required super.name,
    required super.status,
    required super.createdAt,
    super.expiresAt,
    required this.accessToken,
    required this.refreshToken,
    required this.email,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'email': email,
      'type': 'google_drive',
    };
  }

  factory GoogleDriveCredential.fromJson(Map<String, dynamic> json) {
    return GoogleDriveCredential(
      id: json['id'],
      name: json['name'],
      status: IntegrationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => IntegrationStatus.notConnected,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      email: json['email'],
    );
  }
}

/// Slack credentials
class SlackCredential extends IntegrationCredential {
  final String accessToken;
  final String teamId;
  final String teamName;

  SlackCredential({
    required super.id,
    required super.name,
    required super.status,
    required super.createdAt,
    super.expiresAt,
    required this.accessToken,
    required this.teamId,
    required this.teamName,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'accessToken': accessToken,
      'teamId': teamId,
      'teamName': teamName,
      'type': 'slack',
    };
  }

  factory SlackCredential.fromJson(Map<String, dynamic> json) {
    return SlackCredential(
      id: json['id'],
      name: json['name'],
      status: IntegrationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => IntegrationStatus.notConnected,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      accessToken: json['accessToken'],
      teamId: json['teamId'],
      teamName: json['teamName'],
    );
  }
}

/// Confluence credentials
class ConfluenceCredential extends IntegrationCredential {
  final String accessToken;
  final String domain;
  final String? cloudId;
  final bool isCloud;

  ConfluenceCredential({
    required super.id,
    required super.name,
    required super.status,
    required super.createdAt,
    super.expiresAt,
    required this.accessToken,
    required this.domain,
    required this.isCloud,
    this.cloudId,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'accessToken': accessToken,
      'domain': domain,
      'cloudId': cloudId,
      'isCloud': isCloud,
      'type': 'confluence',
    };
  }

  factory ConfluenceCredential.fromJson(Map<String, dynamic> json) {
    return ConfluenceCredential(
      id: json['id'],
      name: json['name'],
      status: IntegrationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => IntegrationStatus.notConnected,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      accessToken: json['accessToken'],
      domain: json['domain'],
      isCloud: json['isCloud'] ?? true,
      cloudId: json['cloudId'],
    );
  }
}

/// Google Drive specific metadata
class GoogleDriveMetadata {
  final String fileId;
  final String? folderId;
  final String mimeType;
  final int size; // in bytes
  final String? webViewLink;
  final DateTime? lastModified;
  final bool isShared;

  GoogleDriveMetadata({
    required this.fileId,
    this.folderId,
    required this.mimeType,
    required this.size,
    this.webViewLink,
    this.lastModified,
    this.isShared = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'folderId': folderId,
      'mimeType': mimeType,
      'size': size,
      'webViewLink': webViewLink,
      'lastModified': lastModified?.toIso8601String(),
      'isShared': isShared,
    };
  }

  factory GoogleDriveMetadata.fromJson(Map<String, dynamic> json) {
    return GoogleDriveMetadata(
      fileId: json['fileId'],
      folderId: json['folderId'],
      mimeType: json['mimeType'],
      size: json['size'],
      webViewLink: json['webViewLink'],
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : null,
      isShared: json['isShared'] ?? false,
    );
  }
}

/// Slack specific metadata
class SlackMetadata {
  final String channelId;
  final String channelName;
  final String? threadTs;
  final int messageCount;
  final DateTime? oldestMessage;

  SlackMetadata({
    required this.channelId,
    required this.channelName,
    this.threadTs,
    required this.messageCount,
    this.oldestMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'channelId': channelId,
      'channelName': channelName,
      'threadTs': threadTs,
      'messageCount': messageCount,
      'oldestMessage': oldestMessage?.toIso8601String(),
    };
  }

  factory SlackMetadata.fromJson(Map<String, dynamic> json) {
    return SlackMetadata(
      channelId: json['channelId'],
      channelName: json['channelName'],
      threadTs: json['threadTs'],
      messageCount: json['messageCount'],
      oldestMessage: json['oldestMessage'] != null
          ? DateTime.parse(json['oldestMessage'])
          : null,
    );
  }
}

/// Confluence specific metadata
class ConfluenceMetadata {
  final String pageId;
  final String? spaceKey;
  final String spaceName;
  final String? pageVersion;
  final String? parentId;
  final List<String>? labels;

  ConfluenceMetadata({
    required this.pageId,
    this.spaceKey,
    required this.spaceName,
    this.pageVersion,
    this.parentId,
    this.labels,
  });

  Map<String, dynamic> toJson() {
    return {
      'pageId': pageId,
      'spaceKey': spaceKey,
      'spaceName': spaceName,
      'pageVersion': pageVersion,
      'parentId': parentId,
      'labels': labels,
    };
  }

  factory ConfluenceMetadata.fromJson(Map<String, dynamic> json) {
    return ConfluenceMetadata(
      pageId: json['pageId'],
      spaceKey: json['spaceKey'],
      spaceName: json['spaceName'],
      pageVersion: json['pageVersion'],
      parentId: json['parentId'],
      labels: json['labels'] != null ? List<String>.from(json['labels']) : null,
    );
  }
}

/// Website metadata
class WebsiteMetadata {
  final String url;
  final bool shouldCrawlLinks;
  final int maxPagesToCrawl;
  final int crawlDepth;
  final bool followSitemap;
  final bool respectRobotsTxt;
  final DateTime? lastCrawled;
  final int totalPagesCrawled;

  WebsiteMetadata({
    required this.url,
    this.shouldCrawlLinks = true,
    this.maxPagesToCrawl = 10,
    this.crawlDepth = 1,
    this.followSitemap = true,
    this.respectRobotsTxt = true,
    this.lastCrawled,
    this.totalPagesCrawled = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'shouldCrawlLinks': shouldCrawlLinks,
      'maxPagesToCrawl': maxPagesToCrawl,
      'crawlDepth': crawlDepth,
      'followSitemap': followSitemap,
      'respectRobotsTxt': respectRobotsTxt,
      'lastCrawled': lastCrawled?.toIso8601String(),
      'totalPagesCrawled': totalPagesCrawled,
    };
  }

  factory WebsiteMetadata.fromJson(Map<String, dynamic> json) {
    return WebsiteMetadata(
      url: json['url'],
      shouldCrawlLinks: json['shouldCrawlLinks'] ?? true,
      maxPagesToCrawl: json['maxPagesToCrawl'] ?? 10,
      crawlDepth: json['crawlDepth'] ?? 1,
      followSitemap: json['followSitemap'] ?? true,
      respectRobotsTxt: json['respectRobotsTxt'] ?? true,
      lastCrawled: json['lastCrawled'] != null
          ? DateTime.parse(json['lastCrawled'])
          : null,
      totalPagesCrawled: json['totalPagesCrawled'] ?? 0,
    );
  }
}

/// Class representing a collection of knowledge sources
class KnowledgeBase {
  final String id;
  final String name;
  final String description;
  final List<KnowledgeSource>? sources;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final bool isEnabled;
  final String? botId; // Optional reference to an associated bot
  final String? category; // Optional category for grouping
  final List<String>? tags; // Optional tags
  final int?
      maxTokenLimit; // Optional token limit for the entire knowledge base
  final List<IntegrationCredential>
      credentials; // Credentials for external services

  const KnowledgeBase({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.sources, // đã là optional, không bắt buộc
    this.isEnabled = true,
    this.botId,
    this.category,
    this.tags,
    this.maxTokenLimit,
    this.credentials = const [],
  });

  /// Get the count of active sources
  int get activeSourcesCount =>
      sources?.where((source) => source.isEnabled).length ?? 0;

  /// Get the total number of sources
  int get totalSourcesCount => sources?.length ?? 0;

  /// Estimate the total token count for this knowledge base
  int get estimatedTokenCount {
    if (sources == null) return 0;
    return sources!
        .where((source) => source.isEnabled && source.tokenCount != null)
        .fold(0, (sum, source) => sum + (source.tokenCount ?? 0));
  }

  /// Check if this knowledge base exceeds its token limit
  bool get isOverTokenLimit {
    if (maxTokenLimit == null) return false;
    return estimatedTokenCount > maxTokenLimit!;
  }

  /// Check if any sources require syncing
  bool get requiresSyncing {
    return sources?.any((source) =>
            source.isEnabled &&
            source.supportsSyncing &&
            (source.lastSynced == null ||
                DateTime.now().difference(source.lastSynced!).inDays > 7)) ??
        false;
  }

  /// Get sources by type
  List<KnowledgeSource> getSourcesByType(KnowledgeSourceType type) {
    return sources?.where((source) => source.type == type).toList() ?? [];
  }

  /// Find credential by ID
  IntegrationCredential? getCredentialById(String id) {
    try {
      return credentials.firstWhere((cred) => cred.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find credential by type
  T? getCredential<T extends IntegrationCredential>() {
    for (final credential in credentials) {
      if (credential is T) {
        return credential;
      }
    }
    return null;
  }

  /// Create a copy of this knowledge base with modified parameters
  KnowledgeBase copyWith({
    String? id,
    String? name,
    String? description,
    List<KnowledgeSource>? sources,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    bool? isEnabled,
    String? botId,
    String? category,
    List<String>? tags,
    int? maxTokenLimit,
    List<IntegrationCredential>? credentials,
  }) {
    return KnowledgeBase(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sources: sources ?? this.sources,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isEnabled: isEnabled ?? this.isEnabled,
      botId: botId ?? this.botId,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      maxTokenLimit: maxTokenLimit ?? this.maxTokenLimit,
      credentials: credentials ?? this.credentials,
    );
  }

  /// Add a new knowledge source to this knowledge base
  KnowledgeBase addSource(KnowledgeSource source) {
    final List<KnowledgeSource> updatedSources;
    if (sources == null) {
      updatedSources = [source];
    } else {
      updatedSources = List<KnowledgeSource>.from(sources!)..add(source);
    }

    return copyWith(
      sources: updatedSources,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Update an existing knowledge source
  KnowledgeBase updateSource(KnowledgeSource updatedSource) {
    if (sources == null) return this;

    final updatedSources = sources!.map((source) {
      if (source.id == updatedSource.id) {
        return updatedSource;
      }
      return source;
    }).toList();

    return copyWith(
      sources: updatedSources,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Remove a knowledge source
  KnowledgeBase removeSource(String sourceId) {
    if (sources == null) return this;

    final updatedSources =
        sources!.where((source) => source.id != sourceId).toList();
    return copyWith(
      sources: updatedSources,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Add a new credential
  KnowledgeBase addCredential(IntegrationCredential credential) {
    final updatedCredentials = List<IntegrationCredential>.from(credentials)
      ..add(credential);
    return copyWith(
      credentials: updatedCredentials,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Update an existing credential
  KnowledgeBase updateCredential(IntegrationCredential updatedCredential) {
    final updatedCredentials = credentials.map((cred) {
      if (cred.id == updatedCredential.id) {
        return updatedCredential;
      }
      return cred;
    }).toList();

    return copyWith(
      credentials: updatedCredentials,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Remove a credential
  KnowledgeBase removeCredential(String credentialId) {
    final updatedCredentials =
        credentials.where((cred) => cred.id != credentialId).toList();
    return copyWith(
      credentials: updatedCredentials,
      lastUpdatedAt: DateTime.now(),
    );
  }
}

/// Utility class for creating empty/demo knowledge bases
class KnowledgeBaseFactory {
  /// Create an empty knowledge base
  static KnowledgeBase createEmpty({
    required String name,
    String? description,
    String? botId,
  }) {
    final now = DateTime.now();
    return KnowledgeBase(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      description: description ?? 'Knowledge base for $name',
      sources: [],
      createdAt: now,
      lastUpdatedAt: now,
      botId: botId,
    );
  }

  /// Create a knowledge base with a sample text source
  static KnowledgeBase createWithSampleData({
    required String name,
    String? description,
    String? botId,
  }) {
    final now = DateTime.now();
    final sampleSource = KnowledgeSource(
      id: '${now.millisecondsSinceEpoch}_sample',
      title: 'Sample Text Data',
      description: 'This is a sample text source for your knowledge base',
      type: KnowledgeSourceType.text,
      content:
          'This is sample content for your knowledge base. Replace this with your actual knowledge data.',
      addedAt: now,
      tags: ['sample', 'demo'],
    );

    return KnowledgeBase(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      description: description ?? 'Knowledge base for $name with sample data',
      sources: [sampleSource],
      createdAt: now,
      lastUpdatedAt: now,
      botId: botId,
    );
  }
}
