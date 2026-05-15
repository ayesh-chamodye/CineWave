part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Movie> movies;
  final List<TVShow> tvShows;
  final Movie? featuredMovie;
  final TVShow? featuredTVShow;
  final List<Movie>? trendingMovies;

  const HomeLoaded({
    required this.movies,
    required this.tvShows,
    this.featuredMovie,
    this.featuredTVShow,
    this.trendingMovies,
  });

  @override
  List<Object?> get props => [movies, tvShows, featuredMovie, featuredTVShow, trendingMovies];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}