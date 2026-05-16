import 'package:flutter/material.dart';
import 'package:cinewave/features/movie_list/presentation/pages/movies_list_page.dart';
import 'package:cinewave/features/tv_list/presentation/pages/tv_list_page.dart';

/// Two-tab screen for browsing all movies and TV shows page-by-page.
///
/// Uses `DefaultTabController` so neither tab is a child of `BlocProvider`
/// — each sub-page manages its own BLoC and ScrollController independently.
class AllMediaScreen extends StatelessWidget {
  static const String routeName = '/all-media';

  /// 0 = Movies tab, 1 = TV Shows tab.
  final int initialTab;

  const AllMediaScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTab,
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // ── Tab bar ───────────────────────────────────────────────────
            Container(
              color: Colors.black,
              child: TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                tabs: const [
                  Tab(text: 'Movies'),
                  Tab(text: 'TV Shows'),
                ],
              ),
            ),
            // ── Tab views ─────────────────────────────────────────────────
            const Expanded(
              child: TabBarView(
                children: [
                  MoviesListPage(),
                  TVListPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
