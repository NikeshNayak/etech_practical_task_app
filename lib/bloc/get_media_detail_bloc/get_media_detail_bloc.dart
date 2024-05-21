import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:etech_practical_task_app/models/media_video_model.dart';
import 'package:etech_practical_task_app/repository/get_media_repository.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

part 'get_media_detail_event.dart';
part 'get_media_detail_state.dart';

class GetMediaDetailBloc extends Bloc<GetMediaEvent, GetMediaDetailState> {
  final GetMediaRepository _getMediaRepository = GetMediaRepository();

  GetMediaDetailBloc() : super(GetMediaDetailInitialState()) {
    on<UpdateDownloadProgressMediaDetailEvent>(_updateDownloadProgressEvent);
    on<ResumeDownloadProgressMediaDetailEvent>(_resumeDownloadProgressEvent);
  }

  void _updateDownloadProgressEvent(UpdateDownloadProgressMediaDetailEvent event, Emitter<GetMediaDetailState> emit) async {
    final data = await _getMediaRepository.fetchVideoByTaskId(taskId: event.taskId);
    if (data != null) {
      data.downloadTaskStatus = DownloadTaskStatus.fromInt(event.downloadTaskStatus);
      data.progress = event.progress;
      emit(GetMediaDetailSuccessState(mediaVideoModel: data));
    }
  }

  void _resumeDownloadProgressEvent(ResumeDownloadProgressMediaDetailEvent event, Emitter<GetMediaDetailState> emit) async {
    final data = await _getMediaRepository.fetchVideoById(videoId: event.videoId);
    if (data != null) {
      data.taskId = event.newTaskId;
      data.downloadTaskStatus = DownloadTaskStatus.fromInt(event.downloadTaskStatus);
      data.progress = event.progress;
      emit(GetMediaDetailSuccessState(mediaVideoModel: data));
    }
  }
}
