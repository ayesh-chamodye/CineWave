import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

const String _kPlayerRootUrl = 'https://player.videasy.net/';
const String _kUserAgent =
    "Mozilla/5.0 (Linux; Android 13; SM-S911B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36";

class IframeVideoPlayer extends StatefulWidget {
  final String embedUrl;
  final VoidCallback? onBack;
  final bool fillRemainingSpace;
  final VoidCallback? onEndOfVideo;
  final String? title;

  const IframeVideoPlayer({
    super.key,
    required this.embedUrl,
    this.onBack,
    this.fillRemainingSpace = true,
    this.onEndOfVideo,
    this.title,
  });

  @override
  State<IframeVideoPlayer> createState() => _IframeVideoPlayerState();
}

class _IframeVideoPlayerState extends State<IframeVideoPlayer> {
  late final WebViewController _controller;

  bool _endedReported = false;
  String _loadedUrl = '';
  bool _controlsVisible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    _setupController();

    if (widget.embedUrl.isNotEmpty && widget.embedUrl != _kPlayerRootUrl) {
      _controller.loadRequest(
        Uri.parse(widget.embedUrl),
        headers: {'Referer': _kPlayerRootUrl},
      );
      _loadedUrl = widget.embedUrl;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onBack?.call();
      });
    }
  }

  void _setupController() {
    // 🎭 Set a standard mobile User-Agent to avoid being blocked as a bot
    _controller.setUserAgent(_kUserAgent);

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);

            if (uri.toString().endsWith(_kPlayerRootUrl)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onBack?.call();
              });
              return NavigationDecision.prevent;
            }

            final host = uri.host;

            final blocked = host.contains('googleads') ||
                host.contains('doubleclick') ||
                host.contains('facebook.com/tr') ||
                host.contains('adservice') ||
                host.contains('pagead') ||
                host.contains('googlesyndication');

            return blocked
                ? NavigationDecision.prevent
                : NavigationDecision.navigate;
          },
          onPageFinished: (_) => _injectEndWatcher(),
        ),
      )
      ..addJavaScriptChannel(
        'onVideoEnd',
        onMessageReceived: (msg) {
          if (_endedReported) return;
          if (msg.message == 'ENDED') {
            _endedReported = true;
            widget.onEndOfVideo?.call();
          }
        },
      );

    // 📱 Platform-specific media playback enhancements
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void _injectEndWatcher() {
    const script = '''
      (function () {
        function reportEnd() {
          if (window.__videoEndReported) return;
          window.__videoEndReported = true;
          if (window.onVideoEnd) {
            window.onVideoEnd.postMessage('ENDED');
          }
        }

        function attach() {
          document.querySelectorAll('video').forEach(function (v) {
            v.addEventListener('ended', reportEnd, true);
          });
        }

        attach();

        if (window.MutationObserver) {
          new MutationObserver(attach)
            .observe(document.documentElement, {
              childList: true,
              subtree: true
            });
        }
      })();
    ''';

    _controller.runJavaScript(script);
  }

  void _triggerBack() {
    widget.onBack?.call();
  }

  void _showControls() {
    setState(() => _controlsVisible = true);

    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant IframeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.embedUrl != _loadedUrl) {
      _loadedUrl = widget.embedUrl;
      _endedReported = false;
      _controller.loadRequest(
        Uri.parse(widget.embedUrl),
        headers: {'Referer': _kPlayerRootUrl},
      );
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          // 🌐 WebView
          WebViewWidget(
            controller: _controller,
            gestureRecognizers: {
              // This allows the WebView to handle touches, but also lets us
              // detect taps to show/hide our overlay controls.
              Factory<TapGestureRecognizer>(
                () => TapGestureRecognizer()..onTapDown = (_) => _showControls(),
              ),
            },
          ),

          // 🔝 Top bar FIXED at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _controlsVisible ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.black45,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: _triggerBack,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        if (widget.title != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
