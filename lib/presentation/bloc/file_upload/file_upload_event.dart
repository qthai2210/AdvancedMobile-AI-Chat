import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class FileUploadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to upload a local file to the knowledge base
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
  List<Object?> get props => [knowledgeId, file, accessToken, guid];
}

/// Event to reset the upload state
class ResetUploadEvent extends FileUploadEvent {}
