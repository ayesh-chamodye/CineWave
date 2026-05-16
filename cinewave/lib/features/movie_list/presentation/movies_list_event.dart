part of 'movies_list_bloc.dart';

abstract class MoviesListEvent extends Equatable {
  const MoviesListEvent();

  @override
  List<Object> get props => [];
}

class LoadMoviesPage extends MoviesListEvent {
  final int page;

  const LoadMoviesPage(this.page);

  @override
  List<Object> get props => [page];
}

class SearchMovies extends MoviesListEvent {
  final String query;

  const SearchMovies(this.query);

  @override
  List<Object> get props => [query];
}
