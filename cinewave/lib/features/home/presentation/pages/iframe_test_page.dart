import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Bare-bones iframe test page.
///
/// Wraps the supplied [embedUrl] inside a plain HTML `<iframe>` and loads it
/// into a `WebView` with absolutely no decoration, no navigation-blocking, no
/// JS channels, and no injected scripts.  Use this to verify that the backend
/// embed page itself renders correctly inside a real browser engine before
/// wiring it to the full production `IframeVideoPlayer`.
class IframeTestPage extends StatefulWidget {
  /// The Videasy embed URL, e.g.
  /// `https://player.videasy.net/movie/350` or
  /// `https://player.videasy.net/tv/1399/1/1`.
  final String embedUrl;

  const IframeTestPage({super.key, required this.embedUrl});

  @override
  State<IframeTestPage> createState() => _IframeTestPageState();
}

class _IframeTestPageState extends State<IframeTestPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadHtmlString(_buildIframeHtml(widget.embedUrl));
  }

  /// Returns a minimal HTML document that embeds the target URL in an
  /// `<iframe>` sized to fill the viewport — nothing else.
  static String _buildIframeHtml(String src) => '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      html, body { margin: 0; padding: 0; background: #000; height: 100%; overflow: hidden; }
      iframe { border: none; width: 100%; height: 100%; }
    </style>
  </head>
  <body>
    <iframe src="$src" allowfullscreen allow="autoplay; encrypted-media"></iframe>
  </body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
