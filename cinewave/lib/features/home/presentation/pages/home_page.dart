import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/home/presentation/home_bloc.dart';
import 'package:cinewave/features/home/presentation/widgets/movie_list.dart';
import 'package:cinewave/features/home/presentation/widgets/tv_list.dart';
import 'package:cinewave/features/home/presentation/widgets/category_section.dart';
import 'package:cinewave/features/home/presentation/widgets/hero_banner.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) => previous is! HomeLoaded || current is! HomeLoaded,
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            return CustomScrollView(
              cacheExtent: 1500,
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.black.withValues(alpha: 0.8),
                  elevation: 0,
                  pinned: true,
                  floating: false,
                  title: Text(
                    'CineWave',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search, size: 28),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/search');
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                // Hero Banner — precache image eagerly for smooth entry
                if (state.featuredMovie != null || state.featuredTVShow != null)
                  SliverToBoxAdapter(
                    child: FutureBuilder<void>(
                      future: () async {
                        final url = state.featuredMovie?.backdropUrl
                            ?? state.featuredTVShow?.backdropUrl
                            ?? state.featuredMovie?.posterUrl
                            ?? state.featuredTVShow?.posterUrl;
                        if (url != null && url.isNotEmpty) {
                          await precacheImage(
                            NetworkImage(url),
                            context,
                          );
                        }
                      }(),
                      builder: (context, _) => HeroBanner(
                        featuredItem: state.featuredMovie ?? state.featuredTVShow!,
                        height: 450,
                      ),
                    ),
                  ),
                // Content Sections
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Latest Movies Section
                      CategorySection(
                        title: 'Latest Movies',
                        child: MovieList(movies: state.movies),
                      ),
                      const SizedBox(height: 24),
                      // Latest TV Shows Section
                      CategorySection(
                        title: 'Latest TV Shows',
                        child: TVList(tvShows: state.tvShows),
                      ),
                      const SizedBox(height: 24),
                      // Trending Section
                      if (state.trendingMovies != null && state.trendingMovies!.isNotEmpty)
                        CategorySection(
                          title: 'Trending Now',
                          onSeeAll: () {
                            // Navigate to see all trending
                          },
                          child: MovieList(movies: state.trendingMovies!),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(LoadHomeData());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}