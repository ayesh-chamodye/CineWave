import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cinewave.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createWatchHistoryTable(db);
      await _createFavoritesTable(db);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE downloads (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        posterUrl TEXT,
        filePath TEXT NOT NULL,
        type TEXT NOT NULL,
        season INTEGER,
        episode INTEGER,
        status INTEGER NOT NULL
      )
    ''');
    await _createWatchHistoryTable(db);
    await _createFavoritesTable(db);
  }

  Future _createWatchHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE watch_history (
        id TEXT PRIMARY KEY,
        mediaId TEXT NOT NULL,
        title TEXT NOT NULL,
        posterUrl TEXT,
        type TEXT NOT NULL,
        season INTEGER,
        episode INTEGER,
        position INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        lastWatched TEXT NOT NULL
      )
    ''');
  }

  Future _createFavoritesTable(Database db) async {
    await db.execute('''
      CREATE TABLE favorites (
        mediaId TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        posterUrl TEXT,
        backdropUrl TEXT,
        overview TEXT,
        type TEXT NOT NULL,
        rating REAL,
        releaseDate TEXT
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
