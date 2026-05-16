import 'package:flutter/material.dart';

/// ── Server infrastructure ───────────────────────────────────────────────────

/// Defines a media streaming player-server that the player can switch between.
///
/// All servers share the same relative embed path structure:
///   Movie  →  `https://{host}/movie/{id}`
///   TV     →  `https://{host}/tv/{id}/{season}/{episode}`
class AppServer {
  /// Regenerates the embed URL for this server, swapping only the host while
  /// keeping the existing path (movie or TV with episode) unchanged.
  String rebuild(String currentEmbedUrl) {
    try {
      final uri = Uri.parse(currentEmbedUrl);
      return uri.replace(host: host).toString();
    } catch (_) {
      return currentEmbedUrl;
    }
  }

  /// Parses an embed URL and returns the [AppServer] whose host matches, or `null`.
  static AppServer? byHost(String host) {
    try { return all.firstWhere((s) => s.host == host); } catch (_) { return null; }
  }

  static AppServer get defaultServer => all.first;

  // ── All registered servers ─────────────────────────────────────────────────
  static const List<AppServer> all = [
    AppServer._('movie-scrape-silk.vercel.app', 'MovieScrape Silk', Color(0xFF8B5CF6)),
    AppServer._('www.111movies.net',            '111 Movies',      Color(0xFFEF4444)),
    AppServer._('primesrc.me',                  'PrimeSrc',        Color(0xFFF59E0B)),
  ];

  final String host;    // e.g. 'player.videasy.net'
  final String label;   // Display name: 'Videasy'
  final Color color;    // Accent colour for the server badge

  const AppServer._(this.host, this.label, this.color);
}

/// ── App-wide constants ───────────────────────────────────────────────────────
class AppConstants {
  static const String baseUrl = 'https://movie-scrape-silk.vercel.app';

  // Default selected server
  static AppServer selectedServer = AppServer.all.first;

  // API Endpoints
  static const String home = '/api/home';
  static const String moviesLatest = '/api/movies/latest';
  static const String moviesSearch = '/api/movies/search';
  static const String tvLatest = '/api/tv/latest';
  static const String tvSearch = '/api/tv/search';

  // App Constants
  static const String appName = 'CineWave';
  static const String primaryColor = '#2F1869';
  static const String backgroundColor = '#141414';
  static const String cardBackgroundColor = '#181818';
  static const String textColor = '#FFFFFF';
  static const String secondaryTextColor = '#B3B3B3';
}
