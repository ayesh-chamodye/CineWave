import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/tv_detail/presentation/tv_detail_bloc.dart';
import 'package:cinewave/features/tv_detail/data/repositories/tv_detail_repository.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_bloc.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_event.dart';
import 'package:cinewave/shared/widgets/source_selection_dialog.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/features/tv_detail/presentation/widgets/detail_info.dart';
import 'package:cinewave/shared/utils/link_extractor.dart';

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
    if (_currentTvShow != null && _currentTvShow!.seasons.isNotEmpty) {
      _selectedSeason = _currentTvShow!.seasons.first.seasonNumber;
      _selectedEpisode = 1;
    }
    _tvDetailSubscription =
        context.read<TVDetailBloc>().stream.listen((state) {
      if (state is TVDetailLoaded) {
        setState(() {
          _currentTvShow = state.tvShow;
          if (_currentTvShow!.seasons.isNotEmpty) {
            _selectedSeason = _currentTvShow!.seasons.first.seasonNumber;
            _selectedEpisode = 1;
          } else {
            _selectedSeason = null;
            _selectedEpisode = null;
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

  void _startDownload() {
    if (_selectedSeason == null ||
        _selectedEpisode == null ||
        _currentTvShow == null) return;
    final embedUrl =
        'https://play.xpass.top/e/tv/${_currentTvShow!.id}/${_selectedSeason}/${_selectedEpisode}';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => SourceSelectionDialog(
        title:
            '${_currentTvShow!.name} S${_selectedSeason!.toString().padLeft(2, '0')}E${_selectedEpisode!.toString().padLeft(2, '0')}',
        embedUrl: embedUrl,
        onUrlResolved: (url) {
          context.read<DownloadBloc>().add(
                StartDownload(
                  tvShow: _currentTvShow!,
                  season: _selectedSeason,
                  episode: _selectedEpisode,
                  url: url,
                ),
              );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download started')),
          );
        },
      ),
    );
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: episodeCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
      itemBuilder: (context, index) {
        final episode = index + 1;
        return Padding(
          padding: const EdgeInsets.all(3),
          child: _EpisodeSquare(
            episode: episode,
            onTap: () {
              setState(() {
                _selectedEpisode = episode;
              });
              _playEpisode(episode);
            },
            isSelected: episode == _selectedEpisode,
          ),
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
                            Navigator.of(context).pushNamed(
                              '/video-player',
                              arguments: {
                                'tmdbId': tvShow.id.toString(),
                                'title': tvShow.name,
                                'type': 'tv',
                                'isTv': true,
                                'seasonNumber': _selectedSeason,
                                'episodeNumber': _selectedEpisode,
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
                      IconButton(
                        onPressed: _startDownload,
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

  const _EpisodeSquare({required this.episode, required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(episode.toString(),
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
