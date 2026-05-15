import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/movie_detail/presentation/movie_detail_bloc.dart';
import 'package:cinewave/features/movie_detail/data/repositories/movie_detail_repository.dart';
import 'package:cinewave/features/movie_detail/presentation/widgets/detail_info.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/shared/widgets/video_player.dart';
import 'package:cinewave/core/models/media_models.dart';

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
          cacheExtent: 2000,
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.black,
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
                  VideoPlayerWidget(videoUrl: movie.videoUrl),
                  const SizedBox(height: 16),
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