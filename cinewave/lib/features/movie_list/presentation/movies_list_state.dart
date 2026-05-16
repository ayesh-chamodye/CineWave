part of 'movies_list_bloc.dart';

abstract class MoviesListState extends Equatable {
  const MoviesListState();

  @override
  List<Object?> get props => [];
}

class MoviesListInitial extends MoviesListState {
  const MoviesListInitial();
}

class MoviesListLoading extends MoviesListState {
  const MoviesListLoading();
}

class MoviesListLoaded extends MoviesListState {
  final List<Movie> movies;
  final int page;
  final int totalPages;
  final bool hasReachedMax;

  const MoviesListLoaded({
    required this.movies,
    required this.page,
    required this.totalPages,
    this.hasReachedMax = false,
  });

  MoviesListLoaded copyWith({
    List<Movie>? movies,
    int? page,
    int? totalPages,
    bool? hasReachedMax,
  }) {
    return MoviesListLoaded(
      movies: movies ?? this.movies,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [movies, page, totalPages, hasReachedMax];
}

class MoviesListSearchLoaded extends MoviesListState {
  final List<Movie> movies;

  const MoviesListSearchLoaded({
    required this.movies,
  });

  @override
  List<Object?> get props => [movies];
}

class MoviesListError extends MoviesListState {
  final String message;

  const MoviesListError({required this.message});

  @override
  List<Object> get props => [message];
}
