import 'package:dio/dio.dart';
import 'package:etech_practical_task_app/models/media_exception.dart';
import 'package:etech_practical_task_app/models/media_response.dart';
import 'package:etech_practical_task_app/models/media_video_model.dart';
import 'package:etech_practical_task_app/service/local_api_service.dart';
import 'package:etech_practical_task_app/service/remote_api_service.dart';
import 'package:sqflite/sqflite.dart';

class GetMediaRepository {
  final RemoteApiService _remoteApiService = RemoteApiService();
  final LocalAPIService _localAPIService = LocalAPIService();

  Future<List<MediaVideoModel>> fetchMedias() async {
    try {
      await _localAPIService.initDB();
      final json = await _remoteApiService.fetchMedias();
      final mediaResponse = MediaResponse.fromJson(json);
      final medias = mediaResponse.categories.firstOrNull?.videos ?? [];
      for (int index = 0; index < medias.length; index++) {
        int fileSize = await _remoteApiService.fetchFileSize(medias[index].sources.first);
        medias[index] = medias[index].copyWith(fileSize: fileSize);
        final tempMedia = await _localAPIService.isMediaExists(medias[index].id);
        if (tempMedia == null) {
          await _localAPIService.insertMedia(medias[index]);
        } else {
          print(tempMedia.toLocalJson());
          medias[index] = medias[index].copyWith(
            taskId: tempMedia.taskId,
            downloadTaskStatus: tempMedia.downloadTaskStatus,
            progress: tempMedia.progress,
            sourceFilePath: tempMedia.sourceFilePath,
          );
        }
      }
      return medias;
    } on DatabaseException catch (err) {
      print('Database Exception');
      print(err);
      print(err.runtimeType);
      throw MediaException('Couldn\'t find the medias');
    } on FormatException catch (err) {
      print('Format Exception');
      print(err);
      print(err.runtimeType);
      throw MediaException('Bad response format');
    } on DioException catch (err) {
      print('Dio Exception');
      print(err.runtimeType);
      print(err);
      throw MediaException('Couldn\'t find the medias');
    } catch (err) {
      print('Exception');
      print(err.runtimeType);
      print(err);
      throw MediaException('Unexpected Error !');
    }
  }

  Future<List<MediaVideoModel>> fetchLocalMedias() async {
    try {
      await _localAPIService.initDB();
      final mediaList = await _localAPIService.getAllMedias();
      return mediaList;
    } on DatabaseException catch (err) {
      print('Database Exception');
      print(err);
      print(err.runtimeType);
      throw MediaException('Couldn\'t find the medias');
    } on FormatException catch (err) {
      print('Format Exception');
      print(err);
      print(err.runtimeType);
      throw MediaException('Bad response format');
    } catch (err) {
      print('Exception');
      print(err.runtimeType);
      print(err);
      throw MediaException('Unexpected Error !');
    }
  }

  Future<MediaVideoModel?> fetchVideoByTaskId({required String taskId}) async {
    try {
      final data = await _localAPIService.fetchVideoByTaskId(taskId);
      return data;
    } catch (err) {
      print('Exception');
      print(err.runtimeType);
      print(err);
      throw MediaException('Downloading Video Failed !');
    }
  }

  Future<MediaVideoModel?> fetchVideoById({required int videoId}) async {
    try {
      final data = await _localAPIService.isMediaExists(videoId);
      return data;
    } catch (err) {
      print('Exception');
      print(err.runtimeType);
      print(err);
      throw MediaException('Downloading Video Failed !');
    }
  }

  Future<void> downloadVideo({
    required int videoId,
    required String taskId,
    required String filePath,
  }) async {
    try {
      await _localAPIService.updateMediaDownloadStart(
        videoId,
        taskId,
        filePath,
      );
    } catch (err) {
      print('Exception');
      print(err.runtimeType);
      print(err);
      throw MediaException('Downloading Video Failed !');
    }
  }

  Future<void> updateDownloadProgress({
    required String taskId,
    required int downloadTaskStatus,
    required int progress,
  }) async {
    try {
      await _localAPIService.updateMediaDownloadProgress(
        taskId,
        downloadTaskStatus,
        progress,
      );
    } catch (err) {
      print('Exception');
      print(err.runtimeType);
      print(err);
      throw MediaException('Unexpected Error !');
    }
  }

  Future<void> resumeDownloadProgress({
    required int videoId,
    required String newTaskId,
    required int downloadTaskStatus,
    required int progress,
  }) async {
    try {
      await _localAPIService.resumeMediaDownloadProgress(
        videoId,
        newTaskId,
        downloadTaskStatus,
        progress,
      );
    } catch (err) {
      print('Exception');
      print(err.runtimeType);
      print(err);
      throw MediaException('Unexpected Error !');
    }
  }
}
