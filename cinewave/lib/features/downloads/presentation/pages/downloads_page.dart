import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_bloc.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_event.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_state.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/core/models/media_models.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Downloads', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocBuilder<DownloadBloc, DownloadState>(
        builder: (context, state) {
          if (state is DownloadsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DownloadsLoaded) {
            if (state.items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_for_offline_outlined, color: Colors.white24, size: 64),
                    SizedBox(height: 16),
                    Text('No downloads yet', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _DownloadTile(item: item);
              },
            );
          }
          if (state is DownloadError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox.shrink();
        },
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
                    Text(
                      item.title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.type == 'movie' ? 'Movie' : 'TV Show • S${item.season} E${item.episode}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    if (item.status == DownloadStatus.downloading) ...[
                      LinearProgressIndicator(
                        value: currentProgress,
                        backgroundColor: Colors.white12,
                        color: Colors.blueAccent,
                        minHeight: 4,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(currentProgress * 100).toInt()}%',
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 11),
                      ),
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
