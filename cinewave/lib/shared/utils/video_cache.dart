import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

/// Custom cache manager for video streams with a longer cache period
class VideoCacheManager {
  static const String key = 'videoCache';
  static final VideoCacheManager _instance = VideoCacheManager._internal();
  factory VideoCacheManager() => _instance;
  VideoCacheManager._internal();

  static CacheManager get _cacheManager => CacheManager(
        Config(
          key,
          stalePeriod: const Duration(days: 7), // Keep videos cached for a week
          maxNrOfCacheObjects: 100, // Increased for HLS segments
          fileService: HttpFileService(),
        ),
      );

  /// Get a file from cache or download and cache it
  Future<File> getFile(String url, {Map<String, String>? headers}) async {
    try {
      // Try to get from cache first
      return await _cacheManager.getSingleFile(url);
    } catch (e) {
      // If not in cache, download and cache it
      try {
        var response = await http.get(
          Uri.parse(url),
          headers: headers,
        );
        
        if (response.statusCode == 200) {
          // Store in cache
          await _cacheManager.putFile(url, Uint8List.fromList(response.bodyBytes));
          return await _cacheManager.getSingleFile(url);
        } else {
          throw Exception('Failed to download video: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Failed to cache video: $e');
      }
    }
  }

  /// Check if a URL is in cache
  Future<bool> isCached(String url) async {
    try {
      var file = await _cacheManager.getSingleFile(url);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Put file in cache manually
  Future<void> putFile(String url, List<int> bytes) async {
    await _cacheManager.putFile(url, Uint8List.fromList(bytes));
  }

  /// Clear the video cache
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }
}