import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/tv_detail/presentation/tv_detail_bloc.dart';
import 'package:cinewave/features/tv_detail/data/repositories/tv_detail_repository.dart';
import 'package:cinewave/features/tv_detail/presentation/widgets/detail_info.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/shared/widgets/video_player.dart';
import 'package:cinewave/core/models/media_models.dart';

class TVDetailPage extends StatelessWidget {
  static const String routeName = '/tv-detail';

  const TVDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TVShow tvShow = ModalRoute.of(context)!.settings.arguments as TVShow;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: BlocProvider(
        create: (_) => TVDetailBloc(
          tvDetailRepository: context.read<TVDetailRepository>(),
        )..add(LoadTVDetail(tvShow: tvShow)),
        child: CustomScrollView(
          cacheExtent: 2000,
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.black,
              flexibleSpace: FlexibleSpaceBar(
                background: NetworkImageWidget(
                  imageUrl: tvShow.backdropUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VideoPlayerWidget(videoUrl: tvShow.videoUrl),
                  const SizedBox(height: 16),
                  DetailInfoWidget(tvShow: tvShow),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}