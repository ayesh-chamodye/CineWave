import 'package:cinewave/core/models/library_models.dart';
import 'package:cinewave/features/library/data/datasources/library_local_datasource.dart';

class LibraryRepository {
  final LibraryLocalDataSource localDataSource;

  LibraryRepository({required this.localDataSource});

  Future<void> saveWatchHistory(WatchHistoryItem item) => localDataSource.saveWatchHistory(item);
  Future<List<WatchHistoryItem>> getWatchHistory() => localDataSource.getWatchHistory();
  Future<void> deleteWatchHistoryItem(String id) => localDataSource.deleteWatchHistoryItem(id);
  Future<void> clearWatchHistory() => localDataSource.clearWatchHistory();

  Future<void> toggleFavorite(FavoriteItem item) => localDataSource.toggleFavorite(item);
  Future<bool> isFavorite(String mediaId) => localDataSource.isFavorite(mediaId);
  Future<List<FavoriteItem>> getFavorites() => localDataSource.getFavorites();

  Future<void> toggleWatchlist(FavoriteItem item) => localDataSource.toggleWatchlist(item);
  Future<bool> isInWatchlist(String mediaId) => localDataSource.isInWatchlist(mediaId);
  Future<List<FavoriteItem>> getWatchlist() => localDataSource.getWatchlist();
}
