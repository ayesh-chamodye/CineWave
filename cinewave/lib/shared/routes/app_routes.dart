import 'package:flutter/material.dart';
import 'package:cinewave/shared/widgets/main_layout.dart';
import 'package:cinewave/features/search/presentation/pages/search_page.dart';
import 'package:cinewave/features/movie_detail/presentation/pages/movie_detail_page.dart';
import 'package:cinewave/features/tv_detail/presentation/pages/tv_detail_page.dart';
import 'package:cinewave/features/all_media/presentation/all_media_screen.dart';
import 'package:cinewave/shared/widgets/landscape_video_player.dart';
import 'package:cinewave/splash_page.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
      case '/':
        return MaterialPageRoute(
          builder: (_) => const MainLayout(),
          settings: settings,
        );
      case '/search':
        return MaterialPageRoute(
          builder: (_) => const SearchPage(),
          settings: settings,
        );
      case '/movie-detail':
        return MaterialPageRoute(
          builder: (_) => const MovieDetailPage(),
          settings: settings,
        );
      case '/tv-detail':
        return MaterialPageRoute(
          builder: (_) => const TVDetailPage(),
          settings: settings,
        );
      case '/all-media':
        final args = settings.arguments as Map<String, dynamic>?;
        final initialTab = (args?['initialTab'] as int?) ?? 0;
        return MaterialPageRoute(
          builder: (_) => AllMediaScreen(initialTab: initialTab),
          settings: settings,
        );
      case '/video-player':
        final args =
            settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LandscapeVideoPlayerPage(
            title: args?['title'] as String?,
            isTv: (args?['isTv'] as bool?) ?? (args?['type'] == 'tv'),
            seasonNumber: args?['seasonNumber'] as int?,
            episodeNumber: args?['episodeNumber'] as int?,
            tmdbId: args?['tmdbId'] as String?,
            videoUrl: args?['videoUrl'] as String?,
            isLocal: (args?['isLocal'] as bool?) ?? false,
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
          settings: settings,
        );
    }
  }
}
