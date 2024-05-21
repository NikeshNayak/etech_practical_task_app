import 'package:cached_network_image/cached_network_image.dart';
import 'package:etech_practical_task_app/models/media_video_model.dart';
import 'package:etech_practical_task_app/utils/constants.dart';
import 'package:etech_practical_task_app/view/page/media_detail_page.dart';
import 'package:etech_practical_task_app/view/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'shimmer_effect_widget.dart';

class MediaItemWidget extends StatefulWidget {
  final MediaVideoModel videoItem;
  final void Function() onTap;
  final void Function() onDownload;
  final void Function() onDownloadResume;
  final void Function() onDownloadPause;

  const MediaItemWidget({
    super.key,
    required this.videoItem,
    required this.onTap,
    required this.onDownload,
    required this.onDownloadResume,
    required this.onDownloadPause,
  });

  @override
  State<MediaItemWidget> createState() => _MediaItemWidgetState();
}

class _MediaItemWidgetState extends State<MediaItemWidget> {
  bool _isVideoPlay = false;

  @override
  Widget build(BuildContext context) {
    final remainingFileSize = getFileSizeString(bytes: widget.videoItem.fileSize - (((widget.videoItem.progress / 100) * widget.videoItem.fileSize).toInt()));
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: !_isVideoPlay
                          ? Hero(
                              tag: widget.videoItem.id,
                              child: CachedNetworkImage(
                                cacheKey: '${widget.videoItem.id}',
                                imageUrl: '$thumbnailBaseUrl${widget.videoItem.thumb}',
                                fit: BoxFit.cover,
                                height: 200,
                                width: double.infinity,
                                placeholder: (context, url) {
                                  return const ShimmerView();
                                },
                                errorWidget: (context, url, error) {
                                  return const SizedBox(
                                    height: 200,
                                    width: double.infinity,
                                    child: Center(
                                      child: Text('Image not found'),
                                    ),
                                  );
                                },
                              ),
                            )
                          : VideoPlayerWidget(
                              key: ValueKey(widget.videoItem.id),
                              url: widget.videoItem.downloadTaskStatus == DownloadTaskStatus.complete ? widget.videoItem.sourceFilePath! : widget.videoItem.sources.first,
                              thumb: '$thumbnailBaseUrl${widget.videoItem.thumb}',
                              onPause: () {
                                setState(() {
                                  _isVideoPlay = false;
                                });
                              },
                            ),
                    ),
                    if (!_isVideoPlay && (widget.videoItem.downloadTaskStatus == DownloadTaskStatus.undefined || widget.videoItem.downloadTaskStatus == DownloadTaskStatus.complete))
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
                    if (widget.videoItem.downloadTaskStatus == DownloadTaskStatus.enqueued ||
                        widget.videoItem.downloadTaskStatus == DownloadTaskStatus.running ||
                        widget.videoItem.downloadTaskStatus == DownloadTaskStatus.paused)
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
                            widget.videoItem.title,
                            style: TextStyle(
                              fontSize: 17,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        if (widget.videoItem.downloadTaskStatus == DownloadTaskStatus.running)
                          InkWell(
                            onTap: !_isVideoPlay
                                ? () {
                                    widget.onDownloadPause();
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
                        else if (widget.videoItem.downloadTaskStatus == DownloadTaskStatus.paused)
                          InkWell(
                            onTap: !_isVideoPlay
                                ? () {
                                    widget.onDownloadResume();
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
                        else if (widget.videoItem.downloadTaskStatus != DownloadTaskStatus.complete)
                          InkWell(
                            onTap: !_isVideoPlay
                                ? () {
                                    widget.onDownload();
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
                                    getFileSizeString(bytes: widget.videoItem.fileSize),
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
                    Text(
                      widget.videoItem.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.videoItem.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                        letterSpacing: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 15)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
