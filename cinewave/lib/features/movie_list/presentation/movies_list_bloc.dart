import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cinewave/features/movie_list/data/repositories/movies_list_repository.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/models/api_page_result.dart';

part 'movies_list_event.dart';
part 'movies_list_state.dart';

class MoviesListBloc extends Bloc<MoviesListEvent, MoviesListState> {
  static const int _firstPage = 1;

  final MoviesListRepository _repository;
  final List<Movie> _allMovies = [];

  MoviesListBloc({required MoviesListRepository repository})
      : _repository = repository,
        super(const MoviesListInitial()) {
    on<LoadMoviesPage>(_onLoadMoviesPage);
    on<SearchMovies>(_onSearchMovies);
  }

  Future<void> _onLoadMoviesPage(
    LoadMoviesPage event,
    Emitter<MoviesListState> emit,
  ) async {
    if (event.page > _firstPage &&
        state is MoviesListLoaded &&
        (state as MoviesListLoaded).hasReachedMax) {
      return;
    }

    if (event.page == _firstPage) {
      emit(const MoviesListLoading());
      _allMovies.clear();
    }

    try {
      final ApiPageResult<Movie> result =
          await _repository.getMoviesPage(event.page);

      _allMovies.addAll(result.items);

      final hasReachedMax = result.page >= result.totalPages;

      emit(MoviesListLoaded(
        movies: List<Movie>.from(_allMovies),
        page: result.page,
        totalPages: result.totalPages,
        hasReachedMax: hasReachedMax,
      ));
    } catch (e) {
      emit(MoviesListError(message: e.toString()));
    }
  }

  Future<void> _onSearchMovies(
    SearchMovies event,
    Emitter<MoviesListState> emit,
  ) async {
    final trimmed = event.query.trim();
    if (trimmed.isEmpty) {
      // Restore to initial loading state — MoviesListPage will handle the
      // transition back to the default page-1 load.
      emit(const MoviesListLoading());
      return;
    }

    try {
      final ApiPageResult<Movie> result =
          await _repository.searchMovies(trimmed);

      emit(MoviesListSearchLoaded(movies: result.items));
    } catch (e) {
      emit(MoviesListError(message: e.toString()));
    }
  }
}
