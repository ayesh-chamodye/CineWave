import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/shared/widgets/network_image.dart';

class MovieList extends StatelessWidget {
  static const double _tileWidth = 130;
  static const double _tileHeight = 190;

  final List<Movie> movies;

  const MovieList({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollCacheExtent: ScrollCacheExtent.pixels(600), scrollDirection: Axis.horizontal,
        addAutomaticKeepAlives: true,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/movie-detail',
                arguments: movie,
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
                      child: NetworkImageWidget(
                        imageUrl: movie.posterUrl,
                        width: _tileWidth,
                        height: _tileHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.title,
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