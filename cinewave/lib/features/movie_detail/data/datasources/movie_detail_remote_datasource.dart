import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/network/endpoints.dart';

class MovieDetailRemoteDataSource {
  final ApiClient apiClient;

  MovieDetailRemoteDataSource({required this.apiClient});

  Future<Movie> getMovieDetail(int movieId) async {
    final response =
        await apiClient.get(ApiEndpoints.movieDetail(movieId));
    return Movie.fromJson(response.data);
  }
}