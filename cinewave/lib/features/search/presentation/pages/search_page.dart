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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const LoadingIndicator();
                  } else if (state is SearchMoviesLoaded) {
                    return SearchResultList(
                      movies: state.movies,
                      tvShows: const [],
                    );
                  } else if (state is SearchTvShowsLoaded) {
                    return SearchResultList(
                      movies: const [],
                      tvShows: state.tvShows,
                    );
                  } else if (state is SearchError) {
                    return ErrorDisplay(
                      message: state.message,
                      onRetry: () {
                        if (state.query != null && state.query!.isNotEmpty) {
                          context.read<SearchBloc>().add(SearchMovies(query: state.query!));
                          context.read<SearchBloc>().add(SearchTvShows(query: state.query!));
                        }
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'Search for movies and TV shows',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for movies and TV shows',
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
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            context.read<SearchBloc>().add(SearchMovies(query: value));
            context.read<SearchBloc>().add(SearchTvShows(query: value));
          }
        },
      ),
    );
  }
}