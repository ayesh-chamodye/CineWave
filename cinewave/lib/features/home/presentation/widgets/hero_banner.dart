import 'package:flutter/material.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/shared/widgets/network_image.dart';

class HeroBanner extends StatelessWidget {
  final dynamic featuredItem; // Can be Movie or TVShow
  final double height;

  const HeroBanner({
    super.key,
    required this.featuredItem,
    this.height = 450,
  });

  String get _title {
    if (featuredItem is Movie) return featuredItem.title;
    if (featuredItem is TVShow) return featuredItem.name;
    return 'Unknown';
  }

  String? get _backdropUrl => featuredItem.backdropUrl;
  String? get _posterUrl => featuredItem.posterUrl;
  String get _description {
    if (featuredItem is Movie) return featuredItem.overview ?? '';
    if (featuredItem is TVShow) return featuredItem.overview ?? '';
    return '';
  }

  int get _year {
    final dateStr = featuredItem is Movie
        ? featuredItem.releaseDate
        : featuredItem.firstAirDate;
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        return int.parse(dateStr.split('-')[0]);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  double get _rating => featuredItem.voteAverage ?? 0.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: NetworkImageWidget(
              imageUrl: _backdropUrl ?? _posterUrl ?? '',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlays
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(48, 0, 48, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Meta info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF46D369), width: 1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          '${(_rating * 10).toInt()}% Match',
                          style: const TextStyle(
                            color: Color(0xFF46D369),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _year > 0 ? _year.toString() : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  if (_description.isNotEmpty)
                    Text(
                      _description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.play_arrow,
                        label: 'Play',
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        onPressed: () {
                          // Handle play action
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.info_outline,
                        label: 'More Info',
                        backgroundColor: Colors.grey.withValues(alpha: 0.5),
                        textColor: Colors.white,
                        onPressed: () {
                          // Navigate to detail page
                          if (featuredItem is Movie) {
                            Navigator.of(context).pushNamed(
                              '/movie-detail',
                              arguments: featuredItem,
                            );
                          } else if (featuredItem is TVShow) {
                            Navigator.of(context).pushNamed(
                              '/tv-detail',
                              arguments: featuredItem,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
