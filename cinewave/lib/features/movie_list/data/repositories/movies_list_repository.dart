import 'package:cinewave/features/movie_list/data/datasources/movies_all_remote_datasource.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/models/api_page_result.dart';

class MoviesListRepository {
  final MoviesAllRemoteDataSource remoteDataSource;

  MoviesListRepository({required this.remoteDataSource});

  Future<ApiPageResult<Movie>> getMoviesPage(int page) async {
    return await remoteDataSource.fetchPage(page);
  }

  /// Returns search results for a given query string as a single-page result.
  Future<ApiPageResult<Movie>> searchMovies(String query) async {
    return await remoteDataSource.searchMovies(query);
  }
}
