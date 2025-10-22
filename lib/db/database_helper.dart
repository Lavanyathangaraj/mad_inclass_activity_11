import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/folder.dart';
import '../models/card_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cards_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        previewImage TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        suit TEXT,
        imageUrl TEXT,
        imageBytes TEXT,
        folderId INTEGER,
        createdAt TEXT,
        FOREIGN KEY (folderId) REFERENCES folders (id)
      )
    ''');

    // Prepopulate folders
    final now = DateTime.now().toIso8601String();
    final suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    for (var suit in suits) {
      await db.insert('folders', {
        'name': suit,
        'createdAt': now,
      });
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
