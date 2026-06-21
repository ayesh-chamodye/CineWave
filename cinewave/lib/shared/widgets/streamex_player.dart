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
import 'package:http/http.dart' as http;

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
  bool _showNextEpisodeButton = false;
  MediaSubtitle? _selectedSubtitle;
  List<MediaSubtitle>? _availableSubtitles;

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

  void _showSubtitleMenu(List<MediaSubtitle> subs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Subtitles', 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: subs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: Icon(Icons.close, color: _selectedSubtitle == null ? Colors.blueAccent : Colors.white70),
                        title: Text('None', style: TextStyle(color: _selectedSubtitle == null ? Colors.blueAccent : Colors.white)),
                        trailing: _selectedSubtitle == null ? const Icon(Icons.check, color: Colors.blueAccent) : null,
                        onTap: () {
                          setState(() => _selectedSubtitle = null);
                          _chewieController?.setSubtitle([]);
                          Navigator.pop(context);
                        },
                      );
                    }
                    final sub = subs[index - 1];
                    final isSelected = _selectedSubtitle?.url == sub.url;
                    return ListTile(
                      leading: Icon(Icons.subtitles, color: isSelected ? Colors.blueAccent : Colors.white70),
                      title: Text(sub.label, style: TextStyle(color: isSelected ? Colors.blueAccent : Colors.white)),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.blueAccent) : null,
                      onTap: () {
                        _loadSubtitle(sub);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadSubtitle(MediaSubtitle sub) async {
    try {
      setState(() => _selectedSubtitle = sub);
      final response = await http.get(Uri.parse(sub.url));
      if (response.statusCode == 200) {
        final List<Subtitle> parsedSubs = _parseVtt(response.body);
        if (parsedSubs.isNotEmpty && _chewieController != null) {
          _chewieController!.setSubtitle(parsedSubs);
          debugPrint('✅ Subtitles loaded and set: ${sub.label}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading subtitle: $e');
    }
  }

  List<Subtitle> _parseVtt(String vttContent) {
    final List<Subtitle> subtitles = [];
    try {
      final lines = vttContent.split('\n');
      Duration? start;
      Duration? end;
      String text = '';

      final timeRegex = RegExp(r'(\d{2}:)?\d{2}:\d{2}\.\d{3}');

      for (var line in lines) {
        if (line.contains('-->')) {
          final parts = line.split('-->');
          if (parts.length == 2) {
            start = _parseVttTime(parts[0].trim());
            end = _parseVttTime(parts[1].trim());
          }
        } else if (line.trim().isEmpty) {
          if (start != null && end != null && text.isNotEmpty) {
            subtitles.add(Subtitle(
              index: subtitles.length,
              start: start,
              end: end,
              text: text.trim(),
            ));
            start = null;
            end = null;
            text = '';
          }
        } else if (!line.startsWith('WEBVTT') && !line.startsWith('NOTE')) {
          text += '$line\n';
        }
      }
      // Final one
      if (start != null && end != null && text.isNotEmpty) {
        subtitles.add(Subtitle(
          index: subtitles.length,
          start: start,
          end: end,
          text: text.trim(),
        ));
      }
    } catch (e) {
      debugPrint('❌ VTT Parse Error: $e');
    }
    return subtitles;
  }

  Duration _parseVttTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length == 3) {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final secondsParts = parts[2].split('.');
      final seconds = int.parse(secondsParts[0]);
      final milliseconds = int.parse(secondsParts[1]);
      return Duration(hours: hours, minutes: minutes, seconds: seconds, milliseconds: milliseconds);
    } else {
      final minutes = int.parse(parts[0]);
      final secondsParts = parts[1].split('.');
      final seconds = int.parse(secondsParts[0]);
      final milliseconds = int.parse(secondsParts[1]);
      return Duration(minutes: minutes, seconds: seconds, milliseconds: milliseconds);
    }
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

      await _initializeNativePlayer(result.url, result.headers, result.subtitles);
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

  Future<void> _initializeNativePlayer(
      String url, Map<String, String> headers, List<MediaSubtitle>? subtitles) async {
    debugPrint('▶️ Initializing player: $url');
    _availableSubtitles = subtitles;

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

      // Convert subtitles for Chewie
      final List<OptionItem> subtitleOptions = [];
      Subtitles? chewieSubtitles;

      if (subtitles != null && subtitles.isNotEmpty) {
        // Try to find English or just take the first one for auto-display
        final autoSub = subtitles.firstWhere(
          (s) => s.language.startsWith('en'),
          orElse: () => subtitles.first,
        );

        chewieSubtitles = Subtitles([
          // Note: Chewie's Subtitle class expects start/end/text, 
          // but we usually have a URL for VTT/SRT.
          // Chewie actually doesn't directly support VTT URLs in its 'subtitle' parameter.
          // It expects pre-parsed subtitles.
          // To support remote VTT, we might need 'chewie_vtt' or similar, 
          // or just provide them in 'additionalOptions'.
        ]);
        
        // Actually, many users use 'additionalOptions' to switch subtitle tracks by changing the 'subtitle' parameter dynamically.
        // For now, let's just add them to additional options so user can pick.
      }

      _videoPlayerController!.addListener(() {
        if (widget.isTv && _videoPlayerController!.value.isInitialized) {
          final position = _videoPlayerController!.value.position;
          final duration = _videoPlayerController!.value.duration;
          if (duration - position < const Duration(seconds: 45)) {
            if (!_showNextEpisodeButton) {
              setState(() => _showNextEpisodeButton = true);
            }
          } else {
            if (_showNextEpisodeButton) {
              setState(() => _showNextEpisodeButton = false);
            }
          }
        }
      });

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
          final List<OptionItem> options = [
            OptionItem(
              onTap: (ctx) {
                _videoPlayerController!.setPlaybackSpeed(1.0);
                Navigator.pop(ctx);
              },
              iconData: Icons.speed,
              title: 'Normal Speed',
            ),
            OptionItem(
              onTap: (ctx) {
                _videoPlayerController!.setPlaybackSpeed(1.5);
                Navigator.pop(ctx);
              },
              iconData: Icons.speed,
              title: '1.5x Speed',
            ),
            OptionItem(
              onTap: (ctx) {
                _videoPlayerController!.setPlaybackSpeed(2.0);
                Navigator.pop(ctx);
              },
              iconData: Icons.speed,
              title: '2.0x Speed',
            ),
          ];

          if (subtitles != null && subtitles.isNotEmpty) {
            options.add(OptionItem(
              onTap: (ctx) {
                Navigator.pop(ctx);
                _showSubtitleMenu(subtitles);
              },
              iconData: Icons.subtitles,
              title: 'Subtitles (${subtitles.length})',
            ));
          }

          return options;
        },
      );

      if (mounted) {
        setState(() {
          _isExtracting = false;
        });

        // Auto-display subtitles if available
        if (subtitles != null && subtitles.isNotEmpty) {
          final autoSub = subtitles.firstWhere(
            (s) => s.language.startsWith('en'),
            orElse: () => subtitles.first,
          );
          _loadSubtitle(autoSub);
        }

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

          // 💬 Subtitle selector button (top right)
          if (!_isExtracting && _availableSubtitles != null && _availableSubtitles!.isNotEmpty)
            _buildSubtitleButton(),

          // ⏭️ Next Episode Button
          if (_showNextEpisodeButton) _buildNextEpisodeButton(),
        ],
      ),
    );
  }

  Widget _buildSubtitleButton() {
    return Positioned(
      top: 40,
      right: 16,
      child: Material(
        color: Colors.black45,
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(
            _selectedSubtitle != null ? Icons.subtitles : Icons.subtitles_off,
            color: _selectedSubtitle != null ? Colors.blueAccent : Colors.white,
          ),
          tooltip: 'Select Subtitles',
          onPressed: () => _showSubtitleMenu(_availableSubtitles!),
        ),
      ),
    );
  }

  Widget _buildNextEpisodeButton() {
    return Positioned(
      bottom: 100,
      right: 32,
      child: ElevatedButton.icon(
        onPressed: () {
          final nextEpisode = (widget.episode ?? 1) + 1;
          Navigator.of(context).pushReplacementNamed(
            '/video-player',
            arguments: {
              'tmdbId': widget.tmdbId,
              'title': widget.title,
              'type': 'tv',
              'isTv': true,
              'seasonNumber': widget.season,
              'episodeNumber': nextEpisode,
              'posterUrl': widget.posterUrl,
            },
          );
        },
        icon: const Icon(Icons.skip_next, color: Colors.white),
        label: const Text('Next Episode', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent.withValues(alpha: 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
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