part of 'get_media_detail_bloc.dart';

sealed class GetMediaEvent extends Equatable {
  const GetMediaEvent();

  @override
  List<Object?> get props => [];
}

class UpdateDownloadProgressMediaDetailEvent extends GetMediaEvent {
  final String taskId;
  final int downloadTaskStatus;
  final int progress;

  const UpdateDownloadProgressMediaDetailEvent({
    required this.taskId,
    required this.downloadTaskStatus,
    required this.progress,
  });
}

class ResumeDownloadProgressMediaDetailEvent extends GetMediaEvent {
  final int videoId;
  final String newTaskId;
  final int downloadTaskStatus;
  final int progress;

  const ResumeDownloadProgressMediaDetailEvent({
    required this.videoId,
    required this.newTaskId,
    required this.downloadTaskStatus,
    required this.progress,
  });
}
