import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/network/endpoints.dart';

class TVDetailRemoteDataSource {
  final ApiClient apiClient;

  TVDetailRemoteDataSource({required this.apiClient});

  Future<TVShow> getTvDetail(int tvId) async {
    final response =
        await apiClient.get(ApiEndpoints.tvDetail(tvId));
    return TVShow.fromJson(response.data);
  }
}