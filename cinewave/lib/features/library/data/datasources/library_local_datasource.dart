import 'package:cinewave/core/database/database_helper.dart';
import 'package:cinewave/core/models/library_models.dart';
import 'package:sqflite/sqflite.dart';

class LibraryLocalDataSource {
  final DatabaseHelper dbHelper;

  LibraryLocalDataSource({required this.dbHelper});

  // Watch History
  Future<void> saveWatchHistory(WatchHistoryItem item) async {
    final db = await dbHelper.database;
    await db.insert(
      'watch_history',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WatchHistoryItem>> getWatchHistory() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'watch_history',
      orderBy: 'lastWatched DESC',
    );
    return List.generate(maps.length, (i) => WatchHistoryItem.fromMap(maps[i]));
  }

  Future<void> deleteWatchHistoryItem(String id) async {
    final db = await dbHelper.database;
    await db.delete('watch_history', where: 'id = ?', whereArgs: [id]);
  }

  // Favorites
  Future<void> toggleFavorite(FavoriteItem item) async {
    final db = await dbHelper.database;
    final exists = await db.query(
      'favorites',
      where: 'mediaId = ?',
      whereArgs: [item.mediaId],
    );

    if (exists.isNotEmpty) {
      await db.delete(
        'favorites',
        where: 'mediaId = ?',
        whereArgs: [item.mediaId],
      );
    } else {
      await db.insert(
        'favorites',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<bool> isFavorite(String mediaId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'favorites',
      where: 'mediaId = ?',
      whereArgs: [mediaId],
    );
    return maps.isNotEmpty;
  }

  Future<List<FavoriteItem>> getFavorites() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) => FavoriteItem.fromMap(maps[i]));
  }

  // Watchlist
  Future<void> toggleWatchlist(FavoriteItem item) async {
    final db = await dbHelper.database;
    final exists = await db.query(
      'watchlist',
      where: 'mediaId = ?',
      whereArgs: [item.mediaId],
    );

    if (exists.isNotEmpty) {
      await db.delete(
        'watchlist',
        where: 'mediaId = ?',
        whereArgs: [item.mediaId],
      );
    } else {
      await db.insert(
        'watchlist',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<bool> isInWatchlist(String mediaId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'watchlist',
      where: 'mediaId = ?',
      whereArgs: [mediaId],
    );
    return maps.isNotEmpty;
  }

  Future<List<FavoriteItem>> getWatchlist() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('watchlist');
    return List.generate(maps.length, (i) => FavoriteItem.fromMap(maps[i]));
  }
}
