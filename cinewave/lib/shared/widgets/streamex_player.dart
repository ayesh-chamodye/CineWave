import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cinewave/shared/utils/link_extractor.dart';
import 'package:cinewave/shared/utils/video_cache.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/library/presentation/bloc/library_bloc.dart';
import 'package:cinewave/features/library/presentation/bloc/library_event.dart';
import 'package:cinewave/core/models/library_models.dart';

class StreamexPlayer extends StatefulWidget {
  final String tmdbId;
  final bool isTv;
  final int? season;
  final int? episode;
  final String? title;
  final String? posterUrl;
  final VoidCallback? onBack;

  const StreamexPlayer({
    super.key,
    required this.tmdbId,
    this.isTv = false,
    this.season,
    this.episode,
    this.title,
    this.posterUrl,
    this.onBack,
  });

  @override
  State<StreamexPlayer> createState() => _StreamexPlayerState();
}

class _StreamexPlayerState extends State<StreamexPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  Timer? _historyTimer;

  bool _isExtracting = true;
  String _errorMessage = '';

  final VideoCacheManager _videoCacheManager = VideoCacheManager();

  static const String _xpassBaseUrl = 'https://play.xpass.top';

  String get _embedUrl {
    if (widget.isTv) {
      return '$_xpassBaseUrl/e/tv/${widget.tmdbId}/${widget.season ?? 1}/${widget.episode ?? 1}';
    }
    return '$_xpassBaseUrl/e/movie/${widget.tmdbId}';
  }

  @override
  void initState() {
    super.initState();
    _startExtraction();
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    _saveProgress();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _saveProgress() {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) return;

    final position = _videoPlayerController!.value.position.inMilliseconds;
    final duration = _videoPlayerController!.value.duration.inMilliseconds;

    if (position <= 0) return;

    final historyItem = WatchHistoryItem(
      id: widget.isTv
          ? 'tv_${widget.tmdbId}_${widget.season}_${widget.episode}'
          : 'movie_${widget.tmdbId}',
      mediaId: widget.tmdbId,
      title: widget.title ?? 'Unknown',
      posterUrl: widget.posterUrl,
      type: widget.isTv ? 'tv' : 'movie',
      season: widget.season,
      episode: widget.episode,
      position: position,
      duration: duration,
      lastWatched: DateTime.now(),
    );

    context.read<LibraryBloc>().add(AddToHistory(historyItem));
  }

  // ---------------------------------------------------------------------------
  // Extraction
  // ---------------------------------------------------------------------------

  Future<void> _startExtraction() async {
    try {
      final result = await LinkExtractor.extractWithHeaders(_embedUrl).timeout(
        const Duration(minutes: 5),
        onTimeout: () => null,
      );

      if (!mounted) return;

      if (result == null || result.url.isEmpty) {
        setState(() {
          _isExtracting = false;
          _errorMessage = 'No playable stream found. The title may not be available right now.';
        });
        return;
      }

      await _initializeNativePlayer(result.url, result.headers);
    } catch (e) {
      debugPrint('❌ Extraction error: $e');
      if (mounted) {
        setState(() {
          _isExtracting = false;
          _errorMessage = 'Failed to load stream: $e';
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Player init
  // ---------------------------------------------------------------------------

  Future<void> _initializeNativePlayer(String url, Map<String, String> headers) async {
    debugPrint('▶️ Initializing player: $url');

    // Check if this is an HLS manifest and try to use cached version
    final String manifestSource = await _getPotentiallyCachedManifest(url, headers);
    final bool isLocalManifest = !manifestSource.startsWith('http');

    try {
      if (isLocalManifest) {
        // Handle local manifest file
        debugPrint('📱 Initializing player with local manifest: $manifestSource');
        _videoPlayerController = VideoPlayerController.file(File(manifestSource));
      } else {
        // Handle network manifest URL
        debugPrint('🌐 Initializing player with network manifest: $manifestSource');
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(manifestSource),
          httpHeaders: headers,
          formatHint: VideoFormat.hls,
        );
      }

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        fullScreenByDefault: true,
        showControls: true,
        placeholder: Container(color: Colors.black),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blueAccent,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
        ),
        additionalOptions: (context) {
          return [
            OptionItem(
              onTap: () {
                _videoPlayerController!.setPlaybackSpeed(1.0);
                Navigator.pop(context);
              },
              iconData: Icons.speed,
              title: 'Normal Speed',
            ),
            OptionItem(
              onTap: () {
                _videoPlayerController!.setPlaybackSpeed(1.5);
                Navigator.pop(context);
              },
              iconData: Icons.speed,
              title: '1.5x Speed',
            ),
            OptionItem(
              onTap: () {
                _videoPlayerController!.setPlaybackSpeed(2.0);
                Navigator.pop(context);
              },
              iconData: Icons.speed,
              title: '2.0x Speed',
            ),
          ];
        },
      );

      if (mounted) {
        setState(() {
          _isExtracting = false;
        });
        _historyTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
          _saveProgress();
        });
      }
    } catch (e) {
      debugPrint('❌ Player init error: $e');
      if (mounted) {
        setState(() {
          _isExtracting = false;
          _errorMessage = 'Failed to initialize video player: $e';
        });
      }
    }
  }

  /// Returns a cached manifest file path if available, otherwise returns the original URL
  Future<String> _getPotentiallyCachedManifest(String url, Map<String, String> headers) async {
    // Only attempt caching for HLS manifests
    if (!url.toLowerCase().endsWith('.m3u8')) {
      return url;
    }

    try {
      // Check if we have a cached manifest
      if (await _videoCacheManager.isCached(url)) {
        debugPrint('📦 Using cached HLS manifest: $url');
        final File cachedFile = await _videoCacheManager.getFile(url, headers: headers);
        return cachedFile.path;
      } else {
        // Download and cache the manifest
        debugPrint('💾 Downloading and caching HLS manifest: $url');
        final File cachedFile = await _videoCacheManager.getFile(url, headers: headers);
        return cachedFile.path;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to use cache for manifest, falling back to network: $e');
      return url; // Fallback to original network URL
    }
  }

  // ---------------------------------------------------------------------------
  // Back navigation
  // ---------------------------------------------------------------------------

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).pop();
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 📺 Native player
          if (_chewieController != null)
            GestureDetector(
              onDoubleTapDown: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < screenWidth / 2) {
                  // Rewind 10s
                  final newPos = _videoPlayerController!.value.position - const Duration(seconds: 10);
                  _videoPlayerController!.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
                } else {
                  // Forward 10s
                  final newPos = _videoPlayerController!.value.position + const Duration(seconds: 10);
                  _videoPlayerController!.seekTo(newPos);
                }
              },
              child: Container(
                color: Colors.black,
                child: Chewie(controller: _chewieController!),
              ),
            ),

          // ⏳ Extracting / loading overlay
          if (_isExtracting) _buildLoadingOverlay(),

          // ❌ Error overlay
          if (!_isExtracting && _errorMessage.isNotEmpty)
            _buildErrorOverlay(),

          // 🔙 Back button (always visible)
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.blueAccent),
            const SizedBox(height: 24),
            Text(
              'Loading ${widget.title ?? "your media"}...',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Finding best available stream',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isExtracting = true;
                    _errorMessage = '';
                  });
                  _startExtraction();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _handleBack,
                child: const Text('Go Back', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 40,
      left: 16,
      child: Material(
        color: Colors.black45,
        shape: const CircleBorder(),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _handleBack,
        ),
      ),
    );
  }
}