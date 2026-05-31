import 'package:cinewave/core/models/media_models.dart';

abstract class DownloadState {}

class DownloadInitial extends DownloadState {}

class DownloadsLoading extends DownloadState {}

class DownloadsLoaded extends DownloadState {
  final List<DownloadItem> items;
  DownloadsLoaded(this.items);
}

class DownloadProgressUpdate extends DownloadState {
  final String id;
  final double progress;
  DownloadProgressUpdate(this.id, this.progress);
}

class DownloadError extends DownloadState {
  final String message;
  DownloadError(this.message);
}

class StreamSourcesLoading extends DownloadState {}

class StreamSourcesLoaded extends DownloadState {
  final List<VylaSource> sources;
  StreamSourcesLoaded({required this.sources});
}

class StreamSourcesError extends DownloadState {
  final String message;
  StreamSourcesError(this.message);
}
