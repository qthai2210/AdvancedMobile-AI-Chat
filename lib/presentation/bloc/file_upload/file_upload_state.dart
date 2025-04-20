import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:equatable/equatable.dart';

abstract class FileUploadState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state of the file upload
class FileUploadInitial extends FileUploadState {}

/// State when file upload is in progress
class FileUploadLoading extends FileUploadState {}

/// State when file upload is successful
class FileUploadSuccess extends FileUploadState {
  final FileUploadResponse response;

  FileUploadSuccess({required this.response});

  @override
  List<Object> get props => [response];
}

/// State when file upload fails
class FileUploadError extends FileUploadState {
  final String message;

  FileUploadError({required this.message});

  @override
  List<Object> get props => [message];
}
