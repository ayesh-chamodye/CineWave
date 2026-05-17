import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  /// Full embed URL from the backend `playerUrl` field.
  final String embedUrl;

  /// When `true` (default) the WebView is wrapped in `Expanded` so it fills
  /// all remaining vertical space inside its parent `Column`.
  /// Set to `false` when the parent controls sizing explicitly.
  final bool fillRemainingSpace;

  /// Called when the video fires its `ended` event via the JS→Dart bridge.
  final VoidCallback? onEndOfVideo;

  const IframeVideoPlayer({
    super.key,
    required this.embedUrl,
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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _setupController();
    _controller.loadRequest(Uri.parse(widget.embedUrl));
    _loadedUrl = widget.embedUrl;
  }

  void _setupController() {
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Block pop-up / new-tab navigations (ad popups, external links via target=_blank / window.open)
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
    final webView = WebViewWidget(controller: _controller);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.fillRemainingSpace)
          Expanded(child: webView)
        else
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: webView,
          ),
      ],
    );
  }
}
