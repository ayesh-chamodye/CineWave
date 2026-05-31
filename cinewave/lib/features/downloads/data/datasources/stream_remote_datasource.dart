import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/network/endpoints.dart';

class StreamRemoteDataSource {
  final ApiClient apiClient;

  StreamRemoteDataSource({required this.apiClient});

  Future<Vyla> getStreamLinks(int tmdbId, String type,
      {int? season, int? episode}) async {
    final endpoint = ApiEndpoints.stream(tmdbId, type,
        season: season, episode: episode);
    final response = await apiClient.getAsMap(endpoint);
    return Vyla.fromJson(response);
  }
}
