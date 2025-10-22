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
    // --- Create folders table ---
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        previewImage TEXT,
        createdAt TEXT
      )
    ''');

    // --- Create cards table ---
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

    // --- Prepopulate folders (4 suits) ---
    final now = DateTime.now().toIso8601String();
    final suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];

    for (var suit in suits) {
      await db.insert('folders', {
        'name': suit,
        'createdAt': now,
      });
    }

    // --- Prepopulate cards (52 total, 13 per suit) ---
    await _insertCards(db);
  }

  Future<void> _insertCards(Database db) async {
    // Example image URLs (you can replace these with your own later)
    final imageUrls = [
      'https://upload.wikimedia.org/wikipedia/commons/5/57/Playing_card_heart_A.svg',
      'https://upload.wikimedia.org/wikipedia/commons/d/d3/Playing_card_spade_A.svg',
      'https://upload.wikimedia.org/wikipedia/commons/2/22/Playing_card_diamond_A.svg',
      'https://upload.wikimedia.org/wikipedia/commons/5/50/Playing_card_club_A.svg',
      'https://upload.wikimedia.org/wikipedia/commons/2/25/Playing_card_heart_K.svg',
      'https://upload.wikimedia.org/wikipedia/commons/2/25/Playing_card_spade_K.svg',
      'https://upload.wikimedia.org/wikipedia/commons/f/f2/Playing_card_diamond_K.svg',
      'https://upload.wikimedia.org/wikipedia/commons/8/80/Playing_card_club_K.svg',
      'https://upload.wikimedia.org/wikipedia/commons/3/36/Playing_card_heart_Q.svg',
      'https://upload.wikimedia.org/wikipedia/commons/0/0d/Playing_card_spade_Q.svg',
      'https://upload.wikimedia.org/wikipedia/commons/9/94/Playing_card_diamond_Q.svg',
      'https://upload.wikimedia.org/wikipedia/commons/3/3e/Playing_card_club_Q.svg',
      'https://upload.wikimedia.org/wikipedia/commons/2/21/Playing_card_heart_J.svg',
      'https://upload.wikimedia.org/wikipedia/commons/b/bd/Playing_card_spade_J.svg',
    ];

    final suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    final ranks = [
      'A',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K'
    ];

    final now = DateTime.now().toIso8601String();
    int imageIndex = 0;

    for (var suit in suits) {
      for (var rank in ranks) {
        final name = '$rank of $suit';
        final imageUrl = imageUrls[imageIndex % imageUrls.length];
        imageIndex++;

        await db.insert('cards', {
          'name': name,
          'suit': suit,
          'imageUrl': imageUrl,
          'createdAt': now,
          'folderId': suits.indexOf(suit) + 1, // folder IDs start at 1
        });
      }
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
