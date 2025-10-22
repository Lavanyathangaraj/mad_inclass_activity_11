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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create folders table
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        previewImage TEXT,
        createdAt TEXT
      )
    ''');

    // Create cards table
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

    // Insert folders
    final now = DateTime.now().toIso8601String();
    final suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    List<int> folderIds = [];

    for (var suit in suits) {
      int id = await db.insert('folders', {
        'name': suit,
        'createdAt': now,
      });
      folderIds.add(id);
    }

    // Insert cards
    await _insertCards(db, suits, folderIds);
  }

  Future<void> _insertCards(Database db, List<String> suits, List<int> folderIds) async {
    final ranks = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];

    // Local asset paths for the cards
    final imageUrls = [
      'assets/cards/heart_a.png',
      'assets/cards/spade_a.png',
      'assets/cards/diamond_a.png',
      'assets/cards/club_a.png',
      'assets/cards/heart_k.png',
      'assets/cards/spade_k.png',
      'assets/cards/diamond_k.png',
      'assets/cards/club_k.png',
      'assets/cards/heart_q.png',
      'assets/cards/spade_q.png',
      'assets/cards/diamond_q.png',
      'assets/cards/club_q.png',
      'assets/cards/heart_j.png',
      'assets/cards/spade_j.png',
    ];

    int imageIndex = 0;
    final now = DateTime.now().toIso8601String();

    for (int i = 0; i < suits.length; i++) {
      final suit = suits[i];
      final folderId = folderIds[i];

      for (var rank in ranks) {
        await db.insert('cards', {
          'name': '$rank of $suit',
          'suit': suit,
          'imageUrl': imageUrls[imageIndex % imageUrls.length],
          'createdAt': now,
          'folderId': folderId,
        });
        imageIndex++;
      }
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}