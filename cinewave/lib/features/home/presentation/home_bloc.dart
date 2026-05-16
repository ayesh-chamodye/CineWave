import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cinewave/features/home/data/repositories/home_repository.dart';
import 'package:cinewave/core/models/media_models.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Reads the `popular` array produced by the legacy `/api/home` endpoint
/// and returns only items whose `mediaType` matches [type].
///
/// Returns `null` when `popular` is absent or not a list.
List<dynamic>? _extractFromPopular(
    Map<String, dynamic> data, String type) {
  final popular = data['popular'];
  if (popular is! List) return null;
  final lowerType = type.toLowerCase();
  return popular.where((item) =>
      item is Map &&
      (item['mediaType'] ?? '').toString().toLowerCase() == lowerType
  ).toList();
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final Map<String, dynamic> data = await homeRepository.getHomeData();

      // ── Movies & TV ─────────────────────────────────────────────────────
      // The data source returns the raw response.  The backend may produce
      // either of two formats:
      //
      // 1. New:  { movies: [...], tvShows: [...], trendingMovies: [...] }
      // 2. Old:  { popular: [{ mediaType:"movie"|"tv", ... }, ...],
      //            trending:   [...] }
      //
      // We read `movies`/`tvShows` first (new format) and fall back to
      // scanning `popular` for the matching `mediaType`.
      final List<dynamic> moviesJson =
          (data['movies'] as List<dynamic>?) ??
          _extractFromPopular(data, 'movie') ??
          const <dynamic>[];
      final List<dynamic> tvShowsJson =
          (data['tvShows'] as List<dynamic>?) ??
          _extractFromPopular(data, 'tv') ??
          const <dynamic>[];

      final List<Movie> movies =
          moviesJson.map((json) => Movie.fromJson(json)).toList();
      final List<TVShow> tvShows =
          tvShowsJson.map((json) => TVShow.fromJson(json)).toList();

      // ── Featured ────────────────────────────────────────────────────────
      Movie? featuredMovie;
      TVShow? featuredTVShow;

      if (movies.isNotEmpty) {
        featuredMovie = movies.reduce((a, b) => a.voteAverage > b.voteAverage ? a : b);
      } else if (tvShows.isNotEmpty) {
        featuredTVShow = tvShows.reduce((a, b) => a.voteAverage > b.voteAverage ? a : b);
      }

      // ── Trending ────────────────────────────────────────────────────────
      // The server supplies this in live order under "trending".
      // Support both "trending" (current name) and "trendingMovies" (old name).
      List<Movie>? trendingMovies;
      final rawTrending = data['trending'] ?? data['trendingMovies'];
      if (rawTrending is List && rawTrending.isNotEmpty) {
        trendingMovies = rawTrending
            .cast<Map<String, dynamic>>()
            .map(Movie.fromJson)
            .where((m) => m.id != 0)
            .toList();
      } else if (movies.length >= 5) {
        final sorted = List<Movie>.from(movies);
        sorted.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
        trendingMovies = sorted.length > 10 ? sorted.sublist(0, 10) : sorted;
      }

      emit(HomeLoaded(
        movies: movies,
        tvShows: tvShows,
        featuredMovie: featuredMovie,
        featuredTVShow: featuredTVShow,
        trendingMovies: trendingMovies,
      ));
    } catch (e) {
      emit(HomeError(message: 'Failed to load home data: ${e.toString()}'));
    }
  }
}
