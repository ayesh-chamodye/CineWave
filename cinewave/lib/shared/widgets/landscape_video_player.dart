import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cinewave/shared/widgets/iframe_video_player.dart';

typedef PlayNextCallback = void Function(String nextVideoUrl, String? title);

/// Full-screen **landscape** video-player page, immmersive with auto-orientation lock.
class LandscapeVideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final bool isTv;
  final int? seasonNumber;
  final int? episodeNumber;
  final PlayNextCallback? onPlayNext;

  const LandscapeVideoPlayerPage({
    super.key,
    required this.videoUrl,
    this.title,
    this.isTv = false,
    this.seasonNumber,
    this.episodeNumber,
    this.onPlayNext,
  });

  @override
  State<LandscapeVideoPlayerPage> createState() =>
      _LandscapeVideoPlayerPageState();
}

class _LandscapeVideoPlayerPageState extends State<LandscapeVideoPlayerPage> {
  @override
  void initState() {
    super.initState();
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
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            top: true,
            bottom: true,
            left: true,
            right: true,
            child: IframeVideoPlayer(
              embedUrl: widget.videoUrl,
              title: widget.title,
              fillRemainingSpace: true,
              onBack: () => Navigator.of(context).pop(),
              onEndOfVideo: widget.onPlayNext != null
                  ? () => _advanceToNext(widget.onPlayNext!)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Auto-play next episode helper ──────────────────────────────────────────

  void _advanceToNext(PlayNextCallback callback) {
    final nextEp = ((widget.episodeNumber ?? 1) + 1);
    final nextSeason = widget.seasonNumber ?? 1;
    final idPart = _extractShowId(widget.videoUrl);

    String nextUrl;
    if (idPart != null && widget.isTv) {
      nextUrl = 'https://player.videasy.net/tv/$idPart/$nextSeason/$nextEp';
    } else {
      nextUrl = widget.videoUrl;
    }

    callback(nextUrl, widget.title);
  }

  String? _extractShowId(String url) {
    try {
      final segs = Uri.parse(url).pathSegments;
      if (segs.length >= 2 && segs[0] == 'tv') return segs[1];
      return null;
    } catch (_) {
      return null;
    }
  }
}
