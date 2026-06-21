import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ExtractionResult {
  final String url;
  final Map<String, String> headers;
  final List<MediaSubtitle>? subtitles;

  ExtractionResult({required this.url, required this.headers, this.subtitles});
}

class MediaSubtitle {
  final String url;
  final String label;
  final String language;

  MediaSubtitle({required this.url, required this.label, required this.language});
}

class LinkExtractor {
  static const String agentUrl = 'https://movie-scrape-silk.vercel.app/agent.js';
  static HeadlessInAppWebView? _headlessWebView;
  static String? _cachedAgentJs;
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(minutes: 5),
    receiveTimeout: const Duration(minutes: 5),
  ));

  static Future<String?> extract(String embedUrl) async {
    final result = await extractWithHeaders(embedUrl);
    return result?.url;
  }

  static Future<String?> resolve(String embedUrl) async {
    final result = await extractWithHeaders(embedUrl);
    return result?.url;
  }

  static Future<ExtractionResult?> extractWithHeaders(String embedUrl) async {
    final completer = Completer<ExtractionResult?>();
    
    String? episodeHref;
    if (embedUrl.contains('/e/movie/')) {
      final id = embedUrl.split('/e/movie/').last;
      episodeHref = 'streamex:movie:$id';
    } else if (embedUrl.contains('/e/tv/')) {
      final parts = embedUrl.split('/e/tv/').last.split('/');
      if (parts.length >= 3) {
        episodeHref = 'streamex:tv:${parts[0]}:${parts[1]}:${parts[2]}';
      }
    }

    if (episodeHref == null) {
      debugPrint('❌ LinkExtractor: Could not parse episodeHref from $embedUrl');
      return null;
    }

    try {
      if (_cachedAgentJs == null) {
        debugPrint('🌐 LinkExtractor: Fetching agent.js...');
        final res = await _dio.get(agentUrl);
        _cachedAgentJs = res.data.toString();
        debugPrint('✅ LinkExtractor: agent.js fetched (${_cachedAgentJs!.length} bytes)');
      }

      _headlessWebView = HeadlessInAppWebView(
        initialData: InAppWebViewInitialData(data: """
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            <body>
              <script>console.log('WebView: Context initialized');</script>
            </body>
          </html>
        """),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
        ),
        onConsoleMessage: (controller, message) {
          debugPrint('🌐 LinkExtractor JS: ${message.message}');
        },
        onReceivedError: (controller, request, error) {
          debugPrint('❌ LinkExtractor WebView Error: ${error.description}');
        },
        onWebViewCreated: (controller) {
          controller.addJavaScriptHandler(handlerName: 'fetchv2', callback: (args) async {
            final String url = args[0];
            final Map<String, dynamic> headers = Map<String, dynamic>.from(args[1]);
            final String method = args[2];
            final String? body = args[3]?.toString();

            try {
              final res = await _dio.request(
                url,
                data: (body != null && body.isNotEmpty && body != '""' && body != "''" && body != "null") ? body : null,
                options: Options(
                  method: method,
                  headers: headers,
                  validateStatus: (_) => true,
                  responseType: ResponseType.plain,
                ),
              );

              final normalizedHeaders = <String, String>{};
              res.headers.forEach((name, values) {
                normalizedHeaders[name.toLowerCase()] = values.join(', ');
              });

              final bodyText = res.data?.toString() ?? '';

              return {
                'status': res.statusCode,
                'ok': (res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300,
                'headers': normalizedHeaders,
                'body': bodyText,
                'bodyBytes': bodyText.length,
              };
            } catch (e) {
              return {
                'status': 500,
                'ok': false,
                'headers': {},
                'body': json.encode({'error': e.toString()}),
                'bodyBytes': 0,
              };
            }
          });

          controller.addJavaScriptHandler(handlerName: 'extractionFinished', callback: (args) {
            final resultJson = args[0];
            if (resultJson != null) {
              try {
                final data = json.decode(resultJson);
                if (data['streams'] != null && data['streams'] is List && data['streams'].length >= 2) {
                  final String streamUrl = data['streams'][1].toString();
                  final Map<String, dynamic> rawHeaders = data['headers'] ?? {};
                  final Map<String, String> headers = rawHeaders.map((k, v) => MapEntry(k, v.toString()));
                  
                  final List<MediaSubtitle> subtitles = [];
                  if (data['subtitles'] != null && data['subtitles'] is List) {
                    for (var sub in data['subtitles']) {
                      if (sub['url'] != null) {
                        subtitles.add(MediaSubtitle(
                          url: sub['url'].toString(),
                          label: sub['lang']?.toString() ?? 'English',
                          language: sub['lang']?.toString().toLowerCase() ?? 'en',
                        ));
                      }
                    }
                  }

                  debugPrint('🎯 LinkExtractor: Success! URL: $streamUrl, Subtitles: ${subtitles.length}');
                  completer.complete(ExtractionResult(
                    url: streamUrl,
                    headers: headers,
                    subtitles: subtitles.isNotEmpty ? subtitles : null,
                  ));
                } else if (data['error'] != null) {
                  debugPrint("❌ LinkExtractor: Agent error: ${data['error']}");
                  completer.complete(null);
                } else {
                  debugPrint("❌ LinkExtractor: No playable streams found");
                  completer.complete(null);
                }
              } catch (e) {
                debugPrint("❌ LinkExtractor: Parse failed: $e");
                completer.complete(null);
              }
            } else {
              completer.complete(null);
            }
          });
        },
        onLoadStop: (controller, url) async {
          debugPrint('🚀 LinkExtractor: Context ready. Starting agent for $episodeHref');
          await controller.evaluateJavascript(source: """
            (async function() {
              window.fetchv2 = async function(url, headers, method, body) {
                const result = await window.flutter_inappwebview.callHandler('fetchv2', url, headers, method, body);
                return {
                  status: result.status,
                  ok: result.ok,
                  headers: result.headers,
                  contentType: result.headers['content-type'] || '',
                  body: result.body,
                  bodyBytes: result.bodyBytes || 0,
                  text: async () => result.body,
                  json: async () => { try { return JSON.parse(result.body); } catch(e) { return { error: 'parse_failed', raw: result.body }; } }
                };
              };
              
              window.exports = {};
              
              try {
                ${_cachedAgentJs!}
                
                console.log('LinkExtractor: Calling extractStreamUrl...');
                const result = await extractStreamUrl('$episodeHref', 'en');
                window.flutter_inappwebview.callHandler('extractionFinished', JSON.stringify(result));
              } catch (e) {
                console.error('LinkExtractor: Agent Exception: ' + e.message);
                window.flutter_inappwebview.callHandler('extractionFinished', JSON.stringify({ error: e.message }));
              }
            })();
          """);
        },
      );

      await _headlessWebView!.run();
      
      final result = await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          debugPrint('⏰ LinkExtractor: Timed out after 5 minutes');
          return null;
        },
      );

      return result;
    } catch (e) {
      debugPrint('❌ LinkExtractor: Critical failure: $e');
      return null;
    } finally {
      _headlessWebView?.dispose();
      _headlessWebView = null;
    }
  }
}
