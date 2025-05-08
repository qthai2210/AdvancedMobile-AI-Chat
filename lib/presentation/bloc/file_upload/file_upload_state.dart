import 'package:aichatbot/data/models/knowledge/uploaded_file_model.dart';
import 'package:equatable/equatable.dart';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';

abstract class FileUploadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FileUploadInitial extends FileUploadState {}

class FileRawUploaded extends FileUploadState {
  final UploadedFile file;
  FileRawUploaded(this.file);
  @override
  List<Object?> get props => [file];
}

class FileAttachSuccess extends FileUploadState {
  final FileUploadResponse response;
  FileAttachSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class FileUploadLoading extends FileUploadState {}

class FileUploadError extends FileUploadState {
  final String message;
  FileUploadError([String? m]) : message = m ?? 'Unknown error';
  @override
  List<Object?> get props => [message];
}
