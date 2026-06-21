import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/library/presentation/bloc/library_bloc.dart';
import 'package:cinewave/features/library/presentation/bloc/library_event.dart';
import 'package:cinewave/features/library/presentation/bloc/library_state.dart';
import 'package:cinewave/core/models/library_models.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/core/ads/ad_service.dart';

import 'package:cinewave/core/models/media_models.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(LoadLibrary());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Library', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white70),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1A),
                  title: const Text('Clear History?', style: TextStyle(color: Colors.white)),
                  content: const Text('This will remove all items from your watch history.',
                      style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<LibraryBloc>().add(ClearHistory());
                        Navigator.pop(context);
                      },
                      child: const Text('CLEAR', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LibraryLoaded) {
            final continuing = state.history.where((item) => !item.isCompleted).toList();
            final watched = state.history.where((item) => item.isCompleted).toList();
            final favorites = state.favorites;

            if (continuing.isEmpty && watched.isEmpty && favorites.isEmpty) {
              return _buildEmptyState();
            }

            return CustomScrollView(
              slivers: [
                if (continuing.isNotEmpty)
                  _buildSectionTitle('Continue Watching'),
                if (continuing.isNotEmpty)
                  _buildHorizontalHistoryList(continuing),
                
                if (favorites.isNotEmpty)
                  _buildSectionTitle('My Favorites'),
                if (favorites.isNotEmpty)
                  _buildHorizontalFavoritesList(favorites),

                if (watched.isNotEmpty)
                  _buildSectionTitle('Watched Recently'),
                if (watched.isNotEmpty)
                  _buildVerticalHistoryList(watched),
                
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          } else if (state is LibraryError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          const Text('Your library is empty', style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Movies and shows you watch will appear here.', style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHorizontalHistoryList(List<WatchHistoryItem> items) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _ContinueWatchingCard(item: item);
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalFavoritesList(List<FavoriteItem> items) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _FavoriteCard(item: item);
          },
        ),
      ),
    );
  }

  Widget _buildVerticalHistoryList(List<WatchHistoryItem> items) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return _HistoryTile(item: item);
        },
        childCount: items.length,
      ),
    );
  }
}

class _ContinueWatchingCard extends StatelessWidget {
  final WatchHistoryItem item;
  const _ContinueWatchingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AdService().showRewardedInterstitialAd(() {
          Navigator.of(context).pushNamed(
            '/video-player',
            arguments: {
              'tmdbId': item.mediaId,
              'title': item.title,
              'type': item.type,
              'isTv': item.type == 'tv',
              'seasonNumber': item.season,
              'episodeNumber': item.episode,
            },
          );
        });
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWidget(
                      imageUrl: item.posterUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      color: Colors.white24,
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomLeft,
                        widthFactor: item.progress.clamp(0.0, 1.0),
                        child: Container(color: Colors.red),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.play_circle_outline, color: Colors.white, size: 48),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.type == 'tv')
              Text(
                'S${item.season} E${item.episode}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteItem item;
  const _FavoriteCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AdService().showRewardedInterstitialAd(() {
          // If it's a TV show, we might want to check the history for the last watched episode
          // or just default to S1E1.
          int? season = 1;
          int? episode = 1;

          final libraryState = context.read<LibraryBloc>().state;
          if (libraryState is LibraryLoaded) {
            final history = libraryState.history
                .where((h) => h.mediaId == item.mediaId)
                .toList();
            if (history.isNotEmpty) {
              history.sort((a, b) => b.lastWatched.compareTo(a.lastWatched));
              season = history.first.season;
              episode = history.first.episode;
            }
          }

          Navigator.of(context).pushNamed(
            '/video-player',
            arguments: {
              'tmdbId': item.mediaId,
              'title': item.title,
              'type': item.type,
              'isTv': item.type == 'tv',
              'seasonNumber': item.type == 'tv' ? season : null,
              'episodeNumber': item.type == 'tv' ? episode : null,
              'posterUrl': item.posterUrl,
            },
          );
        });
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: NetworkImageWidget(
            imageUrl: item.posterUrl ?? '',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final WatchHistoryItem item;
  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: NetworkImageWidget(
          imageUrl: item.posterUrl ?? '',
          width: 50,
          height: 75,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(item.title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        item.type == 'tv' ? 'TV Show • S${item.season} E${item.episode}' : 'Movie',
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.white24),
        onPressed: () {
          context.read<LibraryBloc>().add(DeleteHistoryItem(item.id));
        },
      ),
      onTap: () {
         AdService().showRewardedInterstitialAd(() {
          Navigator.of(context).pushNamed(
            '/video-player',
            arguments: {
              'tmdbId': item.mediaId,
              'title': item.title,
              'type': item.type,
              'isTv': item.type == 'tv',
              'seasonNumber': item.season,
              'episodeNumber': item.episode,
            },
          );
        });
      },
    );
  }
}
