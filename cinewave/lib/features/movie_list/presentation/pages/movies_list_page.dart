import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/movie_list/presentation/movies_list_bloc.dart';
import 'package:cinewave/features/movie_list/data/repositories/movies_list_repository.dart';
import 'package:cinewave/features/movie_list/data/datasources/movies_all_remote_datasource.dart';
import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/shared/widgets/error_display.dart';
import 'package:cinewave/shared/widgets/loading_indicator.dart';

class MoviesListPage extends StatefulWidget {
  static const String routeName = '/all-movies';

  const MoviesListPage({super.key});

  @override
  State<MoviesListPage> createState() => _MoviesListPageState();
}

class _MoviesListPageState extends State<MoviesListPage> {
  static const double _tileWidth = 130.0;
  static const double _tileHeight = 190.0;

  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final MoviesListRepository _repository;
  MoviesListBloc? _bloc;
  String? _lastQuery;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _repository = MoviesListRepository(
      remoteDataSource: MoviesAllRemoteDataSource(apiClient: apiClient),
    );
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      // Clear search — reload the paginated list from page 1
      _bloc?.add(const LoadMoviesPage(1));
      _lastQuery = null;
      return;
    }
    if (trimmed == _lastQuery) return;
    _lastQuery = trimmed;
    _bloc?.add(SearchMovies(trimmed));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels > 0) {
      // Only paginate when no search query is active
      if (_searchController.text.trim().isEmpty) {
        final bloc = _bloc;
        final state = bloc?.state;
        if (state is MoviesListLoaded && !state.hasReachedMax) {
          bloc!.add(LoadMoviesPage(state.page + 1));
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MoviesListBloc(repository: _repository)
        ..add(const LoadMoviesPage(1)),
      child: Builder(
        builder: (innerContext) {
          _bloc = innerContext.watch<MoviesListBloc>();
          return Scaffold(
            backgroundColor:
                Theme.of(innerContext).scaffoldBackgroundColor,
            body: BlocBuilder<MoviesListBloc, MoviesListState>(
              builder: (context, state) {
                // Collect movies from whichever state variant we are in.
                final List<Movie> movies; // Dart narrows inside switch arms
                final bool hasReachedMax;
                switch (state) {
                  case MoviesListLoaded(
                      movies: final m, hasReachedMax: final h):
                    movies = m;
                    hasReachedMax = h;
                    break;
                  case MoviesListSearchLoaded(movies: final m):
                    movies = m;
                    hasReachedMax = true;
                    break;
                  default:
                    movies = const <Movie>[];
                    hasReachedMax = true;
                }

                if (state is MoviesListLoading) {
                  return const Center(child: LoadingIndicator());
                }
                if (state is MoviesListError) {
                  return ErrorDisplay(
                    message: state.message,
                    onRetry: () {
                      if (_lastQuery != null) {
                        context
                            .read<MoviesListBloc>()
                            .add(SearchMovies(_lastQuery!));
                      } else {
                        context
                            .read<MoviesListBloc>()
                            .add(const LoadMoviesPage(1));
                      }
                    },
                  );
                }

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      backgroundColor:
                          Colors.black.withValues(alpha: 0.8),
                      elevation: 0,
                      pinned: true,
                      floating: false,
                      leading: const BackButton(color: Colors.white),
                      title: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: 'Search movies…',
                          hintStyle:
                              const TextStyle(color: Colors.white54),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    if (movies.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No movies found',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio:
                                _tileWidth / _tileHeight,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < movies.length) {
                                return _MovieGridTile(movie: movies[index]);
                              }
                              if (!hasReachedMax || _lastQuery != null) {
                                return const _LoadingMoreIndicator();
                              }
                              return const _EndOfListMarker();
                            },
                            childCount: movies.length +
                                (hasReachedMax && _lastQuery == null
                                    ? 1
                                    : 0),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MovieGridTile extends StatelessWidget {
  final Movie movie;

  const _MovieGridTile({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/movie-detail', arguments: movie),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Netflix-style poster card: rounded, upright portrait with badge
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageWidget(
                    imageUrl: movie.posterUrl,
                    fit: BoxFit.cover,
                  ),
                  // Green match badge — top-left
                  if (movie.voteAverage > 0)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF46D369),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${(movie.voteAverage * 10).toInt()}% Match',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  // Bottom vignette so white title text remains readable
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                          stops: [0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
}

class _EndOfListMarker extends StatelessWidget {
  const _EndOfListMarker();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text(
            "You've reached the end",
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ),
      );
}
