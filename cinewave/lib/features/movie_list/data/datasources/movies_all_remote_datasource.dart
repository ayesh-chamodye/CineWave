import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/network/endpoints.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/models/api_page_result.dart';
import 'package:dio/dio.dart';

class MoviesAllRemoteDataSource {
  final ApiClient apiClient;

  MoviesAllRemoteDataSource({required this.apiClient});

  /// Returns a single page of movies.
  Future<ApiPageResult<Movie>> fetchPage(int page) async {
    final response = await apiClient.get(ApiEndpoints.moviesAll(page));
    return _parseResponse(response);
  }

  /// Searches movies by query string. Returns results as a single-page
  /// `ApiPageResult` with `totalPages` set to 1 (no pagination in search).
  Future<ApiPageResult<Movie>> searchMovies(String query) async {
    final response = await apiClient.get(ApiEndpoints.moviesSearch(query));
    return _parseResponse(response);
  }

  /// Shared JSON-parsing logic used by both `fetchPage` and `searchMovies`.
  ApiPageResult<Movie> _parseResponse(Response response) {
    final data = response.data as Map<String, dynamic>;

    final List<dynamic> jsonList =
        (data['movies'] as List<dynamic>?) ?? const <dynamic>[];
    final int currentPage = (data['page'] as int?) ?? 1;
    final int totalPages = (data['totalPages'] as int?) ?? 1;

    final movies = jsonList
        .cast<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .toList();

    return ApiPageResult(
      items: movies,
      page: currentPage,
      totalPages: totalPages,
    );
  }
}
