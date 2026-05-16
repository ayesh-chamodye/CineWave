import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/core/theme/app_theme.dart';
import 'package:cinewave/features/home/presentation/home_bloc.dart';
import 'package:cinewave/features/home/data/repositories/home_repository.dart';
import 'package:cinewave/features/home/data/datasources/home_remote_datasource.dart';
import 'package:cinewave/features/search/presentation/search_bloc.dart';
import 'package:cinewave/features/search/data/repositories/search_repository.dart';
import 'package:cinewave/features/search/data/datasources/search_remote_datasource.dart';
import 'package:cinewave/features/movie_detail/presentation/movie_detail_bloc.dart';
import 'package:cinewave/features/movie_detail/data/repositories/movie_detail_repository.dart';
import 'package:cinewave/features/movie_detail/data/datasources/movie_detail_remote_datasource.dart';
import 'package:cinewave/features/tv_detail/presentation/tv_detail_bloc.dart';
import 'package:cinewave/features/tv_detail/data/repositories/tv_detail_repository.dart';
import 'package:cinewave/features/tv_detail/data/datasources/tv_detail_remote_datasource.dart';
import 'package:cinewave/core/network/api_client.dart';
import 'package:cinewave/shared/routes/app_routes.dart';

void main() {
  runApp(const CineWaveApp());
}

class CineWaveApp extends StatelessWidget {
  const CineWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => HomeRepository(
            homeRemoteDataSource: HomeRemoteDataSource(
              apiClient: ApiClient(),
            ),
          ),
        ),
        RepositoryProvider(
          create: (_) => SearchRepository(
            searchRemoteDataSource: SearchRemoteDataSource(
              apiClient: ApiClient(),
            ),
          ),
        ),
        RepositoryProvider(
          create: (_) => MovieDetailRepository(
            movieDetailRemoteDataSource: MovieDetailRemoteDataSource(
              apiClient: ApiClient(),
            ),
          ),
        ),
        RepositoryProvider(
          create: (_) => TVDetailRepository(
            tvDetailRemoteDataSource: TVDetailRemoteDataSource(
              apiClient: ApiClient(),
            ),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeBloc(
              homeRepository: context.read<HomeRepository>(),
            )..add(LoadHomeData()),
          ),
          BlocProvider(
            create: (context) => SearchBloc(
              searchRepository: context.read<SearchRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => MovieDetailBloc(
              movieDetailRepository: context.read<MovieDetailRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => TVDetailBloc(
              tvDetailRepository: context.read<TVDetailRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'CineWave',
          theme: AppTheme.getTheme(),
          debugShowCheckedModeBanner: false,
          initialRoute: '/splash',
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}