import 'package:flutter/material.dart';
import 'package:cinewave/features/movie_list/presentation/pages/movies_list_page.dart';
import 'package:cinewave/features/tv_list/presentation/pages/tv_list_page.dart';

/// Modern movie-app style tab screen (Movies / TV Shows)
class AllMediaScreen extends StatelessWidget {
  static const String routeName = '/all-media';

  /// 0 = Movies tab, 1 = TV Shows tab
  final int initialTab;

  const AllMediaScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      initialIndex: initialTab,
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header Title (modern movie app style) ────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(                  
                  children: [  
                    BackButton(color: Colors.white),                  
                    Text(
                      "Explore",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),                                        
                  ],
                ),
              ),

              // ── Floating Tab Bar (modern pill design) ───────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.15),
                    ),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    splashBorderRadius: BorderRadius.circular(14),
                    tabs: const [
                      Tab(text: 'Movies'),
                      Tab(text: 'TV Shows'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Content Area ─────────────────────────────────────────
              const Expanded(
                child: TabBarView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    MoviesListPage(),
                    TVListPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
