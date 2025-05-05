import 'dart:io';
import 'package:aichatbot/presentation/bloc/knowledge_unit/knowledge_unit_event.dart';
import 'package:equatable/equatable.dart';

abstract class FileUploadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Upload a local file
class UploadLocalFileEvent extends FileUploadEvent {
  final String knowledgeId;
  final File file;
  final String accessToken;
  final String? guid;

  UploadLocalFileEvent({
    required this.knowledgeId,
    required this.file,
    required this.accessToken,
    this.guid,
  });

  @override
  List<Object?> get props => [knowledgeId, file.path, accessToken, guid];
}

/// Upload a Google Drive "file" (metadata only)
class UploadGoogleDriveEvent extends FileUploadEvent {
  final String knowledgeId;
  final String id;
  final String name;
  final bool status;
  final String userId;
  final String createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final String? accessToken;

  UploadGoogleDriveEvent({
    required this.knowledgeId,
    required this.id,
    required this.name,
    required this.status,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.accessToken,
  });

  @override
  List<Object?> get props => [
        knowledgeId,
        id,
        name,
        status,
        userId,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        accessToken,
      ];
}

class UploadSlackEvent extends FileUploadEvent {
  final String knowledgeId;
  final String unitName;
  final String slackWorkspace;
  final String slackBotToken;
  final String? accessToken;

  UploadSlackEvent({
    required this.knowledgeId,
    required this.unitName,
    required this.slackWorkspace,
    required this.slackBotToken,
    this.accessToken,
  });

  @override
  List<Object?> get props => [
        knowledgeId,
        unitName,
        slackWorkspace,
        slackBotToken,
        accessToken,
      ];
}

/// Upload a Confluence source
class UploadConfluenceEvent extends FileUploadEvent {
  final String knowledgeId;
  final String unitName;
  final String wikiPageUrl;
  final String confluenceUsername;
  final String confluenceAccessToken;
  final String? accessToken;

  UploadConfluenceEvent({
    required this.knowledgeId,
    required this.unitName,
    required this.wikiPageUrl,
    required this.confluenceUsername,
    required this.confluenceAccessToken,
    this.accessToken,
  });

  @override
  List<Object?> get props => [
        knowledgeId,
        unitName,
        wikiPageUrl,
        confluenceUsername,
        confluenceAccessToken,
        accessToken,
      ];
}

/// Event đẩy lên khi upload từ Web URL
class UploadWebEvent extends FileUploadEvent {
  final String knowledgeId;
  final String unitName;
  final String webUrl;
  final String accessToken;

  UploadWebEvent({
    required this.knowledgeId,
    required this.unitName,
    required this.webUrl,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [knowledgeId, unitName, webUrl, accessToken];
}

/// Reset to initial state
class ResetUploadEvent extends FileUploadEvent {}
