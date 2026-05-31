import 'package:cinewave/core/models/media_models.dart';
import '../datasources/stream_remote_datasource.dart';

class StreamRepository {
  final StreamRemoteDataSource streamRemoteDataSource;

  StreamRepository({required this.streamRemoteDataSource});

  Future<Vyla> getStreamLinks(int tmdbId, String type,
      {int? season, int? episode}) {
    return streamRemoteDataSource.getStreamLinks(tmdbId, type,
        season: season, episode: episode);
  }
}
