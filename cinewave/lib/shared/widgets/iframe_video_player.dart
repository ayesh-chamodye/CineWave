import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String _kPlayerRootUrl = 'https://player.videasy.net/';

/// Embedded video player built on `webview_flutter`.
///
/// The Videasy embed pages (`https://player.videasy.net/movie/{id}` and
/// `//tv/{id}/{s}/{e}`) are themselves web-based players that turn API IDs
/// into byte-stream video URLs.  They must be rendered inside a real browser
/// engine — the native `video_player` plugin cannot handle them directly.
///
/// ---
/// Why WebView not native video_player
/// The embed page is a JavaScript-heavy HTML document that calls many
/// internal byte-stream endpoints and negotiates HLS/DASH/MP4/etc.  The
/// native player cannot materialise those URLs without the page's negotiation
/// logic, so we render the whole embed page inside a WebView and let its own
/// JavaScript pipeline drive playback.
class IframeVideoPlayer extends StatefulWidget {
  /// Full embed URL from the backend `playerUrl` field, e.g.
  /// `https://player.videasy.net/movie/350` or
  /// `https://player.videasy.net/tv/1399/1/1`.
  ///
  /// If the URL is ever the bare root `https://player.videasy.net/`, this
  /// widget treats it as an "empty embed" and pops [onBack] immediately.
  final String embedUrl;

  /// Called when the user taps the top-left back button **or** when the page
  /// navigates to the bare root player URL.
  final VoidCallback? onBack;

  /// When `true` (default) the WebView is wrapped in `Expanded` so it fills
  /// all remaining vertical space inside its parent `Column`.
  /// Set to `false` when the parent controls sizing explicitly.
  final bool fillRemainingSpace;

  /// Called when the video fires its `ended` event via the JS→Dart bridge.
  final VoidCallback? onEndOfVideo;

  const IframeVideoPlayer({
    super.key,
    required this.embedUrl,
    this.onBack,
    this.fillRemainingSpace = true,
    this.onEndOfVideo,
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
    _controller = WebViewController();
    _triggerBack(); // fire on mount for bare-root URLs
    _setupController();
    if (widget.embedUrl != _kPlayerRootUrl) {
      _controller.loadRequest(Uri.parse(widget.embedUrl));
      _loadedUrl = widget.embedUrl;
    }
  }

  void _setupController() {
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // If the page redirected to the bare player root, treat it as
            // "no valid embed URL" and go back.
            final cleaned = request.url.endsWith('/')
                ? request.url
                : '${request.url}/';
            if (cleaned == _kPlayerRootUrl) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _triggerBack());
              return NavigationDecision.navigate;
            }

            // Block pop-up / new-tab navigations (ad popups, etc.)
            if (!request.isMainFrame) return NavigationDecision.prevent;

            // Block known ad / tracker domains (player redirects and video CDNs never use these hosts)
            final host = Uri.tryParse(request.url)?.host ?? '';
            return host.contains('googleads') ||
                    host.contains('doubleclick') ||
                    host.contains('facebook.com/tr') ||
                    host.contains('adservice') ||
                    host.contains('pagead') ||
                    host.contains('doubleverify') ||
                    host.contains('googlesyndication') ||
                    host.contains('pubads.g.doubleclick')
                ? NavigationDecision.prevent
                : NavigationDecision.navigate;
          },
          onPageFinished: (_) => _injectEndWatcher(),
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? false) return;
          },
        ),
      )
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
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
  }

  void _triggerBack() {
    if (widget.onBack != null) widget.onBack!();
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  @override
  void didUpdateWidget(covariant IframeVideoPlayer old) {
    super.didUpdateWidget(old);
    if (widget.embedUrl != _loadedUrl) {
      _endedReported = false;
      _loadedUrl = widget.embedUrl;
      _controller.loadRequest(Uri.parse(widget.embedUrl));
    }
  }

  /// Injects JS to detect the `<video>` `ended` event inside the embed page.
  ///
  /// Uses [MutationObserver] so the listener re-attaches whenever the
  /// player injects a new `<video>` element after `DOMContentLoaded`.
  void _injectEndWatcher() {
    final script = r'''
      (function () {
        function reportEnd() {
          if (window.__videoEndReported) return;
          window.__videoEndReported = true;
          if (window.onVideoEnd) window.onVideoEnd.postMessage('ENDED');
        }
        function attach() {
          document.querySelectorAll('video').forEach(function (v) {
            v.addEventListener('ended', reportEnd, true);
          });
        }
        attach();
        if (window.MutationObserver) {
          new MutationObserver(attach)
              .observe(document.documentElement, {childList: true, subtree: true});
        }
      })();
    ''';
    _controller.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    final backBtn = _AnimatedBackButton(
      visible: _controlsVisible,
      onTap: _triggerBack,
    );
    final body = Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.fillRemainingSpace)
              Expanded(child: WebViewWidget(controller: _controller))
            else
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: WebViewWidget(controller: _controller),
              ),
          ],
        ),
        // Touch detector — shows controls and back button
        Positioned.fill(
          child: GestureDetector(
            onTap: _showControls,
            onLongPressStart: (_) => _showControls(),
            onLongPressEnd: (_) => _hideTimer?.cancel(),
            child: Container(
              color: Colors.transparent,
              child: backBtn,
            ),
          ),
        ),
      ],
    );
    return body;
  }
}

/// Back button that fades in/out and lives at the top-left of the player.
class _AnimatedBackButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const _AnimatedBackButton({required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: visible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !visible,
        child: SafeArea(
          top: true,
          bottom: false,
          left: false,
          right: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child:
                      Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
