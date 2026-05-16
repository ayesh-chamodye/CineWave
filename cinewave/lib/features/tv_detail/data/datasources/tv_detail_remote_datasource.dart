import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/network/endpoints.dart';

class TVDetailRemoteDataSource {
  final ApiClient apiClient;

  TVDetailRemoteDataSource({required this.apiClient});

  /// Fetches full TV-show detail by scraping the TMDB TV page.
  Future<TVShow> getTvDetail(int tvId, {String? tmdbUrl}) async {
    final url = tmdbUrl ??
        'https://www.themoviedb.org/tv/$tvId';
    final response =
        await apiClient.get(ApiEndpoints.scrapeTV(url));
    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
    return TVShow.fromJson(data);
  }
}