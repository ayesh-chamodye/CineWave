import 'package:flutter/material.dart';
import 'package:cinewave/shared/widgets/main_layout.dart';
import 'package:cinewave/features/search/presentation/pages/search_page.dart';
import 'package:cinewave/features/movie_detail/presentation/pages/movie_detail_page.dart';
import 'package:cinewave/features/tv_detail/presentation/pages/tv_detail_page.dart';
import 'package:cinewave/splash_page.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/splash': (context) => const SplashPage(),
    '/': (context) => const MainLayout(),
    '/search': (context) => const SearchPage(),
    '/movie-detail': (context) => const MovieDetailPage(),
    '/tv-detail': (context) => const TVDetailPage(),
  };
}