import '../db/database_helper.dart';
import '../models/folder.dart';
import 'package:sqflite/sqflite.dart';

class FolderRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Folder>> getAllFolders() async {
    final db = await dbHelper.database;
    final result = await db.query('folders', orderBy: 'createdAt DESC');
    return result.map((map) => Folder.fromMap(map)).toList();
  }

  Future<int> countCards(int folderId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM cards WHERE folderId = ?',
      [folderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> updatePreviewImage(int folderId, String imageUrl) async {
    final db = await dbHelper.database;
    await db.update(
      'folders',
      {'previewImage': imageUrl},
      where: 'id = ?',
      whereArgs: [folderId],
    );
  }
}