part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchMoviesLoaded extends SearchState {
  final List<Movie> movies;

  const SearchMoviesLoaded({required this.movies});

  @override
  List<Object> get props => [movies];
}

class SearchTvShowsLoaded extends SearchState {
  final List<TVShow> tvShows;

  const SearchTvShowsLoaded({required this.tvShows});

  @override
  List<Object> get props => [tvShows];
}

class SearchError extends SearchState {
  final String message;
  final String? query;

  const SearchError({required this.message, this.query});

  @override
  List<Object> get props => [message];
}