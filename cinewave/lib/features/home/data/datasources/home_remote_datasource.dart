import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/network/endpoints.dart';

class HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSource({required this.apiClient});

  /// Calls `/api/home` and returns the raw payload so the BLoC can parse
  /// it however it needs.
  ///
  /// The response may be in one of the following formats:
  ///
  /// | Format | Example keys |
  /// |--------|---------------|
  /// | **New** | `movies`, `tvShows`, `trendingMovies` |
  /// | **Legacy** | `popular` (all items with a `mediaType` key), `trending` |
  ///
  /// Both formats are handled in `HomeBloc._onLoadHomeData`.
  Future<Map<String, dynamic>> getHomeData() async {
    final response = await apiClient.get(ApiEndpoints.home);
    return response.data as Map<String, dynamic>;
  }

  /// Calls `/api/movies/all?page=1` and returns the first five movies,
  /// or an empty list if the endpoint fails or returns no data.
  Future<List<dynamic>> getFirstFiveMoviesJson() async {
    try {
      final response =
          await apiClient.get(ApiEndpoints.moviesAll(1));
      final data = response.data as Map<String, dynamic>;
      final items =
          (data['movies'] as List<dynamic>?) ?? const <dynamic>[];
      return items.take(5).toList();
    } catch (_) {
      return const <dynamic>[];
    }
  }

  /// Calls `/api/tv/all?page=1` and returns the first five TV shows,
  /// or an empty list if the endpoint fails or returns no data.
  Future<List<dynamic>> getFirstFiveTvJson() async {
    try {
      final response =
          await apiClient.get(ApiEndpoints.tvAll(1));
      final data = response.data as Map<String, dynamic>;
      final items =
          (data['tvShows'] as List<dynamic>?) ?? const <dynamic>[];
      return items.take(5).toList();
    } catch (_) {
      return const <dynamic>[];
    }
  }
}
