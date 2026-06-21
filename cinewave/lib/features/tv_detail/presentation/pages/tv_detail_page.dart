import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/tv_detail/presentation/tv_detail_bloc.dart';
import 'package:cinewave/features/tv_detail/data/repositories/tv_detail_repository.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/features/tv_detail/presentation/widgets/detail_info.dart';
import 'package:cinewave/shared/widgets/banner_ad_widget.dart';
import 'package:cinewave/shared/utils/link_extractor.dart';
import 'package:cinewave/core/ads/ad_service.dart';
import 'package:cinewave/features/library/presentation/bloc/library_bloc.dart';
import 'package:cinewave/features/library/presentation/bloc/library_event.dart';
import 'package:cinewave/features/library/presentation/bloc/library_state.dart';
import 'package:cinewave/core/models/library_models.dart';

class TVDetailPage extends StatefulWidget {
  static const String routeName = '/tv-detail';

  final TVShow tvShow;

  const TVDetailPage({super.key, required this.tvShow});

  @override
  State<TVDetailPage> createState() => _TVDetailPageState();
}

class _TVDetailPageState extends State<TVDetailPage> {
  TVShow? _currentTvShow;
  int? _selectedSeason;
  int? _selectedEpisode;
  late final StreamSubscription<TVDetailState> _tvDetailSubscription;

  @override
  void initState() {
    super.initState();
    _currentTvShow = widget.tvShow;
    
    // Check history for last watched episode
    final libraryState = context.read<LibraryBloc>().state;
    if (libraryState is LibraryLoaded) {
      final history = libraryState.history
          .where((h) => h.mediaId == widget.tvShow.id.toString())
          .toList();
      if (history.isNotEmpty) {
        history.sort((a, b) => b.lastWatched.compareTo(a.lastWatched));
        _selectedSeason = history.first.season;
        _selectedEpisode = history.first.episode;
      }
    }

    if (_selectedSeason == null && _currentTvShow != null && _currentTvShow!.seasons.isNotEmpty) {
      _selectedSeason = _currentTvShow!.seasons.first.seasonNumber;
      _selectedEpisode = 1;
    }

    _tvDetailSubscription =
        context.read<TVDetailBloc>().stream.listen((state) {
      if (state is TVDetailLoaded) {
        setState(() {
          _currentTvShow = state.tvShow;
          // Only override if not already set from history
          if (_selectedSeason == null) {
            if (_currentTvShow!.seasons.isNotEmpty) {
              _selectedSeason = _currentTvShow!.seasons.first.seasonNumber;
              _selectedEpisode = 1;
            } else {
              _selectedSeason = null;
              _selectedEpisode = null;
            }
          }
        });
      }
    });
    context.read<TVDetailBloc>().add(LoadTVDetail(tvShow: widget.tvShow));
  }

  @override
  void dispose() {
    _tvDetailSubscription.cancel();
    super.dispose();
  }


  void _playEpisode(int episode) {
    setState(() {
      _selectedEpisode = episode;
    });
  }

  Widget _buildSeasonDropdown() {
    if (_currentTvShow == null || _currentTvShow!.seasons.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButton<int>(
        isExpanded: true,
        hint: const Text('Select Season', style: TextStyle(color: Colors.white60)),
        value: _selectedSeason,
        items: _currentTvShow!.seasons
            .map((season) => DropdownMenuItem<int>(
                  value: season.seasonNumber,
                  child: Text('Season ${season.seasonNumber}',
                      style: const TextStyle(color: Colors.white)),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedSeason = value;
            _selectedEpisode = 1;
          });
        },
        dropdownColor: Colors.black87,
      ),
    );
  }

  Widget _buildEpisodeGrid() {
    final episodeCount = _episodeCountForCurrentSeason;
    if (episodeCount <= 0) return const SizedBox.shrink();

    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, libraryState) {
        List<WatchHistoryItem> history = [];
        if (libraryState is LibraryLoaded) {
          history = libraryState.history
              .where((h) => h.mediaId == _currentTvShow?.id.toString() && h.season == _selectedSeason)
              .toList();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: episodeCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
          itemBuilder: (context, index) {
            final episode = index + 1;
            final isWatched = history.any((h) => h.episode == episode && h.isCompleted);
            
            return Padding(
              padding: const EdgeInsets.all(3),
              child: _EpisodeSquare(
                episode: episode,
                onTap: () {
                  setState(() {
                    _selectedEpisode = episode;
                  });
                  AdService().showRewardedInterstitialAd(() {
                    Navigator.of(context).pushNamed(
                      '/video-player',
                      arguments: {
                        'tmdbId': _currentTvShow!.id.toString(),
                        'title': _currentTvShow!.name,
                        'type': 'tv',
                        'isTv': true,
                        'seasonNumber': _selectedSeason,
                        'episodeNumber': episode,
                        'posterUrl': _currentTvShow!.posterUrl,
                      },
                    );
                  });
                },
                isSelected: episode == _selectedEpisode,
                isWatched: isWatched,
              ),
            );
          },
        );
      },
    );
  }

  int get _episodeCountForCurrentSeason {
    if (_selectedSeason == null ||
        _currentTvShow == null ||
        _currentTvShow!.seasons.isEmpty) return 0;
    final season = _currentTvShow!.seasons.firstWhere(
      (s) => s.seasonNumber == _selectedSeason,
      orElse: () => _currentTvShow!.seasons.first,
    );
    return season.episodeCount;
  }

  Widget _buildContent(TVShow tvShow) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Colors.black,
          leading: const BackButton(color: Colors.white),
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
              const SizedBox(height: 16),
              if (tvShow.playerUrl.isNotEmpty ||
                  (tvShow.videoUrl != null && tvShow.videoUrl!.isNotEmpty))
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
                                  'tmdbId': tvShow.id.toString(),
                                  'title': tvShow.name,
                                  'type': 'tv',
                                  'isTv': true,
                                  'seasonNumber': _selectedSeason,
                                  'episodeNumber': _selectedEpisode,
                                  'posterUrl': tvShow.posterUrl,
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
                        builder: (context, state) {
                          bool isFav = false;
                          bool isWatchlist = false;
                          bool inHistory = false;
                          if (state is LibraryLoaded) {
                            isFav = state.favorites.any((f) => f.mediaId == tvShow.id.toString());
                            isWatchlist = state.watchlist.any((w) => w.mediaId == tvShow.id.toString());
                            inHistory = state.history.any((h) => h.mediaId == tvShow.id.toString());
                          }
                          return Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  context.read<LibraryBloc>().add(
                                        ToggleFavorite(
                                          FavoriteItem(
                                            mediaId: tvShow.id.toString(),
                                            title: tvShow.name,
                                            posterUrl: tvShow.posterUrl,
                                            backdropUrl: tvShow.backdropUrl,
                                            overview: tvShow.overview,
                                            type: 'tv',
                                            rating: tvShow.voteAverage,
                                            releaseDate: tvShow.firstAirDate,
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
                                            mediaId: tvShow.id.toString(),
                                            title: tvShow.name,
                                            posterUrl: tvShow.posterUrl,
                                            backdropUrl: tvShow.backdropUrl,
                                            overview: tvShow.overview,
                                            type: 'tv',
                                            rating: tvShow.voteAverage,
                                            releaseDate: tvShow.firstAirDate,
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
                                    final currentState = context.read<LibraryBloc>().state;
                                    if (currentState is LibraryLoaded) {
                                      final historyItems = currentState.history
                                          .where((h) => h.mediaId == tvShow.id.toString());
                                      for (var item in historyItems) {
                                        context.read<LibraryBloc>().add(DeleteHistoryItem(item.id));
                                      }
                                    }
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
              const SizedBox(height: 12),
              const BannerAdWidget(),
              const SizedBox(height: 20),
              DetailInfoWidget(tvShow: tvShow),
              const SizedBox(height: 20),
              _buildSeasonDropdown(),
              const SizedBox(height: 20),
              const Text('Episodes',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildEpisodeGrid(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<TVDetailBloc, TVDetailState>(
        builder: (context, state) {
          if (state is TVDetailLoading) return const Center(child: CircularProgressIndicator());
          if (state is TVDetailLoaded) return _buildContent(state.tvShow);
          if (state is TVDetailError) return Center(child: Text('Error: ${state.message}'));
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EpisodeSquare extends StatelessWidget {
  final int episode;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isWatched;

  const _EpisodeSquare({
    required this.episode,
    required this.onTap,
    required this.isSelected,
    this.isWatched = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(episode.toString(),
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold)),
            ),
            if (isWatched)
              Positioned(
                bottom: 2,
                right: 2,
                child: Icon(Icons.check_circle, size: 12, color: Colors.greenAccent.withValues(alpha: 0.8)),
              ),
          ],
        ),
      ),
    );
  }
}
