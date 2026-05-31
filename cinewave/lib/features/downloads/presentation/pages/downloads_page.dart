import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_bloc.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_event.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_state.dart';
import 'package:cinewave/features/downloads/presentation/widgets/season_episode_picker_dialog.dart';
import 'package:cinewave/shared/widgets/source_selection_dialog.dart';
import 'package:cinewave/shared/widgets/media_result_tile.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/features/search/presentation/search_bloc.dart';
import 'package:cinewave/core/models/media_models.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  void _onMovieTap(Movie movie) {
    final embedUrl = 'https://play.xpass.top/e/movie/${movie.id}';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => SourceSelectionDialog(
        title: movie.title,
        embedUrl: embedUrl,
        onUrlResolved: (url) {
          context.read<DownloadBloc>().add(StartDownload(movie: movie, url: url));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download started')),
          );
        },
      ),
    );
  }

  Future<void> _onTvTap(TVShow tvShow) async {
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (dialogContext) => SeasonEpisodePickerDialog(
        tvShow: tvShow,
        onSeasonChanged: (_) {},
      ),
    );
    if (result == null) return;
    if (!mounted) return;
    final season = result['season']!;
    final episode = result['episode']!;
    if (!mounted) return;
    final embedUrl = 'https://play.xpass.top/e/tv/${tvShow.id}/$season/$episode';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SourceSelectionDialog(
        title: '${tvShow.name} S${season.toString().padLeft(2, '0')}E${episode.toString().padLeft(2, '0')}',
        embedUrl: embedUrl,
        onUrlResolved: (url) {
          context.read<DownloadBloc>().add(
                StartDownload(tvShow: tvShow, season: season, episode: episode, url: url),
              );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download started')),
          );
        },
      ),
    );
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    context.read<SearchBloc>().add(SearchMovies(query: query));
    context.read<SearchBloc>().add(SearchTvShows(query: query));
    setState(() => _showSearch = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Downloads', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        hintText: 'Search for movies or TV shows...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(_showSearch ? Icons.close : Icons.search, color: Colors.white),
                    onPressed: () {
                      setState(() => _showSearch = !_showSearch);
                      if (_showSearch) {
                        _performSearch();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<SearchBloc, SearchState>(
              bloc: _showSearch ? context.read<SearchBloc>() : null,
              builder: (context, searchState) {
                if (!_showSearch) return const SizedBox.shrink();
                if (searchState is SearchLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (searchState is SearchResultsLoaded) {
                  final movies = searchState.movies;
                  final tvShows = searchState.tvShows;
                  if (movies.isEmpty && tvShows.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('No results found',
                            style: TextStyle(color: Colors.white54, fontSize: 16)),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (movies.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('Movies',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movies.length,
                            itemBuilder: (context, index) {
                              final movie = movies[index];
                              return MediaResultTile.movie(movie: movie, onTap: () => _onMovieTap(movie));
                            },
                          ),
                        ),
                      ],
                      if (tvShows.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('TV Shows',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: tvShows.length,
                            itemBuilder: (context, index) {
                              final tvShow = tvShows[index];
                              return MediaResultTile.tv(tvShow: tvShow, onTap: () => _onTvTap(tvShow));
                            },
                          ),
                        ),
                      ],
                    ],
                  );
                }
                if (searchState is SearchError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(searchState.message,
                          style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<DownloadBloc, DownloadState>(
              builder: (context, state) {
                if (state is DownloadsLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is DownloadsLoaded) {
                  if (state.items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _showSearch ? Icons.search_off_rounded : Icons.download_for_offline_outlined,
                              color: Colors.white24,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showSearch ? 'No downloads yet. Search above to start.' : 'No downloads yet',
                              style: const TextStyle(color: Colors.white54, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text('Your Downloads',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ...state.items.map((item) => _DownloadTile(item: item)),
                    ],
                  );
                }
                if (state is DownloadError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: Text(state.message, style: const TextStyle(color: Colors.red))),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  final DownloadItem item;

  const _DownloadTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadBloc, DownloadState>(
      builder: (context, state) {
        double currentProgress = 0;
        if (item.status == DownloadStatus.downloading) {
          currentProgress = context.read<DownloadBloc>().getProgress(item.id);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: NetworkImageWidget(
                  imageUrl: item.posterUrl,
                  width: 80,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(item.type == 'movie' ? 'Movie' : 'TV Show • S${item.season} E${item.episode}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 12),
                    if (item.status == DownloadStatus.downloading) ...[
                      LinearProgressIndicator(value: currentProgress, backgroundColor: Colors.white12, color: Colors.blueAccent, minHeight: 4),
                      const SizedBox(height: 4),
                      Text('${(currentProgress * 100).toInt()}%', style: const TextStyle(color: Colors.blueAccent, fontSize: 11)),
                    ] else
                      _buildStatus(context),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
                onPressed: () {
                  context.read<DownloadBloc>().add(DeleteDownload(item.id));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatus(BuildContext context) {
    switch (item.status) {
      case DownloadStatus.completed:
        return Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF46D369), size: 16),
            const SizedBox(width: 8),
            const Text('Completed', style: TextStyle(color: Color(0xFF46D369), fontSize: 13)),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/video-player',
                  arguments: {
                    'title': item.title,
                    'videoUrl': item.filePath,
                    'isLocal': true,
                  },
                );
              },
              child: const Text('PLAY', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      case DownloadStatus.error:
        return const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
            SizedBox(width: 8),
            Text('Error', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
          ],
        );
      default:
        return const Text('Queued', style: TextStyle(color: Colors.white38, fontSize: 13));
    }
  }
}
