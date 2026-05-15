part of 'movie_detail_bloc.dart';

abstract class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadMovieDetail extends MovieDetailEvent {
  final Movie movie;

  const LoadMovieDetail({required this.movie});

  @override
  List<Object> get props => [movie];
}