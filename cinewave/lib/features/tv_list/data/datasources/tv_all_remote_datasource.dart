import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/network/endpoints.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/models/api_page_result.dart';
import 'package:dio/dio.dart';

class TVAllRemoteDataSource {
  final ApiClient apiClient;

  TVAllRemoteDataSource({required this.apiClient});

  Future<ApiPageResult<TVShow>> fetchPage(int page) async {
    final response = await apiClient.get(ApiEndpoints.tvAll(page));
    return _parseResponse(response);
  }

  Future<ApiPageResult<TVShow>> searchTvShows(String query) async {
    final response = await apiClient.get(ApiEndpoints.tvSearch(query));
    return _parseResponse(response);
  }

  ApiPageResult<TVShow> _parseResponse(Response response) {
    final data = response.data as Map<String, dynamic>;

    final List<dynamic> jsonList =
        (data['results'] as List<dynamic>?) ??
        (data['tvShows'] as List<dynamic>?) ??
        const <dynamic>[];
    final int currentPage = (data['page'] as int?) ?? 1;
    final int totalPages = (data['totalPages'] as int?) ?? 1;

    final tvShows = jsonList
        .cast<Map<String, dynamic>>()
        .map(TVShow.fromJson)
        .toList();

    return ApiPageResult(
      items: tvShows,
      page: currentPage,
      totalPages: totalPages,
    );
  }
}
