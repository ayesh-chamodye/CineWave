import 'package:cinewave/core/models/media_models.dart';

abstract class DownloadEvent {}

class LoadDownloads extends DownloadEvent {}

class StartDownload extends DownloadEvent {
  final Movie? movie;
  final TVShow? tvShow;
  final int? season;
  final int? episode;
  final String url;

  StartDownload({
    this.movie,
    this.tvShow,
    this.season,
    this.episode,
    required this.url,
  });
}

class DeleteDownload extends DownloadEvent {
  final String id;
  DeleteDownload(this.id);
}
