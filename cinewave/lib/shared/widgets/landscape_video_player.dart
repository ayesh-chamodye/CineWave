import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cinewave/core/constants/app_constants.dart';
import 'package:cinewave/shared/widgets/iframe_video_player.dart';
import 'package:cinewave/shared/widgets/server_picker_dialog.dart';

typedef void PlayNextCallback(String nextVideoUrl, String? title);

/// Full-screen **landscape** video-player page with built-in server switching.
///
/// Features
///  ─────────
///  * Locks device to landscape only while visible
///  * Hides status bar and navigation bar (immersive) — restored on dispose
///  * **Server badge** (top-right) — tap to open a radio-list dialog and
///    switch between Silk / 111 Movies / PrimeSrc instantly
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
  late String _currentEmbedUrl;
  late AppServer _selectedServer;

  @override
  void initState() {
    super.initState();
    _currentEmbedUrl = widget.videoUrl;
    _selectedServer = _detectServer(widget.videoUrl);
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

  AppServer _detectServer(String url) {
    try {
      return AppServer.byHost(Uri.parse(url).host) ?? AppServer.defaultServer;
    } catch (_) {
      return AppServer.defaultServer;
    }
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

  /// Opens the server-picker dialog.  When a new server is chosen the embed
  /// URL host is swapped and the WebView reloads.
  Future<void> _openServerPicker() async {
    if (!mounted) return;
    final chosen = await showModalBottomSheet<AppServer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServerPickerDialog(currentEmbedUrl: _currentEmbedUrl),
    );
    if (chosen == null || chosen.host == _selectedServer.host) return;

    final newUrl = chosen.rebuild(_currentEmbedUrl);
    setState(() {
      _selectedServer = chosen;
      _currentEmbedUrl = newUrl;
    });
    AppConstants.selectedServer = chosen;
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
              embedUrl: _currentEmbedUrl,
              fillRemainingSpace: true,
              onEndOfVideo: widget.onPlayNext != null
                  ? () => _advanceToNext(widget.onPlayNext!)
                  : null,
            ),
          ),
          // ── Server badge (top-right) ─────────────────────────────────────
          Positioned(
            top: 8,
            right: 12,
            child: Material(
              color: _selectedServer.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: _openServerPicker,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedServer.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.swap_horiz,
                          color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
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
