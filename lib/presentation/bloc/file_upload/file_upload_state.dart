import 'package:equatable/equatable.dart';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';

abstract class FileUploadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileUploadInitial extends FileUploadState {}

class FileUploadLoading extends FileUploadState {}

class FileUploadSuccess extends FileUploadState {
  final FileUploadResponse response;

  FileUploadSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class FileUploadError extends FileUploadState {
  final String message;

  FileUploadError({required this.message});

  @override
  List<Object?> get props => [message];
}
