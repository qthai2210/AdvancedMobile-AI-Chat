import 'dart:async';
import 'dart:io';
import 'package:aichatbot/domain/usecases/knowledge_unit/attach_datasource_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_raw_file_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_slack_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'file_upload_event.dart';
import 'file_upload_state.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final UploadRawFileUseCase _raw;
  final AttachDatasourceUseCase _attach;
  final UploadSlackFileUseCase _slack;

  FileUploadBloc(
    UploadRawFileUseCase raw,
    AttachDatasourceUseCase attach,
    UploadSlackFileUseCase slack,
  )   : _raw = raw,
        _attach = attach,
        _slack = slack,
        super(FileUploadInitial()) {
    on<UploadRawFileEvent>(_onRaw);
    on<FileAttachEvent>(_onAttachDatasource);
    on<UploadSlackEvent>(_onSlack);
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
      final resp = await _attach(
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

  Future<void> _onSlack(
    UploadSlackEvent e,
    Emitter<FileUploadState> emit,
  ) async {
    emit(FileUploadLoading());
    try {
      final resp = await _slack.execute(
        knowledgeId: e.knowledgeId,
        unitName: e.name,
        slackWorkspace: '',
        slackBotToken: e.slackBotToken,
        accessToken: e.accessToken,
      );
      emit(FileAttachSuccess(resp));
    } catch (ex) {
      emit(FileUploadError(ex.toString()));
    }
  }
}
