import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/home/presentation/home_bloc.dart';
import 'package:cinewave/features/home/presentation/widgets/movie_list.dart';
import 'package:cinewave/features/home/presentation/widgets/tv_list.dart';
import 'package:cinewave/features/home/presentation/widgets/category_section.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cinewave/features/home/presentation/widgets/trending_carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _trendingMounted = false;
  bool _moviesMounted = false;
  bool _tvMounted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return _homeLoadingSkeleton();
          } else if (state is HomeLoaded) {
            return CustomScrollView(
              cacheExtent: 600,
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.black.withValues(alpha: 0.8),
                  elevation: 0,
                  pinned: true,
                  floating: false,
                  automaticallyImplyLeading: false,
                  title: const Text(
                    'CineWave',
                    style: TextStyle(
                      color: Color(0xFF2F1869),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  actions: const [],
                ),
                // Trending Hero Carousel — loads first, others deferred
                if (state.trendingMovies != null &&
                    state.trendingMovies!.isNotEmpty &&
                    _trendingMounted)
                  SliverToBoxAdapter(
                    child: TrendingCarousel(
                      movies: state.trendingMovies!,
                    ),
                  ),
                // Content Sections
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Latest Movies Section
                      if (_moviesMounted)
                        CategorySection(
                          title: 'Latest Movies',
                          onSeeAll: () {
                            Navigator.of(context).pushNamed(
                              '/all-media',
                              arguments: {'initialTab': 0},
                            );
                          },
                          child: MovieList(movies: state.movies),
                        ),
                      const SizedBox(height: 24),
                      // Latest TV Shows Section
                      if (_tvMounted)
                        CategorySection(
                          title: 'Latest TV Shows',
                          onSeeAll: () {
                            Navigator.of(context).pushNamed(
                              '/all-media',
                              arguments: {'initialTab': 1},
                            );
                          },
                          child: TVList(tvShows: state.tvShows),
                        ),
                      const SizedBox(height: 24),
                      // Trending Section (horizontal list)
                      if (state.trendingMovies != null &&
                          state.trendingMovies!.isNotEmpty &&
                          _trendingMounted)
                        CategorySection(
                          title: 'Trending Now',
                          onSeeAll: () {
                            Navigator.of(context).pushNamed(
                              '/all-media',
                              arguments: {'initialTab': 0},
                            );
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

  /// Staggers section attachment so no frame ever handles more than
  /// ~15 new image decodes at once.  All three sections start hidden;
  /// the frame callback mounts them at 80 ms intervals giving Flutter
  /// ~3 frames to paint shimmer tiles and one NetworkImageWidget each.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carousel — 80 ms after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) setState(() => _trendingMounted = true);
      });
    });
    // Movies — 160 ms after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 160), () {
        if (mounted) setState(() => _moviesMounted = true);
      });
    });
    // TV — 240 ms after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 240), () {
        if (mounted) setState(() => _tvMounted = true);
      });
    });
  }

  Widget _buildTileShimmer({required double? width, required double? height}) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1F1F1F),
      highlightColor: const Color(0xFF303030),
      period: const Duration(milliseconds: 700),
      child: Container(width: width, height: height, color: Colors.black),
    );
  }

  /// Full-screen shimmer skeleton shown while home data is loading.
  Widget _homeLoadingSkeleton() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black.withValues(alpha: 0.8),
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            title: Shimmer.fromColors(
              baseColor: const Color(0xFF1F1F1F),
              highlightColor: const Color(0xFF303030),
              period: const Duration(milliseconds: 700),
              child: Container(width: 140, height: 24, color: Colors.black),
            ),
          ),
          SliverToBoxAdapter(child: _buildLoadingCarouselShimmer()),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildSectionTitleShimmer(),
                _buildMovieRowShimmer(),
                const SizedBox(height: 24),
                _buildSectionTitleShimmer(),
                _buildTVRowShimmer(),
                const SizedBox(height: 24),
                _buildSectionTitleShimmer(),
                _buildMovieRowShimmer(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCarouselShimmer() {
    final screenW = MediaQuery.of(context).size.width;
    final carouselHeight = (screenW / (16 / 9)).clamp(280.0, 480.0);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: carouselHeight,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF1F1F1F),
        highlightColor: const Color(0xFF303030),
        period: const Duration(milliseconds: 700),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitleShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF1F1F1F),
        highlightColor: const Color(0xFF303030),
        period: const Duration(milliseconds: 700),
        child: Container(width: 160, height: 22, color: Colors.black),
      ),
    );
  }

  Widget _buildMovieRowShimmer() {
    const tileW = 130.0;
    const tileH = 190.0;
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            width: tileW,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTileShimmer(
                    width: tileW,
                    height: tileH,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTileShimmer(width: tileW * 0.9, height: 14),
                const SizedBox(height: 6),
                _buildTileShimmer(width: tileW * 0.6, height: 14),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTVRowShimmer() {
    const tileW = 130.0;
    const tileH = 190.0;
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            width: tileW,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTileShimmer(
                    width: tileW,
                    height: tileH,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTileShimmer(width: tileW * 0.9, height: 14),
                const SizedBox(height: 6),
                _buildTileShimmer(width: tileW * 0.6, height: 14),
              ],
            ),
          );
        },
      ),
    );
  }
}
