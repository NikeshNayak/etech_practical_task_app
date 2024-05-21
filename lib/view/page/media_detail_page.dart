import 'package:cached_network_image/cached_network_image.dart';
import 'package:etech_practical_task_app/bloc/get_media_bloc/get_media_bloc.dart';
import 'package:etech_practical_task_app/bloc/get_media_detail_bloc/get_media_detail_bloc.dart';
import 'package:etech_practical_task_app/models/media_video_model.dart';
import 'package:etech_practical_task_app/utils/constants.dart';
import 'package:etech_practical_task_app/view/widgets/shimmer_effect_widget.dart';
import 'package:etech_practical_task_app/view/widgets/video_player_widget.dart';
import 'package:etech_practical_task_app/view_model/get_media_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class MediaDetailPage extends StatefulWidget {
  final MediaVideoModel videoItem;

  const MediaDetailPage({
    super.key,
    required this.videoItem,
  });

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  bool _isInit = true;
  bool _isVideoPlay = false;
  GetMediaViewModel? _getMediaViewModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _getMediaViewModel = GetMediaViewModel(context.read<GetMediaBloc>(), context.read<GetMediaDetailBloc>());
      _getMediaViewModel?.videoItem = widget.videoItem;
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetMediaDetailBloc, GetMediaDetailState>(
      listener: (context, state) {
        if (state is GetMediaDetailSuccessState) {
          print('MEDTAIL SCREEN STATE LISTENER');
          _getMediaViewModel?.videoItem = state.mediaVideoModel;
          setState(() {});
        }
      },
      builder: (context, state) {
        final remainingFileSize = getFileSizeString(bytes: _getMediaViewModel!.videoItem!.fileSize - (((_getMediaViewModel!.videoItem!.progress / 100) * _getMediaViewModel!.videoItem!.fileSize).toInt()));
        return Scaffold(
          appBar: AppBar(
            title: Text(_getMediaViewModel!.videoItem!.title),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: !_isVideoPlay
                          ? Hero(
                              tag: _getMediaViewModel!.videoItem!.id,
                              child: CachedNetworkImage(
                                cacheKey: '${_getMediaViewModel!.videoItem!.id}',
                                imageUrl: '$thumbnailBaseUrl${_getMediaViewModel!.videoItem!.thumb}',
                                fit: BoxFit.cover,
                                height: 300,
                                width: double.infinity,
                                placeholder: (context, url) {
                                  return const ShimmerView();
                                },
                                errorWidget: (context, url, error) {
                                  return const SizedBox(
                                    height: 300,
                                    width: double.infinity,
                                    child: Center(
                                      child: Text('Image not found'),
                                    ),
                                  );
                                },
                              ),
                            )
                          : VideoPlayerWidget(
                              key: ValueKey(_getMediaViewModel!.videoItem!.id),
                              url: _getMediaViewModel!.videoItem!.downloadTaskStatus == DownloadTaskStatus.complete
                                  ? _getMediaViewModel!.videoItem!.sourceFilePath!
                                  : _getMediaViewModel!.videoItem!.sources.first,
                              thumb: '$thumbnailBaseUrl${_getMediaViewModel!.videoItem!.thumb}',
                              onPause: () {
                                setState(() {
                                  _isVideoPlay = false;
                                });
                              },
                            ),
                    ),
                    if (!_isVideoPlay &&
                        (_getMediaViewModel!.videoItem!.downloadTaskStatus == DownloadTaskStatus.undefined || _getMediaViewModel!.videoItem!.downloadTaskStatus == DownloadTaskStatus.complete))
                      Container(
                        color: Colors.black38,
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          child: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () {
                              setState(() {
                                _isVideoPlay = true;
                              });
                            },
                          ),
                        ),
                      ),
                    if (_getMediaViewModel!.videoItem!.downloadTaskStatus == DownloadTaskStatus.enqueued ||
                        _getMediaViewModel!.videoItem!.downloadTaskStatus == DownloadTaskStatus.running ||
                        _getMediaViewModel!.videoItem!.downloadTaskStatus == DownloadTaskStatus.paused)
                      Container(
                        color: Colors.black38,
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          child: Text(
                            remainingFileSize,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getMediaViewModel!.videoItem!.title,
                            style: TextStyle(
                              fontSize: 17,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        if (_getMediaViewModel!.videoItem!.downloadTaskStatus == DownloadTaskStatus.running)
                          InkWell(
                            onTap: !_isVideoPlay
                                ? () {
                                    _getMediaViewModel?.pauseDownload(
                                      _getMediaViewModel!.videoItem!.taskId!,
                                    );
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: !_isVideoPlay ? Theme.of(context).colorScheme.primary : Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 2.5,
                                    spreadRadius: 1.0,
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.pause_circle,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Pause',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (_getMediaViewModel!.videoItem!.downloadTaskStatus == DownloadTaskStatus.paused)
                          InkWell(
                            onTap: !_isVideoPlay
                                ? () async {
                                    final newTaskId = await _getMediaViewModel?.resumeDownload(
                                      context,
                                      _getMediaViewModel!.videoItem!.id,
                                      _getMediaViewModel!.videoItem!.taskId!,
                                      _getMediaViewModel!.videoItem!.downloadTaskStatus,
                                      _getMediaViewModel!.videoItem!.progress,
                                    );
                                    _getMediaViewModel!.videoItem!.taskId = newTaskId;
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: !_isVideoPlay ? Theme.of(context).colorScheme.primary : Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 2.5,
                                    spreadRadius: 1.0,
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.play_circle,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Resume',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (_getMediaViewModel!.videoItem!.downloadTaskStatus != DownloadTaskStatus.complete)
                          InkWell(
                            onTap: !_isVideoPlay
                                ? () {
                                    _getMediaViewModel?.downloadVideo(_getMediaViewModel!.videoItem!.id, _getMediaViewModel!.videoItem!.sources.first);
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: !_isVideoPlay ? Theme.of(context).colorScheme.primary : Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 2.5,
                                    spreadRadius: 1.0,
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.download,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    getFileSizeString(bytes: _getMediaViewModel!.videoItem!.fileSize),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _getMediaViewModel!.videoItem!.subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _getMediaViewModel!.videoItem!.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
