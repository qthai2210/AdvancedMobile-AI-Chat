import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:aichatbot/data/models/knowledge/uploaded_file_model.dart';

abstract class FileUploadEvent extends Equatable {
  const FileUploadEvent();
  @override
  List<Object?> get props => [];
}

/// 1) Upload raw local file
class UploadRawFileEvent extends FileUploadEvent {
  final String knowledgeId;
  final File file;
  final String accessToken;
  const UploadRawFileEvent({
    required this.knowledgeId,
    required this.file,
    required this.accessToken,
  });
  @override
  List<Object?> get props => [knowledgeId, file, accessToken];
}

/// 2) Upload website source
class UploadWebEvent extends FileUploadEvent {
  final String knowledgeId;
  final String unitName;
  final String webUrl;
  final String accessToken;
  const UploadWebEvent({
    required this.knowledgeId,
    required this.unitName,
    required this.webUrl,
    required this.accessToken,
  });
  @override
  List<Object?> get props => [knowledgeId, unitName, webUrl, accessToken];
}

/// 3) Upload Google Drive file
class UploadGoogleDriveEvent extends FileUploadEvent {
  final String knowledgeId;
  final String id;
  final String name;
  final bool status;
  final String userId;
  final String createdAt;
  final String accessToken;
  const UploadGoogleDriveEvent({
    required this.knowledgeId,
    required this.id,
    required this.name,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.accessToken,
  });
  @override
  List<Object?> get props =>
      [knowledgeId, id, name, status, userId, createdAt, accessToken];
}

/// 4) Upload Slack source
class UploadSlackEvent extends FileUploadEvent {
  final String knowledgeId;
  final String name;
  final String slackBotToken;
  final String accessToken;
  const UploadSlackEvent({
    required this.knowledgeId,
    required this.name,
    required this.slackBotToken,
    required this.accessToken,
  });
  @override
  List<Object?> get props => [knowledgeId, name, slackBotToken, accessToken];
}

/// 5) Attach multiple local files as data source
class AttachMultipleLocalFilesEvent extends FileUploadEvent {
  final String knowledgeId;
  final List<UploadedFile> files;
  final String accessToken;
  const AttachMultipleLocalFilesEvent({
    required this.knowledgeId,
    required this.files,
    required this.accessToken,
  });
  @override
  List<Object?> get props => [knowledgeId, files, accessToken];
}
