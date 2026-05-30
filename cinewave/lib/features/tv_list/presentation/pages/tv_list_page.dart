import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/tv_list/presentation/tv_list_bloc.dart';
import 'package:cinewave/features/tv_list/data/repositories/tv_list_repository.dart';
import 'package:cinewave/features/tv_list/data/datasources/tv_all_remote_datasource.dart';
import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/shared/widgets/network_image.dart';
import 'package:cinewave/shared/widgets/error_display.dart';
import 'package:cinewave/shared/widgets/loading_indicator.dart';

class TVListPage extends StatefulWidget {
  static const String routeName = '/all-tv';

  const TVListPage({super.key});

  @override
  State<TVListPage> createState() => _TVListPageState();
}

class _TVListPageState extends State<TVListPage> {
  static const double _tileWidth = 130.0;
  static const double _tileHeight = 190.0;

  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final TVListRepository _repository;
  TVListBloc? _bloc;
  String? _lastQuery;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _repository = TVListRepository(
      remoteDataSource: TVAllRemoteDataSource(apiClient: apiClient),
    );
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _bloc?.add(const LoadTVPage(1));
      _lastQuery = null;
      return;
    }
    if (trimmed == _lastQuery) return;
    _lastQuery = trimmed;
    _bloc?.add(SearchTV(trimmed));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels > 0) {
      if (_searchController.text.trim().isEmpty) {
        final bloc = _bloc;
        final state = bloc?.state;
        if (state is TVListLoaded && !state.hasReachedMax) {
          bloc!.add(LoadTVPage(state.page + 1));
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
      create: (_) => TVListBloc(repository: _repository)
        ..add(const LoadTVPage(1)),
      child: Builder(
        builder: (innerContext) {
          _bloc = innerContext.watch<TVListBloc>();
          return Scaffold(
            backgroundColor:
                Theme.of(innerContext).scaffoldBackgroundColor,
            body: BlocBuilder<TVListBloc, TVListState>(
              builder: (context, state) {
                // Collect tvShows from whichever state variant we are in.
                final List<TVShow> tvShows; // Dart narrows inside switch arms
                final bool hasReachedMax;
                switch (state) {
                  case TVListLoaded(
                      tvShows: final s, hasReachedMax: final h):
                    tvShows = s;
                    hasReachedMax = h;
                    break;
                  case TVListSearchLoaded(tvShows: final s):
                    tvShows = s;
                    hasReachedMax = true;
                    break;
                  default:
                    tvShows = const <TVShow>[];
                    hasReachedMax = true;
                }

                if (state is TVListLoading) {
                  return const Center(child: LoadingIndicator());
                }
                if (state is TVListError) {
                  return ErrorDisplay(
                    message: state.message,
                    onRetry: () {
                      if (_lastQuery != null) {
                        context
                            .read<TVListBloc>()
                            .add(SearchTV(_lastQuery!));
                      } else {
                        context
                            .read<TVListBloc>()
                            .add(const LoadTVPage(1));
                      }
                    },
                  );
                }

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                 SliverAppBar(
                       automaticallyImplyLeading: false,
                       backgroundColor:
                           Colors.black.withValues(alpha: 0.8),
                       elevation: 0,
                       pinned: true,
                       floating: false,                      
                       title: TextField(
                         controller: _searchController,
                         onChanged: _onSearchChanged,
                         style: const TextStyle(color: Colors.white),
                         cursorColor: Colors.white,
                         decoration: InputDecoration(
                           hintText: 'Search TV shows…',
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
                    if (tvShows.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No TV shows found',
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
                              if (index < tvShows.length) {
                                return _TVGridTile(tvShow: tvShows[index]);
                              }
                              if (!hasReachedMax || _lastQuery != null) {
                                return const _LoadingMoreIndicator();
                              }
                              return const _EndOfListMarker();
                            },
                            childCount: tvShows.length +
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

class _TVGridTile extends StatelessWidget {
  final TVShow tvShow;

  const _TVGridTile({required this.tvShow});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/tv-detail', arguments: tvShow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Netflix-style poster card: rounded, upright portrait
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  tvShow.posterUrl.isNotEmpty
                      ? NetworkImageWidget(
                          imageUrl: tvShow.posterUrl,
                          fit: BoxFit.cover,
                        )
                      : const ColoredBox(color: Color(0xFF1F1F1F)),
                  // TV badge — top-left corner
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(
                        Icons.live_tv,
                        color: Colors.black87,
                        size: 12,
                      ),
                    ),
                  ),
                  // Bottom vignette
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
            tvShow.name,
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
