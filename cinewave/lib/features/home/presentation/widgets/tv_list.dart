import 'package:flutter/material.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/shared/widgets/network_image.dart';

class TVList extends StatelessWidget {
  final List<TVShow> tvShows;

  const TVList({super.key, required this.tvShows});

  @override
  Widget build(BuildContext context) {
    if (tvShows.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        cacheExtent: 600,
        addAutomaticKeepAlives: true,
        itemCount: tvShows.length,
        itemBuilder: (context, index) {
          final tvShow = tvShows[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/tv-detail',
                arguments: tvShow,
              );
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: NetworkImageWidget(
                          imageUrl: tvShow.posterUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tvShow.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}