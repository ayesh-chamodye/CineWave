import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/features/search/data/datasources/search_remote_datasource.dart';

class SearchRepository {
  final SearchRemoteDataSource searchRemoteDataSource;

  SearchRepository({required this.searchRemoteDataSource});

  Future<List<Movie>> searchMovies(String query) async {
    final List<dynamic> jsonList = await searchRemoteDataSource.searchMovies(query);
    return jsonList.map((json) => Movie.fromJson(json)).toList();
  }

  Future<List<TVShow>> searchTvShows(String query) async {
    final List<dynamic> jsonList = await searchRemoteDataSource.searchTvShows(query);
    return jsonList.map((json) => TVShow.fromJson(json)).toList();
  }
}