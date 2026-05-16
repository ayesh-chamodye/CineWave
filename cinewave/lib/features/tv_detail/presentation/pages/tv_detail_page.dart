import 'package:flutter/material.dart';
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
  int? _tmdbId;
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
        _tmdbId = raw.id;
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
          cacheExtent: 2000,
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
                            // ── 30-episode list ──────────────────────────────────
                            _buildEpisodeList(),
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

  /// Builds a [Row] containing ◀ arrow, a scrollable season chip strip, and ▶ arrow.
  Widget _buildSeasonStrip(BuildContext context) {
    final seasons = List.generate(5, (i) => _season + i);

    return Row(
      children: [
        // ◀
        IconButton(
          onPressed: _season > 1 ? () => setState(() => _season--) : null,
          icon: const Icon(Icons.chevron_left, color: Colors.white54),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        // Season chips
        Expanded(
          child: SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: seasons.length,
              itemBuilder: (context, index) {
                final s = seasons[index];
                final active = s == _season;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('S$s'),
                    selected: active,
                    onSelected: (_) => setState(() => _season = s),
                    labelStyle: TextStyle(
                      color: active ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.white10,
                    selectedColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          ),
        ),
        // ▶
        IconButton(
          onPressed: () => setState(() => _season++),
          icon: const Icon(Icons.chevron_right, color: Colors.white54),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }

  /// Builds a scrollable vertical list of 30 episode cards.
  Widget _buildEpisodeList() {
    final tmdbId = _tmdbId;
    if (tmdbId == null) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 30,
      itemBuilder: (context, index) {
        final episode = index + 1;
        return _EpisodeCard(
          episode: episode,
          onTap: () => _playEpisode(episode),
        );
      },
    );
  }
}

const _kCardH = 90.0;
const _kCardThumbW = 132.0;
const _kCardGap = 12.0;

class _EpisodeCard extends StatelessWidget {
  final int episode;
  final VoidCallback onTap;

  const _EpisodeCard({required this.episode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _kCardGap),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            height: _kCardH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF1F1F1F),
            ),
            child: Row(
              children: [
                // Thumbnail placeholder
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  child: Container(
                    width: _kCardThumbW,
                    color: const Color(0xFF2A2A2A),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white.withValues(alpha: 0.35),
                              size: 24,
                            ),
                          ),
                        ),
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black38],
                                stops: [0.45, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 1),
                // Episode number + play button
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Episode $episode',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Material(
                          color: Colors.white10,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onTap,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(Icons.play_arrow,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
