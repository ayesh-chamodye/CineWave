import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/shared/widgets/network_image.dart';

class TVList extends StatelessWidget {
  static const double _tileWidth = 130;
  static const double _tileHeight = 190;

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
        scrollCacheExtent: ScrollCacheExtent.pixels(600), scrollDirection: Axis.horizontal,
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
              width: _tileWidth,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: tvShow.posterUrl.isNotEmpty
                          ? NetworkImageWidget(
                              imageUrl: tvShow.posterUrl,
                              width: _tileWidth,
                              height: _tileHeight,
                              fit: BoxFit.cover,
                            )
                          : const ColoredBox(
                              color: Color(0xFF1F1F1F),
                              child: Center(
                                child: Icon(
                                  Icons.live_tv,
                                  color: Colors.white38,
                                ),
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
