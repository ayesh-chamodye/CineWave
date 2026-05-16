import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/search/presentation/search_bloc.dart';
import 'package:cinewave/features/search/presentation/widgets/search_result_list.dart';
import 'package:cinewave/shared/widgets/loading_indicator.dart';
import 'package:cinewave/shared/widgets/error_display.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchBloc = context.read<SearchBloc>();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search movies & TV shows…',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  final trimmed = value.trim();
                  if (trimmed.isNotEmpty) {
                    searchBloc.add(SearchMovies(query: trimmed));
                    searchBloc.add(SearchTvShows(query: trimmed));
                  }
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const LoadingIndicator();
                  }

                  if (state is SearchResultsLoaded) {
                    return SearchResultList(
                      movies: state.movies,
                      tvShows: state.tvShows,
                    );
                  }

                  if (state is SearchError) {
                    return ErrorDisplay(
                      message: state.message,
                      onRetry: () {
                        final q = state.query;
                        if (q != null && q.isNotEmpty) {
                          searchBloc.add(SearchMovies(query: q));
                          searchBloc.add(SearchTvShows(query: q));
                        }
                      },
                    );
                  }

                  return const Center(
                    child: Text(
                      'Search for movies and TV shows',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
