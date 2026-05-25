import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/movie_detail/presentation/movie_detail_bloc.dart';
import 'package:cinewave/features/movie_detail/data/repositories/movie_detail_repository.dart';
import 'package:cinewave/features/movie_detail/presentation/widgets/detail_info.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/shared/utils/link_extractor.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_bloc.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_event.dart';

class MovieDetailPage extends StatelessWidget {
  static const String routeName = '/movie-detail';

  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Movie movie = ModalRoute.of(context)!.settings.arguments as Movie;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: BlocProvider(
        create: (_) => MovieDetailBloc(
          movieDetailRepository: context.read<MovieDetailRepository>(),
        )..add(LoadMovieDetail(movie: movie)),
        child: CustomScrollView(
          scrollCacheExtent: ScrollCacheExtent.pixels(2000), slivers: [
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
                  // Action Buttons Row
                  if (movie.playerUrl.isNotEmpty ||
                      (movie.videoUrl != null && movie.videoUrl!.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Play button → landscape player
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  '/video-player',
                                  arguments: {
                                    'tmdbId': movie.id.toString(),
                                    'title': movie.title,
                                    'type': 'movie',
                                  },
                                );
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
                          // Download button
                          IconButton(
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Extracting link...')),
                              );
                              final embedUrl = 'https://play.xpass.top/e/movie/${movie.id}';
                              final downloadUrl = await LinkExtractor.extract(embedUrl);
                              if (downloadUrl != null) {
                                if (context.mounted) {
                                  context.read<DownloadBloc>().add(
                                    StartDownload(movie: movie, url: downloadUrl),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Download started')),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to extract download link')),
                                  );
                                }
                              }
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
                          // Like button
                          IconButton(
                            onPressed: () {},
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white38),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.thumb_up_off_alt, color: Colors.white70),
                            ),
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
