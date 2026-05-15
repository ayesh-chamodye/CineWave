import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cinewave/features/search/data/repositories/search_repository.dart';
import 'package:cinewave/core/models/media_models.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository searchRepository;

  SearchBloc({required this.searchRepository}) : super(SearchInitial()) {
    on<SearchMovies>(_onSearchMovies);
    on<SearchTvShows>(_onSearchTvShows);
  }

  Future<void> _onSearchMovies(
      SearchMovies event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      final List<Movie> movies =
          await searchRepository.searchMovies(event.query);
      emit(SearchMoviesLoaded(movies: movies));
    } catch (e) {
      emit(SearchError(message: e.toString(), query: event.query));
    }
  }

  Future<void> _onSearchTvShows(
      SearchTvShows event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      final List<TVShow> tvShows =
          await searchRepository.searchTvShows(event.query);
      emit(SearchTvShowsLoaded(tvShows: tvShows));
    } catch (e) {
      emit(SearchError(message: e.toString(), query: event.query));
    }
  }
}