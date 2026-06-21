import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
import 'package:cinewave/core/database/database_helper.dart';
import 'package:cinewave/features/downloads/data/datasources/download_local_datasource.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_bloc.dart';
import 'package:cinewave/features/downloads/presentation/bloc/download_event.dart';
import 'package:cinewave/features/library/data/datasources/library_local_datasource.dart';
import 'package:cinewave/features/library/data/repositories/library_repository.dart';
import 'package:cinewave/features/library/presentation/bloc/library_bloc.dart';
import 'package:cinewave/core/ads/ad_service.dart';
import 'package:cinewave/shared/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService().init();
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
        RepositoryProvider(
          create: (_) => DownloadLocalDataSource(
            dbHelper: DatabaseHelper.instance,
          ),
        ),
        RepositoryProvider(
          create: (_) => LibraryRepository(
            localDataSource: LibraryLocalDataSource(
              dbHelper: DatabaseHelper.instance,
            ),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DownloadBloc(
              localDataSource: context.read<DownloadLocalDataSource>(),
            )..add(LoadDownloads()),
          ),
          BlocProvider(
            create: (context) => LibraryBloc(
              repository: context.read<LibraryRepository>(),
            ),
          ),
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