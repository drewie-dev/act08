import '../database/database_helper.dart';
import '../models/folder.dart';

class FolderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Folder>> getAllFolders() async {
    final db = await _dbHelper.database;
    final maps = await db.query('folders', orderBy: 'id ASC');
    return maps.map((m) => Folder.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<int> deleteFolder(int id) async {
    final db = await _dbHelper.database;
    return db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }
}