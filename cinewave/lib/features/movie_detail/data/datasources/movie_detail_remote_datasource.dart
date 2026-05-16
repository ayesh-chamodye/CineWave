import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/network/endpoints.dart';

class MovieDetailRemoteDataSource {
  final ApiClient apiClient;

  MovieDetailRemoteDataSource({required this.apiClient});

  /// Fetches full movie detail by scraping the TMDB movie page.
  /// The `/api/scrape` endpoint fetches the TMDB URL, extracts all fields
  /// (title, poster, backdrop, overview, releaseDate, voteAverage, playerUrl)
  /// and returns clean JSON.
  Future<Movie> getMovieDetail(int movieId, {String? tmdbUrl}) async {
    final url = tmdbUrl ??
        'https://www.themoviedb.org/movie/$movieId';
    final response =
        await apiClient.get(ApiEndpoints.scrapeMovie(url));
    return Movie.fromJson(
      response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{},
    );
  }
}