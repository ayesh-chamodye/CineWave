import 'package:flutter/material.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/shared/widgets/network_image.dart';

class SearchResultList extends StatelessWidget {
  static const double _tileWidth = 120;
  static const double _tileHeight = 175;

  final List<Movie> movies;
  final List<TVShow> tvShows;

  const SearchResultList({
    super.key,
    required this.movies,
    required this.tvShows,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      cacheExtent: 600,
      addAutomaticKeepAlives: true,
      children: [
        if (movies.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Movies',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              cacheExtent: 600,
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
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: NetworkImageWidget(
                            imageUrl: movie.posterUrl,
                            width: _tileWidth,
                            height: _tileHeight,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        if (tvShows.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'TV Shows',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
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
                    width: _tileWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: NetworkImageWidget(
                            imageUrl: tvShow.posterUrl,
                            width: _tileWidth,
                            height: _tileHeight,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tvShow.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        if (movies.isEmpty && tvShows.isEmpty)
          const Center(
            child: Text(
              'No results found',
              style: TextStyle(color: Colors.white70),
            ),
          ),
      ],
    );
  }
}
