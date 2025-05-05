import 'dart:async';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_confluence_file_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_google_drive_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_slack_use_case.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_web_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aichatbot/utils/logger.dart';
import 'package:aichatbot/data/models/knowledge/file_upload_response.dart';
import 'package:aichatbot/domain/usecases/knowledge_unit/upload_local_file_use_case.dart';
import 'file_upload_event.dart';
import 'file_upload_state.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final UploadLocalFileUseCase _uploadLocal;
  final UploadGoogleDriveFileUseCase _uploadGDrive;
  final UploadSlackFileUseCase _uploadSlack;
  final UploadConfluenceFileUseCase _uploadConfluence;
  final UploadWebUseCase _uploadWeb;

  FileUploadBloc({
    required UploadLocalFileUseCase uploadLocalFileUseCase,
    required UploadGoogleDriveFileUseCase uploadGoogleDriveFileUseCase,
    required UploadSlackFileUseCase uploadSlackFileUseCase,
    required UploadConfluenceFileUseCase uploadConfluenceFileUseCase,
    required UploadWebUseCase uploadWebUseCase,
  })  : _uploadLocal = uploadLocalFileUseCase,
        _uploadGDrive = uploadGoogleDriveFileUseCase,
        _uploadSlack = uploadSlackFileUseCase,
        _uploadConfluence = uploadConfluenceFileUseCase,
        _uploadWeb = uploadWebUseCase,
        super(FileUploadInitial()) {
    on<UploadLocalFileEvent>(_onUploadLocalFile);
    on<UploadGoogleDriveEvent>(_onUploadGoogleDrive);
    on<UploadSlackEvent>(_onUploadSlack);
    on<UploadConfluenceEvent>(_onUploadConfluence);
    on<UploadWebEvent>(_onUploadWeb);
    on<ResetUploadEvent>(_onResetUpload);
  }

  FutureOr<void> _onUploadLocalFile(
    UploadLocalFileEvent event,
    Emitter<FileUploadState> emit,
  ) async {
    emit(FileUploadLoading());
    try {
      final FileUploadResponse resp = await _uploadLocal.execute(
        knowledgeId: event.knowledgeId,
        file: event.file,
        accessToken: event.accessToken,
        guid: event.guid,
      );
      AppLogger.d('Local file uploaded: ${resp.name}');
      emit(FileUploadSuccess(response: resp));
    } catch (e, st) {
      AppLogger.e('Local upload failed: $e\n$st');
      emit(FileUploadError(message: e.toString()));
    }
  }

  FutureOr<void> _onUploadGoogleDrive(
    UploadGoogleDriveEvent event,
    Emitter<FileUploadState> emit,
  ) async {
    emit(FileUploadLoading());
    try {
      final FileUploadResponse resp = await _uploadGDrive.call(
        knowledgeId: event.knowledgeId,
        id: event.id,
        name: event.name,
        status: event.status,
        userId: event.userId,
        createdAt: event.createdAt,
        updatedAt: event.updatedAt,
        createdBy: event.createdBy,
        updatedBy: event.updatedBy,
        accessToken: event.accessToken,
      );
      AppLogger.d('Google Drive metadata uploaded: ${resp.name}');
      emit(FileUploadSuccess(response: resp));
    } catch (e, st) {
      AppLogger.e('Google Drive upload failed: $e\n$st');
      emit(FileUploadError(message: e.toString()));
    }
  }

  FutureOr<void> _onUploadSlack(
    UploadSlackEvent event,
    Emitter<FileUploadState> emit,
  ) async {
    emit(FileUploadLoading());
    try {
      final FileUploadResponse resp = await _uploadSlack.execute(
        knowledgeId: event.knowledgeId,
        unitName: event.unitName,
        slackWorkspace: event.slackWorkspace,
        slackBotToken: event.slackBotToken,
        accessToken: event.accessToken,
      );
      AppLogger.d('Slack source uploaded: ${resp.name}');
      emit(FileUploadSuccess(response: resp));
    } catch (e, st) {
      AppLogger.e('Slack upload failed: $e\n$st');
      emit(FileUploadError(message: e.toString()));
    }
  }

  FutureOr<void> _onUploadConfluence(
    UploadConfluenceEvent event,
    Emitter<FileUploadState> emit,
  ) async {
    emit(FileUploadLoading());
    try {
      final resp = await _uploadConfluence.execute(
        knowledgeId: event.knowledgeId,
        unitName: event.unitName,
        wikiPageUrl: event.wikiPageUrl,
        confluenceUsername: event.confluenceUsername,
        confluenceAccessToken: event.confluenceAccessToken,
        accessToken: event.accessToken,
      );
      AppLogger.d('Confluence source uploaded: ${resp.name}');
      emit(FileUploadSuccess(response: resp));
    } catch (e, st) {
      AppLogger.e('Confluence upload failed: $e\n$st');
      emit(FileUploadError(message: e.toString()));
    }
  }

  Future<void> _onUploadWeb(
      UploadWebEvent e, Emitter<FileUploadState> emit) async {
    emit(FileUploadLoading());
    try {
      final resp = await _uploadWeb.execute(
        knowledgeId: e.knowledgeId,
        unitName: e.unitName,
        webUrl: e.webUrl,
        accessToken: e.accessToken,
      );
      emit(FileUploadSuccess(response: resp));
    } catch (ex) {
      emit(FileUploadError(message: ex.toString()));
    }
  }

  void _onResetUpload(
    ResetUploadEvent event,
    Emitter<FileUploadState> emit,
  ) {
    emit(FileUploadInitial());
  }
}
