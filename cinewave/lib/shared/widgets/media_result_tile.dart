import 'package:flutter/material.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/shared/widgets/network_image.dart';

class MediaResultTile extends StatelessWidget {
  final Movie? movie;
  final TVShow? tvShow;
  final VoidCallback? onTap;

  const MediaResultTile.movie({
    super.key,
    required this.movie,
    this.onTap,
  }) : tvShow = null;

  const MediaResultTile.tv({
    super.key,
    required this.tvShow,
    this.onTap,
  }) : movie = null;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie?.posterUrl ?? tvShow?.posterUrl ?? '';
    final title = movie?.title ?? tvShow?.name ?? 'Unknown';
    final typeLabel = movie != null ? 'Movie' : 'TV Show';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: NetworkImageWidget(
                      imageUrl: posterUrl,
                      width: 120,
                      height: 175,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        typeLabel,
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
