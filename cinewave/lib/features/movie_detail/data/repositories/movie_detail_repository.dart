import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/features/movie_detail/data/datasources/movie_detail_remote_datasource.dart';

class MovieDetailRepository {
  final MovieDetailRemoteDataSource movieDetailRemoteDataSource;

  MovieDetailRepository({required this.movieDetailRemoteDataSource});

  Future<Movie> getMovieDetail(int movieId) async {
    return await movieDetailRemoteDataSource.getMovieDetail(movieId);
  }
}