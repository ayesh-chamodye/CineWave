import 'package:cinewave/core/models/media_models.dart';

abstract class DownloadEvent {}

class LoadDownloads extends DownloadEvent {}

class StartDownload extends DownloadEvent {
  final Movie? movie;
  final TVShow? tvShow;
  final int? season;
  final int? episode;
  final String url;
  final String? headers;

  StartDownload({
    this.movie,
    this.tvShow,
    this.season,
    this.episode,
    required this.url,
    this.headers,
  });
}

class DeleteDownload extends DownloadEvent {
  final String id;
  DeleteDownload(this.id);
}

class LoadStreamSources extends DownloadEvent {
  final int tmdbId;
  final String type;
  final int? season;
  final int? episode;
  LoadStreamSources({
    required this.tmdbId,
    required this.type,
    this.season,
    this.episode,
  });
}
