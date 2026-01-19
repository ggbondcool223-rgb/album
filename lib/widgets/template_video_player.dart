import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TemplateVideoPlayer extends StatefulWidget {
  final String videoPath;
  final BoxFit fit;

  const TemplateVideoPlayer({
    super.key,
    required this.videoPath,
    this.fit = BoxFit.cover,
  });

  @override
  State<TemplateVideoPlayer> createState() => _TemplateVideoPlayerState();
}

class _TemplateVideoPlayerState extends State<TemplateVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoPath);
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return FittedBox(
      fit: widget.fit,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}

