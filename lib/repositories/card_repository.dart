import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/card.dart';

class CardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<PlayingCard>> getCardsByFolderId(int folderId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'card_name ASC',
    );
    return maps
        .map((m) => PlayingCard.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<int> deleteCard(int id) async {
    final db = await _dbHelper.database;
    return db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCardCountByFolder(int folderId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cards WHERE folder_id = ?',
      [folderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}