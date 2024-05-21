import 'dart:io';

import 'package:etech_practical_task_app/bloc/get_media_bloc/get_media_bloc.dart';
import 'package:etech_practical_task_app/main.dart';
import 'package:etech_practical_task_app/models/media_video_model.dart';
import 'package:etech_practical_task_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class GetMediaViewModel extends ChangeNotifier {
  final GetMediaBloc _getMediaBloc;

  GetMediaViewModel(this._getMediaBloc);

  List<MediaVideoModel> mediaVideosList = [];
  MediaVideoModel? videoItem;

  void fetchMedias() {
    _getMediaBloc.add(const GetMediaFetchDataEvent());
  }

  void mediasBlocListener(BuildContext context, GetMediaState state) {
    if (state is GetMediaSuccessState) {
      mediaVideosList = state.mediaList;
    } else if (state is GetMediaFailedState) {
      showSnackMessage(
        context: context,
        title: 'Error',
        text: state.message,
        icon: Icons.error,
      );
    } else if (state is GetMediaExceptionState) {
      showSnackMessage(
        context: context,
        title: 'Error',
        text: state.message,
        icon: Icons.error,
      );
    }
  }

  void updateDownloadProgress(String taskId, DownloadTaskStatus downloadTaskStatus, int progress) {
    int index = mediaVideosList.indexWhere((element) => element.taskId == taskId);
    if (index != -1) {
      mediaVideosList[index].downloadTaskStatus = downloadTaskStatus;
      mediaVideosList[index].progress = progress;
      if (downloadTaskStatus == DownloadTaskStatus.running) {
        _getMediaBloc.add(UpdateDownloadProgressEvent(
          taskId: taskId,
          downloadTaskStatus: downloadTaskStatus.index,
          progress: progress,
        ));
      } else if (downloadTaskStatus == DownloadTaskStatus.complete) {
        _getMediaBloc.add(UpdateDownloadProgressEvent(
          taskId: taskId,
          downloadTaskStatus: downloadTaskStatus.index,
          progress: progress,
        ));
      } else {
        _getMediaBloc.add(UpdateDownloadProgressEvent(
          taskId: taskId,
          downloadTaskStatus: downloadTaskStatus.index,
          progress: progress,
        ));
      }
    }
    print('Download task ($taskId) is in status ($downloadTaskStatus) and process ($progress)');
  }

  void downloadVideo(BuildContext context, int videoId, String url) async {
    bool isInternetAvailable = (await networkManager.isConnected() ?? false);
    if (isInternetAvailable) {
      final directory = Platform.isIOS ? await getApplicationSupportDirectory() : await getExternalStorageDirectory();
      final externalStorageDirPath = directory!.absolute.path;
      final fileName = url.split('/').last;
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        fileName: fileName,
        savedDir: externalStorageDirPath,
        showNotification: false,
      );

      if (taskId != null) {
        int index = mediaVideosList.indexWhere((element) => element.id == videoId);
        mediaVideosList[index].taskId = taskId;
        mediaVideosList[index].sourceFilePath = join(externalStorageDirPath, fileName);
        _getMediaBloc.add(DownloadMediaEvent(
          videoId: videoId,
          taskId: taskId,
          filePath: join(externalStorageDirPath, fileName),
        ));
      }
    } else {
      showSnackMessage(context: context, title: 'Error', text: 'No Internet Connection', icon: Icons.error);
    }
  }

  Future<String?> resumeDownload(BuildContext context, int videoId, String taskId, DownloadTaskStatus status, int progress) async {
    bool isInternetAvailable = (await networkManager.isConnected() ?? false);
    if (isInternetAvailable) {
      final newTaskId = await FlutterDownloader.resume(taskId: taskId);
      if (newTaskId != null) {
        int index = mediaVideosList.indexWhere((element) => element.id == videoId);
        mediaVideosList[index].taskId = newTaskId;
        _getMediaBloc.add(ResumeDownloadProgressEvent(
          videoId: videoId,
          newTaskId: taskId,
          downloadTaskStatus: status.index,
          progress: progress,
        ));
      }
      print('Resume Task :: Old ($taskId) and New ($newTaskId');
      return newTaskId;
    } else {
      showSnackMessage(context: context, title: 'Error', text: 'No Internet Connection', icon: Icons.error);
    }
    return null;
  }

  void pauseDownload(String taskId) async {
    await FlutterDownloader.pause(taskId: taskId);
    print('Pause Task ($taskId)');
  }

  @override
  void dispose() {
    _getMediaBloc.close();
    super.dispose();
  }
}
