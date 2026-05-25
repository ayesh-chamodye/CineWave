import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class StreamexPlayer extends StatefulWidget {
  final String tmdbId;
  final bool isTv;
  final int? season;
  final int? episode;
  final String? title;
  final VoidCallback? onBack;

  const StreamexPlayer({
    super.key,
    required this.tmdbId,
    this.isTv = false,
    this.season,
    this.episode,
    this.title,
    this.onBack,
  });

  @override
  State<StreamexPlayer> createState() => _StreamexPlayerState();
}

class _StreamexPlayerState extends State<StreamexPlayer> {
  InAppWebViewController? _webViewController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  String? _extractedUrl;
  final List<String> _extractedSubtitles = [];
  bool _isExtracting = true;
  String _errorMessage = '';
  
  final String _xpassBaseUrl = 'https://play.xpass.top';
  final String _userAgent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15';

  String get _embedUrl {
    if (widget.isTv) {
      return '$_xpassBaseUrl/e/tv/${widget.tmdbId}/${widget.season ?? 1}/${widget.episode ?? 1}';
    } else {
      return '$_xpassBaseUrl/e/movie/${widget.tmdbId}';
    }
  }

  @override
  void initState() {
    super.initState();
    // Timeout for extraction
    Future.delayed(const Duration(seconds: 25), () {
      if (mounted && _extractedUrl == null && _errorMessage.isEmpty) {
        setState(() {
          _isExtracting = false;
          _errorMessage = 'Loading timed out. Service might be unavailable.';
        });
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializeNativePlayer(String url) async {
    if (_videoPlayerController != null) return;

    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: {
        'Referer': _embedUrl,
        'Origin': _xpassBaseUrl,
        'User-Agent': _userAgent,
      },
    );

    try {
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        fullScreenByDefault: true,
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
              onTap: (ctx) => _showSubtitlePicker(ctx),
              iconData: Icons.subtitles,
              title: 'Subtitles',
            ),
          ];
        },
      );

      if (mounted) {
        setState(() {
          _isExtracting = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Native Player Init Error: $e');
      if (mounted) {
        setState(() {
          _isExtracting = false;
          _errorMessage = 'Failed to load video stream: $e';
        });
      }
    }
  }

  void _showSubtitlePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Subtitle',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_extractedSubtitles.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No external subtitles found.', style: TextStyle(color: Colors.white54)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _extractedSubtitles.length,
                    itemBuilder: (context, index) {
                      final subUrl = _extractedSubtitles[index];
                      final name = subUrl.split('/').last.split('?').first;
                      return ListTile(
                        leading: const Icon(Icons.subtitles, color: Colors.white70),
                        title: Text(name, style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          // Note: Changing subtitles at runtime in Chewie/VideoPlayer 
                          // usually requires re-initializing or using a specific Subtitle provider.
                          // For now, we'll just log and pop.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🕸️ Hidden WebView for extraction
          if (_extractedUrl == null)
            Opacity(
              opacity: 0.01,
              child: SizedBox(
                width: 1,
                height: 1,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(_embedUrl),
                    headers: {
                      'User-Agent': _userAgent,
                      'Referer': 'https://streamex.sh/',
                    },
                  ),
                  initialSettings: InAppWebViewSettings(
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                    javaScriptEnabled: true,
                    userAgent: _userAgent,
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onLoadResource: (controller, resource) {
                    final url = resource.url.toString();
                    
                    // Intercept subtitle links
                    if (url.contains('.vtt') || url.contains('.srt')) {
                      if (!_extractedSubtitles.contains(url)) {
                        debugPrint('📝 Subtitle Extracted: $url');
                        _extractedSubtitles.add(url);
                      }
                    }

                    // Intercept m3u8 playlist links
                    if (url.contains('.m3u8') && 
                        !url.contains('blob:') && 
                        !url.contains('subtitle')) {
                      debugPrint('🎯 StreameX Extracted: $url');
                      if (mounted && _extractedUrl == null) {
                        setState(() {
                          _extractedUrl = url;
                        });
                        _initializeNativePlayer(url);
                      }
                    }
                  },
                ),
              ),
            ),

          // 📺 Native Player UI
          if (_chewieController != null)
            Container(
              color: Colors.black,
              child: Chewie(controller: _chewieController!),
            ),

          // ⌛ Loading Overlay
          if (_isExtracting)
            Container(
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
                  ],
                ),
              ),
            )
          else if (_errorMessage.isNotEmpty)
            Container(
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
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.onBack != null) {
                             widget.onBack!();
                          } else {
                             Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 🔙 Back Button
          Positioned(
            top: 40,
            left: 16,
            child: Material(
              color: Colors.black45,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                   if (widget.onBack != null) {
                     widget.onBack!();
                   } else {
                     Navigator.of(context).pop();
                   }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
