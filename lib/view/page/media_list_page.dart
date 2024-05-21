import 'dart:isolate';
import 'dart:ui';

import 'package:etech_practical_task_app/bloc/get_media_bloc/get_media_bloc.dart';
import 'package:etech_practical_task_app/bloc/get_media_detail_bloc/get_media_detail_bloc.dart';
import 'package:etech_practical_task_app/view/page/media_detail_page.dart';
import 'package:etech_practical_task_app/view/widgets/media_item_widget.dart';
import 'package:etech_practical_task_app/view_model/get_media_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class MediaListPage extends StatefulWidget {
  const MediaListPage({super.key});

  @override
  State<MediaListPage> createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {
  bool _isInit = true;

  GetMediaViewModel? _getMediaViewModel;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((data) {
      String taskId = data[0];
      final status = DownloadTaskStatus.fromInt(data[1] as int);
      int progress = data[2];
      print('_port.listen called : task ($taskId) is in status ($status) and process ($progress)');
      _getMediaViewModel?.updateDownloadProgress(taskId, status, progress);
      BlocProvider.of<GetMediaDetailBloc>(context).add(UpdateDownloadProgressMediaDetailEvent(
        taskId: taskId,
        downloadTaskStatus: status.index,
        progress: progress,
      ));
      setState(() {});
    });
    FlutterDownloader.registerCallback(downloadCallback, step: 1);
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port.close();
    FlutterDownloader.cancelAll();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    print(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );

    IsolateNameServer.lookupPortByName('downloader_send_port')?.send([id, status, progress]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _getMediaViewModel = GetMediaViewModel(context.read<GetMediaBloc>());
      _getMediaViewModel?.fetchMedias();
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Media List'),
          ),
          body: BlocConsumer<GetMediaBloc, GetMediaState>(
            listener: _getMediaViewModel!.mediasBlocListener,
            builder: (context, state) {
              return state is GetMediaLoadingState
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _getMediaViewModel!.mediaVideosList.isNotEmpty
                      ? ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          itemBuilder: (context, index) {
                            final videoItem = _getMediaViewModel!.mediaVideosList[index];
                            return MediaItemWidget(
                              key: ValueKey(videoItem.id),
                              videoItem: videoItem,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MediaDetailPage(
                                        videoItem: videoItem,
                                      );
                                    },
                                  ),
                                ).then((value) {
                                  _getMediaViewModel?.fetchMedias();
                                });
                              },
                              onDownload: () {
                                _getMediaViewModel?.downloadVideo(
                                  videoItem.id,
                                  videoItem.sources.first,
                                );
                              },
                              onDownloadResume: () {
                                _getMediaViewModel?.resumeDownload(
                                  context,
                                  videoItem.id,
                                  videoItem.taskId!,
                                  videoItem.downloadTaskStatus,
                                  videoItem.progress,
                                );
                              },
                              onDownloadPause: () {
                                _getMediaViewModel?.pauseDownload(videoItem.taskId!);
                              },
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemCount: _getMediaViewModel!.mediaVideosList.length,
                        )
                      : const Center(
                          child: Text('No Medias found'),
                        );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _unbindBackgroundIsolate();
    _getMediaViewModel?.dispose();
  }
}
