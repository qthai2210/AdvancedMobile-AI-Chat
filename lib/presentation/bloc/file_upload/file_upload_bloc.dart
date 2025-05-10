import 'dart:async';
import 'dart:io';
import 'package:aichatbot/domain/usecases/knowledge_unit/attach_multiple_local_file_usecase.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_raw_file_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_slack_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_web_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'file_upload_event.dart';
import 'file_upload_state.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final UploadRawFileUseCase _raw;
  final UploadSlackFileUseCase _slack;
  final UploadWebUseCase _web;
  final AttachMultipleLocalFilesUseCase _attachMultiple;

  FileUploadBloc(
    UploadRawFileUseCase raw,
    UploadSlackFileUseCase slack,
    UploadWebUseCase web,
    AttachMultipleLocalFilesUseCase attachMultiple,
  )   : _raw = raw,
        _slack = slack,
        _web = web,
        _attachMultiple = attachMultiple,
        super(FileUploadInitial()) {
    on<UploadRawFileEvent>(_onRaw);
    on<UploadSlackEvent>(_onSlack);
    on<UploadWebEvent>(_onWeb);
    on<AttachMultipleLocalFilesEvent>(_onAttachMultiple);
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

  Future<void> _onWeb(
    UploadWebEvent e,
    Emitter<FileUploadState> emit,
  ) async {
    emit(FileUploadLoading());
    try {
      final resp = await _web.execute(
        knowledgeId: e.knowledgeId,
        unitName: e.unitName,
        webUrl: e.webUrl,
        accessToken: e.accessToken,
      );
      emit(FileAttachSuccess(resp));
    } catch (ex) {
      emit(FileUploadError(ex.toString()));
    }
  }

  Future<void> _onAttachMultiple(
    AttachMultipleLocalFilesEvent e,
    Emitter<FileUploadState> emit,
  ) async {
    emit(FileUploadLoading());
    try {
      final resp = await _attachMultiple.execute(
        knowledgeId: e.knowledgeId,
        uploadedFiles: e.files,
        accessToken: e.accessToken,
      );
      emit(FileAttachSuccess(resp));
    } catch (ex) {
      emit(FileUploadError(ex.toString()));
    }
  }
}
