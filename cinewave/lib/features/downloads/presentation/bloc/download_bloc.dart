import 'dart:io';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/features/downloads/data/datasources/download_local_datasource.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'download_event.dart';
import 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadLocalDataSource localDataSource;
  final Dio dio = Dio();
  final Map<String, double> _progressMap = {};
  Timer? _progressTimer;

  DownloadBloc({required this.localDataSource}) : super(DownloadInitial()) {
    on<LoadDownloads>((event, emit) async {
      emit(DownloadsLoading());
      try {
        final items = await localDataSource.getDownloads();
        emit(DownloadsLoaded(items));
      } catch (e) {
        emit(DownloadError(e.toString()));
      }
    });

    on<StartDownload>((event, emit) async {
      final String id = event.movie?.id.toString() ?? 
                       "${event.tvShow?.id}_${event.season}_${event.episode}";
      
      final currentDownloads = await localDataSource.getDownloads();
      if (currentDownloads.any((item) => item.id == id && item.status == DownloadStatus.completed)) {
        return;
      }

      if (Platform.isAndroid) {
        await Permission.storage.request();
        await Permission.manageExternalStorage.request();
      }
      
      final String title = event.movie?.title ?? 
                          "${event.tvShow?.name} S${event.season}E${event.episode}";
      
      final String poster = event.movie?.posterUrl ?? event.tvShow?.posterUrl ?? '';
      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/$id.mp4";

      final item = DownloadItem(
        id: id,
        title: title,
        posterUrl: poster,
        filePath: filePath,
        type: event.movie != null ? 'movie' : 'tv',
        season: event.season,
        episode: event.episode,
        status: DownloadStatus.downloading,
      );

      await localDataSource.saveDownload(item);
      _startProgressTimer();
      add(LoadDownloads());

      try {
        await dio.download(
          event.url,
          filePath,
          onReceiveProgress: (count, total) {
            if (total != -1) {
              _progressMap[id] = count / total;
            }
          },
        );
        _progressMap.remove(id);
        await localDataSource.updateStatus(id, DownloadStatus.completed);
        _stopProgressTimerIfEmpty();
        add(LoadDownloads());
      } catch (e) {
        _progressMap.remove(id);
        await localDataSource.updateStatus(id, DownloadStatus.error);
        _stopProgressTimerIfEmpty();
        add(LoadDownloads());
      }
    });

    on<DeleteDownload>((event, emit) async {
      try {
        final items = await localDataSource.getDownloads();
        final item = items.firstWhere((element) => element.id == event.id);
        final file = File(item.filePath);
        if (await file.exists()) {
          await file.delete();
        }
        await localDataSource.deleteDownload(event.id);
        add(LoadDownloads());
      } catch (e) {
        emit(DownloadError(e.toString()));
      }
    });
  }

  void _startProgressTimer() {
    if (_progressTimer != null && _progressTimer!.isActive) return;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_progressMap.isNotEmpty) {
        add(LoadDownloads());
      } else {
        timer.cancel();
      }
    });
  }

  void _stopProgressTimerIfEmpty() {
    if (_progressMap.isEmpty) {
      _progressTimer?.cancel();
    }
  }

  double getProgress(String id) => _progressMap[id] ?? 0;

  @override
  Future<void> close() {
    _progressTimer?.cancel();
    return super.close();
  }
}
