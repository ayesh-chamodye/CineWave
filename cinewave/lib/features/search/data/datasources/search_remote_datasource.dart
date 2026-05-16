import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/network/endpoints.dart';

class SearchRemoteDataSource {
  final ApiClient apiClient;

  SearchRemoteDataSource({required this.apiClient});

  Future<List<dynamic>> searchMovies(String query) async {
    final response = await apiClient.get(
      ApiEndpoints.moviesSearch(query),
    );
    // API wraps results in a "results" key
    final results = response.data['results'] ?? response.data;
    return results is List<dynamic> ? results : <dynamic>[];
  }

  Future<List<dynamic>> searchTvShows(String query) async {
    final response = await apiClient.get(
      ApiEndpoints.tvSearch(query),
    );
    final results = response.data['results'] ?? response.data;
    return results is List<dynamic> ? results : <dynamic>[];
  }
}