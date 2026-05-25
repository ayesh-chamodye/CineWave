import 'package:cinewave/core/database/database_helper.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:sqflite/sqflite.dart';

class DownloadLocalDataSource {
  final DatabaseHelper dbHelper;

  DownloadLocalDataSource({required this.dbHelper});

  Future<void> saveDownload(DownloadItem item) async {
    final db = await dbHelper.database;
    await db.insert(
      'downloads',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DownloadItem>> getDownloads() async {
    final db = await dbHelper.database;
    final maps = await db.query('downloads');
    return List.generate(maps.length, (i) {
      return DownloadItem.fromMap(maps[i]);
    });
  }

  Future<void> deleteDownload(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      'downloads',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateStatus(String id, DownloadStatus status) async {
    final db = await dbHelper.database;
    await db.update(
      'downloads',
      {'status': status.index},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
