import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:etech_practical_task_app/main.dart';
import 'package:etech_practical_task_app/models/media_exception.dart';
import 'package:etech_practical_task_app/models/media_video_model.dart';
import 'package:etech_practical_task_app/repository/get_media_repository.dart';

part 'get_media_event.dart';
part 'get_media_state.dart';

class GetMediaBloc extends Bloc<GetMediaEvent, GetMediaState> {
  final GetMediaRepository _getMediaRepository = GetMediaRepository();

  GetMediaBloc() : super(GetMediaInitialState()) {
    on<GetMediaFetchDataEvent>(_getMediaEvent);
    on<DownloadMediaEvent>(_downloadMediaEvent);
    on<UpdateDownloadProgressEvent>(_updateDownloadProgressEvent);
    on<ResumeDownloadProgressEvent>(_resumeDownloadProgressEvent);
  }

  void _getMediaEvent(GetMediaFetchDataEvent event, Emitter<GetMediaState> emit) async {
    emit(GetMediaLoadingState());
    try {
      bool isInternetAvailable = (await networkManager.isConnected() ?? false);
      if (isInternetAvailable) {
        final data = await _getMediaRepository.fetchMedias();
        if (data.isNotEmpty) {
          emit(GetMediaSuccessState(
            mediaList: data,
          ));
        } else {
          emit(const GetMediaFailedState(
            'Couldn\'t find the medias',
          ));
        }
      } else {
        final data = await _getMediaRepository.fetchLocalMedias();
        if (data.isNotEmpty) {
          emit(GetMediaSuccessState(
            mediaList: data,
          ));
        } else {
          emit(const GetMediaFailedState(
            'Couldn\'t find the medias',
          ));
        }
      }
    } on MediaException catch (err) {
      emit(GetMediaExceptionState(
        err.message,
      ));
    } catch (err) {
      print(err);
      emit(const GetMediaExceptionState(
        'Unexpected Error!',
      ));
    }
  }

  void _downloadMediaEvent(DownloadMediaEvent event, Emitter<GetMediaState> emit) async {
    await _getMediaRepository.downloadVideo(
      videoId: event.videoId,
      taskId: event.taskId,
      filePath: event.filePath,
    );
  }

  void _updateDownloadProgressEvent(UpdateDownloadProgressEvent event, Emitter<GetMediaState> emit) async {
    await _getMediaRepository.updateDownloadProgress(
      taskId: event.taskId,
      downloadTaskStatus: event.downloadTaskStatus,
      progress: event.progress,
    );
  }

  void _resumeDownloadProgressEvent(ResumeDownloadProgressEvent event, Emitter<GetMediaState> emit) async {
    await _getMediaRepository.resumeDownloadProgress(
      videoId: event.videoId,
      newTaskId: event.newTaskId,
      downloadTaskStatus: event.downloadTaskStatus,
      progress: event.progress,
    );
  }
}
