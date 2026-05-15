import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/network/endpoints.dart';

class HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> getHomeData() async {
    final response = await apiClient.get(ApiEndpoints.home);
    return response.data;
  }
}