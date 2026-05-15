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
      final Map<String, dynamic> data = await homeRepository.getHomeData();
      
      final List<dynamic> moviesJson = data['movies'] ?? [];
      final List<dynamic> tvShowsJson = data['tvShows'] ?? [];
      
      final List<Movie> movies = moviesJson.map((json) => Movie.fromJson(json)).toList();
      final List<TVShow> tvShows = tvShowsJson.map((json) => TVShow.fromJson(json)).toList();

      // Extract featured content (highest rated item)
      Movie? featuredMovie;
      TVShow? featuredTVShow;
      
      if (movies.isNotEmpty) {
        featuredMovie = movies.reduce((a, b) => a.voteAverage > b.voteAverage ? a : b);
      } else if (tvShows.isNotEmpty) {
        featuredTVShow = tvShows.reduce((a, b) => a.voteAverage > b.voteAverage ? a : b);
      }

      // Extract trending (top 10 movies by rating)
      List<Movie> trendingMovies = [];
      if (movies.length >= 5) {
        trendingMovies = List.from(movies);
        trendingMovies.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
        if (trendingMovies.length > 10) {
          trendingMovies = trendingMovies.sublist(0, 10);
        }
      }

      emit(HomeLoaded(
        movies: movies,
        tvShows: tvShows,
        featuredMovie: featuredMovie,
        featuredTVShow: featuredTVShow,
        trendingMovies: trendingMovies.isNotEmpty ? trendingMovies : null,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}