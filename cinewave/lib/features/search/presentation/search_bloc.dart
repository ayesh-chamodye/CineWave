import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cinewave/features/search/data/repositories/search_repository.dart';
import 'package:cinewave/core/models/media_models.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository searchRepository;

  SearchBloc({required this.searchRepository}) : super(const SearchInitial()) {
    on<SearchMovies>(_onSearchMovies);
    on<SearchTvShows>(_onSearchTvShows);
  }

  Future<void> _onSearchMovies(
      SearchMovies event, Emitter<SearchState> emit) async {
    emit(const SearchLoading());
    try {
      final List<Movie> movies =
          await searchRepository.searchMovies(event.query);
      // Merge with any already-loaded TV results
      final prev = state;
      emit(SearchResultsLoaded(
        query: event.query,
        movies: movies,
        tvShows: prev is SearchResultsLoaded ? prev.tvShows : const [],
      ));
    } catch (e) {
      emit(SearchError(message: e.toString(), query: event.query));
    }
  }

  Future<void> _onSearchTvShows(
      SearchTvShows event, Emitter<SearchState> emit) async {
    emit(const SearchLoading());
    try {
      final List<TVShow> tvShows =
          await searchRepository.searchTvShows(event.query);
      // Merge with any already-loaded movie results
      final prev = state;
      emit(SearchResultsLoaded(
        query: event.query,
        movies: prev is SearchResultsLoaded ? prev.movies : const [],
        tvShows: tvShows,
      ));
    } catch (e) {
      emit(SearchError(message: e.toString(), query: event.query));
    }
  }
}
