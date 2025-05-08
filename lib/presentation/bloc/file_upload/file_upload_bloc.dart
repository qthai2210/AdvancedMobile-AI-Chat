import 'dart:async';
import 'dart:io';
import 'package:aichatbot/domain/usecases/knowledge_unit/attach_datasource_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_raw_file_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'file_upload_event.dart';
import 'file_upload_state.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final UploadRawFileUseCase _raw;
  final AttachDatasourceUseCase attachDatasourceUseCase;

  FileUploadBloc(
    UploadRawFileUseCase raw,
    AttachDatasourceUseCase attachDatasource,
  )   : _raw = raw,
        attachDatasourceUseCase = attachDatasource,
        super(FileUploadInitial()) {
    on<UploadRawFileEvent>(_onRaw);
    on<FileAttachEvent>(_onAttachDatasource);
  }

  Future<void> _onRaw(
    UploadRawFileEvent e,
    Emitter<FileUploadState> emit,
  ) async {
    emit(FileUploadLoading());
    try {
      final file = await _raw.execute(
        file: e.file,
        accessToken: e.accessToken,
      );
      emit(FileRawUploaded(file));
    } catch (ex) {
      emit(FileUploadError(ex.toString()));
    }
  }

  Future<void> _onAttachDatasource(
    FileAttachEvent event,
    Emitter<FileUploadState> emit,
  ) async {
    emit(FileUploadLoading());
    try {
      final resp = await attachDatasourceUseCase(
        knowledgeId: event.knowledgeId,
        fileId: event.fileId,
        fileName: event.fileName,
        accessToken: event.accessToken,
      );
      emit(FileAttachSuccess(resp));
    } catch (e) {
      emit(FileUploadError(e.toString()));
    }
  }
}
