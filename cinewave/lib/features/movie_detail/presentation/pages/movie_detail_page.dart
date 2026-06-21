import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/movie_detail/presentation/movie_detail_bloc.dart';
import 'package:cinewave/features/movie_detail/data/repositories/movie_detail_repository.dart';
import 'package:cinewave/features/movie_detail/presentation/widgets/detail_info.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/shared/widgets/banner_ad_widget.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/ads/ad_service.dart';
import 'package:cinewave/features/library/presentation/bloc/library_bloc.dart';
import 'package:cinewave/features/library/presentation/bloc/library_event.dart';
import 'package:cinewave/features/library/presentation/bloc/library_state.dart';
import 'package:cinewave/core/models/library_models.dart';

class MovieDetailPage extends StatefulWidget {
  static const String routeName = '/movie-detail';

  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late final Movie _movie;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
  }

  @override
  Widget build(BuildContext context) {
    final Movie movie = _movie;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
      body: BlocProvider(
        create: (_) => MovieDetailBloc(
          movieDetailRepository: context.read<MovieDetailRepository>(),
        )..add(LoadMovieDetail(movie: movie)),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.black,
              leading: const BackButton(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: NetworkImageWidget(
                  imageUrl: movie.backdropUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<MovieDetailBloc, MovieDetailState>(
                builder: (context, state) {
                  Movie movieToShow = movie;
                  bool isLoading = state is MovieDetailLoading;
                  
                  if (state is MovieDetailLoaded) {
                    movieToShow = state.movie;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (movieToShow.playerUrl.isNotEmpty ||
                          (movieToShow.videoUrl != null && movieToShow.videoUrl!.isNotEmpty) || movieToShow.id > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    AdService().showRewardedInterstitialAd(() {
                                      Navigator.of(context).pushNamed(
                                        '/video-player',
                                        arguments: {
                                          'tmdbId': movieToShow.id.toString(),
                                          'title': movieToShow.title,
                                          'type': 'movie',
                                          'posterUrl': movieToShow.posterUrl,
                                        },
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                                  label: const Text('Play', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              BlocBuilder<LibraryBloc, LibraryState>(
                                builder: (context, libraryState) {
                                  bool isFav = false;
                                  bool isWatchlist = false;
                                  bool inHistory = false;
                                  if (libraryState is LibraryLoaded) {
                                    isFav = libraryState.favorites.any((f) => f.mediaId == movieToShow.id.toString());
                                    isWatchlist = libraryState.watchlist.any((w) => w.mediaId == movieToShow.id.toString());
                                    inHistory = libraryState.history.any((h) => h.mediaId == movieToShow.id.toString());
                                  }
                                  return Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          context.read<LibraryBloc>().add(
                                                ToggleFavorite(
                                                  FavoriteItem(
                                                    mediaId: movieToShow.id.toString(),
                                                    title: movieToShow.title,
                                                    posterUrl: movieToShow.posterUrl,
                                                    backdropUrl: movieToShow.backdropUrl,
                                                    overview: movieToShow.overview,
                                                    type: 'movie',
                                                    rating: movieToShow.voteAverage,
                                                    releaseDate: movieToShow.releaseDate,
                                                  ),
                                                ),
                                              );
                                        },
                                        icon: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.white38),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            isFav ? Icons.favorite : Icons.favorite_border,
                                            color: isFav ? Colors.red : Colors.white70,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () {
                                          context.read<LibraryBloc>().add(
                                                ToggleWatchlist(
                                                  FavoriteItem(
                                                    mediaId: movieToShow.id.toString(),
                                                    title: movieToShow.title,
                                                    posterUrl: movieToShow.posterUrl,
                                                    backdropUrl: movieToShow.backdropUrl,
                                                    overview: movieToShow.overview,
                                                    type: 'movie',
                                                    rating: movieToShow.voteAverage,
                                                    releaseDate: movieToShow.releaseDate,
                                                  ),
                                                ),
                                              );
                                        },
                                        icon: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.white38),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            isWatchlist ? Icons.bookmark : Icons.bookmark_border,
                                            color: isWatchlist ? Colors.blueAccent : Colors.white70,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (inHistory)
                                        IconButton(
                                          onPressed: () {
                                            context.read<LibraryBloc>().add(DeleteHistoryItem('movie_${movieToShow.id}'));
                                          },
                                          icon: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.white38),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Icon(Icons.history_toggle_off, color: Colors.white70),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      DetailInfoWidget(movie: movieToShow),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
