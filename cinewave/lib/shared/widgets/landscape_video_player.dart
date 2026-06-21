import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cinewave/shared/widgets/streamex_player.dart';
import 'package:video_player/video_player.dart';

/// Full-screen **landscape** video-player page, immmersive with auto-orientation lock.
class LandscapeVideoPlayerPage extends StatefulWidget {
  final String? title;
  final bool isTv;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? tmdbId;
  final String? videoUrl;
  final String? posterUrl;
  final bool isLocal;

  const LandscapeVideoPlayerPage({
    super.key,
    this.title,
    this.isTv = false,
    this.seasonNumber,
    this.episodeNumber,
    this.tmdbId,
    this.videoUrl,
    this.posterUrl,
    this.isLocal = false,
  });

  @override
  State<LandscapeVideoPlayerPage> createState() =>
      _LandscapeVideoPlayerPageState();
}

class _LandscapeVideoPlayerPageState extends State<LandscapeVideoPlayerPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.isLocal && widget.videoUrl != null) {
      _initializeLocalPlayer();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
          overlays: SystemUiOverlay.values,
        );
      }
    });
  }

  Future<void> _initializeLocalPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.videoUrl!));
    await _videoPlayerController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLocal) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.tmdbId == null || widget.tmdbId!.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Invalid Content ID",
                  style: TextStyle(color: Colors.white)),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Go Back"))
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: StreamexPlayer(
          tmdbId: widget.tmdbId!,
          isTv: widget.isTv,
          season: widget.seasonNumber,
          episode: widget.episodeNumber,
          title: widget.title,
          posterUrl: widget.posterUrl,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}


