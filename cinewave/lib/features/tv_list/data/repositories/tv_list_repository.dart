import 'package:cinewave/features/tv_list/data/datasources/tv_all_remote_datasource.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/models/api_page_result.dart';

class TVListRepository {
  final TVAllRemoteDataSource remoteDataSource;

  TVListRepository({required this.remoteDataSource});

  Future<ApiPageResult<TVShow>> getTVPage(int page) async {
    return await remoteDataSource.fetchPage(page);
  }

  Future<ApiPageResult<TVShow>> searchTvShows(String query) async {
    return await remoteDataSource.searchTvShows(query);
  }
}
