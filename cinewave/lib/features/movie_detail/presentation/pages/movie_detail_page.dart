import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/movie_detail/presentation/movie_detail_bloc.dart';
import 'package:cinewave/features/movie_detail/data/repositories/movie_detail_repository.dart';
import 'package:cinewave/features/movie_detail/presentation/widgets/detail_info.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_bloc.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_event.dart';
import 'package:cinewave/shared/widgets/source_selection_dialog.dart';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  if (movie.playerUrl.isNotEmpty ||
                      (movie.videoUrl != null && movie.videoUrl!.isNotEmpty))
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
                                      'tmdbId': movie.id.toString(),
                                      'title': movie.title,
                                      'type': 'movie',
                                      'posterUrl': movie.posterUrl,
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
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (dialogContext) => SourceSelectionDialog(
                                  title: movie.title,
                                  embedUrl: 'https://play.xpass.top/e/movie/${movie.id}',
                                  onUrlResolved: (url) {
                                    context.read<DownloadBloc>().add(
                                      StartDownload(movie: movie, url: url),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Download started')),
                                    );
                                  },
                                ),
                              );
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white38),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.download, color: Colors.white70),
                            ),
                          ),
                          const SizedBox(width: 8),
                          BlocBuilder<LibraryBloc, LibraryState>(
                            builder: (context, state) {
                              bool isFav = false;
                              if (state is LibraryLoaded) {
                                isFav = state.favorites.any((f) => f.mediaId == movie.id.toString());
                              }
                              return IconButton(
                                onPressed: () {
                                  context.read<LibraryBloc>().add(
                                        ToggleFavorite(
                                          FavoriteItem(
                                            mediaId: movie.id.toString(),
                                            title: movie.title,
                                            posterUrl: movie.posterUrl,
                                            backdropUrl: movie.backdropUrl,
                                            overview: movie.overview,
                                            type: 'movie',
                                            rating: movie.voteAverage,
                                            releaseDate: movie.releaseDate,
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
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  DetailInfoWidget(movie: movie),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
