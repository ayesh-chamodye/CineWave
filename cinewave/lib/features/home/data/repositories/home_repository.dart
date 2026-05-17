import 'package:cinewave/features/home/data/datasources/home_remote_datasource.dart';

class HomeRepository {
  final HomeRemoteDataSource homeRemoteDataSource;

  HomeRepository({required this.homeRemoteDataSource});

  Future<Map<String, dynamic>> getHomeData() async {
    return await homeRemoteDataSource.getHomeData();
  }

  Future<List<dynamic>> getFirstFiveMoviesJson() async {
    return await homeRemoteDataSource.getFirstFiveMoviesJson();
  }

  Future<List<dynamic>> getFirstFiveTvJson() async {
    return await homeRemoteDataSource.getFirstFiveTvJson();
  }
}
