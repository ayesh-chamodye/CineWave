import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/network/endpoints.dart';

class SearchRemoteDataSource {
  final ApiClient apiClient;

  SearchRemoteDataSource({required this.apiClient});

  Future<List<dynamic>> searchMovies(String query) async {
    final response = await apiClient.get(
      ApiEndpoints.moviesSearch(query),
    );
    return response.data;
  }

  Future<List<dynamic>> searchTvShows(String query) async {
    final response = await apiClient.get(
      ApiEndpoints.tvSearch(query),
    );
    return response.data;
  }
}