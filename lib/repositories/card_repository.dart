import '../db/database_helper.dart';
import '../models/card_model.dart';

class CardRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<CardModel>> getCardsByFolder(int folderId) async {
    final db = await dbHelper.database;
    final result =
        await db.query('cards', where: 'folderId = ?', whereArgs: [folderId]);
    return result.map((map) => CardModel.fromMap(map)).toList();
  }

  Future<int> createCard(CardModel card) async { // <-- MANDATORY CREATE
    final db = await dbHelper.database;
    return await db.insert('cards', card.toMap());
  }
  
  Future<int> updateCard(CardModel card) async { // <-- MANDATORY UPDATE
    final db = await dbHelper.database;
    return await db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(int id) async {
    final db = await dbHelper.database;
    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}