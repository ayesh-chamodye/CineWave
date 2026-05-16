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
  /// | **Legacy** | `popular` (all items with a `mediaType` field), `trending` |
  ///
  /// Both formats are handled in `HomeBloc._onLoadHomeData`.
  Future<Map<String, dynamic>> getHomeData() async {
    final response = await apiClient.get(ApiEndpoints.home);
    return response.data as Map<String, dynamic>;
  }
}
