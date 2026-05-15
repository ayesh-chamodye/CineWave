import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/features/tv_detail/data/datasources/tv_detail_remote_datasource.dart';

class TVDetailRepository {
  final TVDetailRemoteDataSource tvDetailRemoteDataSource;

  TVDetailRepository({required this.tvDetailRemoteDataSource});

   Future<TVShow> getTvDetail(int tvShowId) async {
     return await tvDetailRemoteDataSource.getTvDetail(tvShowId);
   }
}
