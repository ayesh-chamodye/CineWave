import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/tv_detail/presentation/tv_detail_bloc.dart';
import 'package:cinewave/features/tv_detail/data/repositories/tv_detail_repository.dart';
import 'package:cinewave/features/tv_detail/presentation/widgets/detail_info.dart';
import 'package:cinewave/shared/widgets/landscape_video_player.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/core/models/media_models.dart';

class TVDetailPage extends StatefulWidget {
  static const String routeName = '/tv-detail';

  const TVDetailPage({super.key});

  @override
  State<TVDetailPage> createState() => _TVDetailPageState();
}

class _TVDetailPageState extends State<TVDetailPage> {
  TVShow? _tvShow;
  String _playerUrl = '';
  String? _videoUrl;
  bool _tvParseOk = false;
  int _season = 1;
  int _episode = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final raw = ModalRoute.of(context)?.settings.arguments as TVShow?;
      if (raw == null) return;
      setState(() {
        _tvShow = raw;
        _playerUrl = raw.playerUrl;
        _videoUrl = raw.videoUrl;
      });
      _parseEmbedUrl(raw);
    });
  }

  void _parseEmbedUrl(TVShow show) {
    final raw = show.playerUrl.isNotEmpty ? show.playerUrl : (show.videoUrl ?? '');
    if (raw.isEmpty) return;
    try {
      final segs = Uri.parse(raw).pathSegments;
      if (segs.length >= 4 && segs[0] == 'tv') {
        setState(() {
          _season = int.tryParse(segs[2]) ?? 1;
          _episode = int.tryParse(segs[3]) ?? 1;
          _tvParseOk = true;
        });
      }
    } catch (_) {}
  }

  void _onSeasonSelected(int season) {
    setState(() {
      _season = season;
      _episode = 1; // reset to first episode when season changes
    });
  }

  int get _episodeCountForCurrentSeason {
    final seasons = _tvShow?.seasons;
    if (seasons == null || seasons.isEmpty) return 0;
    for (final s in seasons) {
      if (s.seasonNumber == _season) return s.episodeCount;
    }
    return 0;
  }

  /// Called by `_EpisodeCard` to open the player for a specific episode.
  void _playEpisode(int episode) {
    if (episode < 1) return;
    final epUrl = _playerUrl.replaceAll(
      RegExp(r'/\d+/\d+$'),
      '/$_season/$episode',
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LandscapeVideoPlayerPage(
          videoUrl: epUrl,
          isTv: true,
          seasonNumber: _season,
          episodeNumber: episode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TVShow tvShow =
        _tvShow ?? (ModalRoute.of(context)!.settings.arguments as TVShow);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: BlocProvider(
        create: (_) => TVDetailBloc(
          tvDetailRepository: context.read<TVDetailRepository>(),
        )..add(LoadTVDetail(tvShow: tvShow)),
        child: CustomScrollView(
          scrollCacheExtent: ScrollCacheExtent.pixels(2000), slivers: [
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
                  // ── Play + action buttons ───────────────────────────────────
                  if (_playerUrl.isNotEmpty ||
                      (_videoUrl != null && _videoUrl!.isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _playEpisode(_episode),
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
                            onPressed: () {},
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white38),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.bookmark_border, color: Colors.white70),
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
                  const SizedBox(height: 16),
                  // ── Season strip + episode cards ─────────────────────────────
                  if (_tvParseOk)
                    Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top:
                                BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                            bottom:
                                BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Episodes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // ── Season strip ─────────────────────────────────────
                            _buildSeasonStrip(context),
                            const SizedBox(height: 16),
                            // ── Episode numbers in small squares ──────────────────
                            _buildEpisodeGrid(),
                          ],
                        )),
                  const SizedBox(height: 8),
                  DetailInfoWidget(tvShow: tvShow),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Episodes helpers ─────────────────────────────────────────────────────────

  /// Builds a horizontally-scrolling strip of season chips for every season
  /// returned by the TMDB scrape.  Arrow buttons are omitted so the list
  /// scrolls naturally when there are more seasons than fit on screen.
  Widget _buildSeasonStrip(BuildContext context) {
    final seasons = _tvShow?.seasons;
    if (seasons == null || seasons.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: seasons.length,
        itemBuilder: (context, index) {
          final s = seasons[index];
          final active = s.seasonNumber == _season;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(s.name),
              selected: active,
              onSelected: (_) => _onSeasonSelected(s.seasonNumber),
              labelStyle: TextStyle(
                color: active ? Colors.black : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: Colors.white10,
              selectedColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: active ? Colors.white : Colors.white10,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds a wrapped grid of small episode-number squares, one per episode
  /// in the currently selected season (as reported by the TMDB scrape API).
  Widget _buildEpisodeGrid() {
    if (_tvShow == null) return const SizedBox.shrink();

    final episodeCount = _episodeCountForCurrentSeason;
    if (episodeCount <= 0) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: episodeCount,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
      itemBuilder: (context, index) {
        final episode = index + 1;
        return Padding(
          padding: const EdgeInsets.all(3),
          child: _EpisodeSquare(
            episode: episode,
            onTap: () => _playEpisode(episode),
            isSelected: episode == _episode,
          ),
        );
      },
    );
  }
}

class _EpisodeSquare extends StatelessWidget {
  final int episode;
  final VoidCallback onTap;
  final bool isSelected;

  const _EpisodeSquare({
    required this.episode,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: isSelected
            ? Theme.of(context).primaryColor
            : const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Text(
              '$episode',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
