import 'package:dio/dio.dart';
import 'package:cinewave/core/network/endpoints.dart';

class ApiClient {
  static const connectTimeout = Duration(minutes: 5);
  static const receiveTimeout = Duration(minutes: 5);
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
  ));

  /// Performs a GET request returning the response body as a Map.
  ///
  /// Detects GitHub Codespace gateway HTML responses before they reach the
  /// normal data layer so callers get a clear error instead of a silent JSON
  /// parse failure.
  Future<Map<String, dynamic>> getAsMap(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    final response = await get(endpoint, queryParameters: queryParameters);
    if (response is Map<String, dynamic>) return response as Map<String, dynamic>;

    // GitHub Codespace port-forward gateway returns a small HTML page.
    final body = response.toString();
    if (body.contains('<!doctype html>')) {
      throw Exception(
        'API returned HTML instead of JSON for $endpoint. '
        'The backend may not be running at ${ApiEndpoints.baseUrl}.',
      );
    }

    throw Exception('Unexpected response type from $endpoint');
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final Response response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw Exception('Network error calling $endpoint: ${e.message}');
    } catch (e) {
      throw Exception('Failed to call $endpoint: $e');
    }
  }
}