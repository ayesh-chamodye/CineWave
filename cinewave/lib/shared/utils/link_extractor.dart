import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';

class LinkExtractor {
  static Future<String?> extract(String embedUrl) async {
    final Completer<String?> completer = Completer<String?>();
    HeadlessInAppWebView? headlessWebView;

    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(embedUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
          'Referer': 'https://streamex.sh/',
        },
      ),
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        javaScriptEnabled: true,
      ),
      onLoadResource: (controller, resource) {
        final url = resource.url.toString();
        // Look for m3u8 or mp4
        if ((url.contains('.m3u8') || url.contains('.mp4')) &&
            !url.contains('blob:') &&
            !url.contains('subtitle')) {
          if (!completer.isCompleted) {
            debugPrint('🎯 Extracted Link: $url');
            completer.complete(url);
          }
        }
      },
    );

    await headlessWebView.run();
    
    try {
      final result = await completer.future.timeout(
        const Duration(seconds: 20),
      );
      return result;
    } catch (_) {
      return null;
    } finally {
      await headlessWebView.dispose();
    }
  }
}
