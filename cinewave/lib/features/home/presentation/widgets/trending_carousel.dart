import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/core/ads/ad_service.dart';

class TrendingCarousel extends StatefulWidget {
  final List<Movie> movies;

  const TrendingCarousel({super.key, required this.movies});

  @override
  State<TrendingCarousel> createState() => _TrendingCarouselState();
}

class _TrendingCarouselState extends State<TrendingCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _scheduleAutoScroll();
  }

  void _scheduleAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _advancePage(),
    );
  }

  void _pauseAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  /// Resume auto-scroll after a human-friendly delay so the user has time
  /// to read the slide they manually swiped to.
  void _resumeAutoScroll() {
    _pauseAutoScroll();
    Future.delayed(const Duration(seconds: 6), _scheduleAutoScroll);
  }

  void _advancePage() {
    if (!_pageController.hasClients) return;
    final nextPage = _currentPage + 1;
    _pageController.animateToPage(
      nextPage >= widget.movies.length ? 0 : nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use a manual LayoutBuilder to get precise aspect-ratio dimensions.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Carousel area: full available width, 16 px horizontal margins total.
        final displayW = constraints.maxWidth - 16;
        final carouselHeight = (constraints.maxWidth / (16 / 9)).clamp(280.0, 480.0);

        return SizedBox(
          height: carouselHeight,
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _pauseAutoScroll();
                  } else if (notification is ScrollEndNotification) {
                    _resumeAutoScroll();
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    if (mounted) setState(() => _currentPage = index);
                  },
                  itemCount: widget.movies.length,
                  itemBuilder: (context, index) {
                    final movie = widget.movies[index];
                    return _TrendingSlide(
                      movie: movie,
                      displayWidth: displayW,
                      displayHeight: carouselHeight,
                    );
                  },
                ),
              ),
              // Dot indicators
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.movies.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == i
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrendingSlide extends StatelessWidget {
  final Movie movie;
  final double displayWidth;
  final double displayHeight;

  const _TrendingSlide({
    required this.movie,
    required this.displayWidth,
    required this.displayHeight,
  });

  String? get _backdropUrl =>
      movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl;

  int get _year {
    if (movie.releaseDate.isNotEmpty) {
      try {
        return int.parse(movie.releaseDate.split('-')[0]);
      } catch (_) {}
    }
    return 0;
  }

  double get _rating => movie.voteAverage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/movie-detail', arguments: movie);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: NetworkImageWidget(
                imageUrl: _backdropUrl ?? '',
                width: displayWidth,
                height: displayHeight,
                fit: BoxFit.cover,
              ),
            ),
            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF46D369), width: 1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          '${(_rating * 10).toInt()}% Match',
                          style: const TextStyle(
                            color: Color(0xFF46D369),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_year > 0)
                        Text(
                          _year.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (movie.overview.isNotEmpty)
                    Text(
                      movie.overview,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Play button — opens landscape player
                  if (movie.playerUrl.isNotEmpty ||
                      (movie.videoUrl != null && movie.videoUrl!.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextButton.icon(
                        onPressed: () {
                          AdService().showRewardedInterstitialAd(() {
                            Navigator.of(context).pushNamed(
                              '/video-player',
                              arguments: {
                                'tmdbId': movie.id.toString(),
                                'title': movie.title,
                                'type': 'movie',
                                'posterUrl': movie.posterUrl,
                              },
                            );
                          });
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                        label: Text(
                          'Play',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF46D369).withValues(alpha: 0.9),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
