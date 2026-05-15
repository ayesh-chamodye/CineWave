import 'package:dio/dio.dart';
import 'package:cinewave/core/network/endpoints.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final Response response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
}