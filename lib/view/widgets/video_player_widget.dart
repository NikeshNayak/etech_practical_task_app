import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../main.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    required this.url,
    required this.thumb,
    this.aspectRatio = 1,
    this.canPlay = true,
    super.key,
    required this.onPause,
  });

  /// Link of the video
  final String url;

  final String thumb;

  /// The Aspect Ratio of the Video. Important to get the correct size of the video
  final double aspectRatio;

  /// If the video can be played
  final bool canPlay;

  final Function() onPause;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> with WidgetsBindingObserver, RouteAware {
  bool _isInit = true;
  bool isPlay = false;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.url.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized,
          // even before the play button has been pressed.
          if (widget.canPlay) {
            isPlay = true;
            _controller.play();
          }
          setState(() {});
        });
    } else if (widget.url.startsWith('assets')) {
      _controller = VideoPlayerController.asset(widget.url)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized,
          // even before the play button has been pressed.
          if (widget.canPlay) {
            isPlay = true;
            _controller.play();
          }
          setState(() {});
        });
    } else {
      _controller = VideoPlayerController.file(File(widget.url))
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized,
          // even before the play button has been pressed.
          if (widget.canPlay) {
            isPlay = true;
            _controller.play();
          }
          setState(() {});
        });
    }
    _controller.setLooping(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didPushNext() {
    print('didPushNext Route');
    if (_controller.value.isPlaying) {
      _controller.pause();
      widget.onPause();
    }
    super.didPushNext();
  }

  @override
  void didPop() {
    print('didPop Route');
    if (_controller.value.isPlaying) {
      _controller.pause();
      widget.onPause();
    }
    super.didPopNext();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        print('AppLifecycleState.detached');
        break;
      case AppLifecycleState.resumed:
        print('AppLifecycleState.resumed');
        break;
      case AppLifecycleState.inactive:
        print('AppLifecycleState.inactive');
        break;
      case AppLifecycleState.hidden:
        print('AppLifecycleState.hidden');
        break;
      case AppLifecycleState.paused:
        print('AppLifecycleState.paused');
        if (_controller.value.isPlaying) {
          _controller.pause();
          widget.onPause();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? ColoredBox(
            color: Colors.black,
            child: Stack(
              alignment: _controller.value.isPlaying ? AlignmentDirectional.center : AlignmentDirectional.center,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
                      });
                      if (!_controller.value.isPlaying) {
                        widget.onPause();
                      }
                    },
                    child: Container(
                      decoration: !_controller.value.isPlaying
                          ? const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            )
                          : null,
                      padding: const EdgeInsets.all(3),
                      child: Icon(
                        _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
