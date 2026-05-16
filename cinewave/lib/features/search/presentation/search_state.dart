part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  /// Returns the best available list of movies for this state.
  List<Movie> get movies => const <Movie>[];

  /// Returns the best available list of TV shows for this state.
  List<TVShow> get tvShows => const <TVShow>[];

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();

  @override
  List<Object?> get props => [];
}

class SearchLoading extends SearchState {
  const SearchLoading();

  @override
  List<Object?> get props => [];
}

/// Single accumulated state — both branches merge their results here so
/// neither branch's results are lost when the other branch finishes first.
class SearchResultsLoaded extends SearchState {
  final String? query;
  @override
  final List<Movie> movies;
  @override
  final List<TVShow> tvShows;

  const SearchResultsLoaded({
    this.query,
    required this.movies,
    required this.tvShows,
  });

  @override
  List<Object?> get props => [query, movies, tvShows];
}

class SearchError extends SearchState {
  final String message;
  final String? query;

  const SearchError({required this.message, this.query});

  @override
  List<Object?> get props => [message, query];
}
