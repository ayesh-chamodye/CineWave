import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cinewave/features/movie_detail/data/repositories/movie_detail_repository.dart';
import 'package:cinewave/core/models/media_models.dart';

part 'movie_detail_event.dart';
part 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final MovieDetailRepository movieDetailRepository;

  MovieDetailBloc({required this.movieDetailRepository})
      : super(MovieDetailInitial()) {
    on<LoadMovieDetail>(_onLoadMovieDetail);
  }

  Future<void> _onLoadMovieDetail(
      LoadMovieDetail event, Emitter<MovieDetailState> emit) async {
    emit(MovieDetailLoading());
    try {
      final Movie movieDetail = await movieDetailRepository
          .getMovieDetail(event.movie.id, tmdbUrl: event.movie.tmdbUrl);
      emit(MovieDetailLoaded(movie: movieDetail));
    } catch (e) {
      emit(MovieDetailError(message: e.toString()));
    }
  }
}