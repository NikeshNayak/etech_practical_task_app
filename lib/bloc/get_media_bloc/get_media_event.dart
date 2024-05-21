part of 'get_media_bloc.dart';

sealed class GetMediaEvent extends Equatable {
  const GetMediaEvent();

  @override
  List<Object?> get props => [];
}

class GetMediaFetchDataEvent extends GetMediaEvent {
  const GetMediaFetchDataEvent();
}

class DownloadMediaEvent extends GetMediaEvent {
  final int videoId;
  final String taskId;
  final String filePath;

  const DownloadMediaEvent({
    required this.videoId,
    required this.taskId,
    required this.filePath,
  });
}

class UpdateDownloadProgressEvent extends GetMediaEvent {
  final String taskId;
  final int downloadTaskStatus;
  final int progress;

  const UpdateDownloadProgressEvent({
    required this.taskId,
    required this.downloadTaskStatus,
    required this.progress,
  });
}

class ResumeDownloadProgressEvent extends GetMediaEvent {
  final int videoId;
  final String newTaskId;
  final int downloadTaskStatus;
  final int progress;

  const ResumeDownloadProgressEvent({
    required this.videoId,
    required this.newTaskId,
    required this.downloadTaskStatus,
    required this.progress,
  });
}
