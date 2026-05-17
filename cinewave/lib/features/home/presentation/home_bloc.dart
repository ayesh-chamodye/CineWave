import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cinewave/features/home/data/repositories/home_repository.dart';
import 'package:cinewave/core/models/media_models.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // Both movies and TV always come from their /all endpoints (first 5).
      // The /api/home response is only used for the trending section below.
      final Map<String, dynamic> data = await homeRepository.getHomeData();

      List<Movie> movies;
      List<TVShow> tvShows;

      movies = (await homeRepository.getFirstFiveMoviesJson())
          .map((j) => Movie.fromJson(j))
          .toList();
      tvShows = (await homeRepository.getFirstFiveTvJson())
          .map((j) => TVShow.fromJson(j))
          .toList();

      movies = movies.take(5).toList();
      tvShows = tvShows.take(5).toList();

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
