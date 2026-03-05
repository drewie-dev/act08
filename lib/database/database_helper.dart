import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders (id)
          ON DELETE CASCADE
      )
    ''');

    await _prepopulateFolders(db);
    await _prepopulateCards(db);
  }

  Future<void> _prepopulateFolders(Database db) async {
    final suits = ['Hearts', 'Spades']; 

    for (final suit in suits) {
      await db.insert('folders', {
        'folder_name': suit,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _prepopulateCards(Database db) async {
    final folders = await db.query('folders', orderBy: 'id ASC');

    final ranks = <String>[
      'Ace',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'Jack',
      'Queen',
      'King',
    ];

    for (final f in folders) {
      final folderId = f['id'] as int;
      final suit = f['folder_name'] as String;

      for (final rank in ranks) {
        await db.insert('cards', {
          'card_name': rank,
          'suit': suit,
          'image_url': _cardImageUrl(rank, suit),
          'folder_id': folderId,
        });
      }
    }
  }

  String _cardImageUrl(String rank, String suit) {
    String rankCode;
    switch (rank) {
      case 'Ace':
        rankCode = 'A';
        break;
      case 'King':
        rankCode = 'K';
        break;
      case 'Queen':
        rankCode = 'Q';
        break;
      case 'Jack':
        rankCode = 'J';
        break;
      default:
        rankCode = rank; 
    }

    String suitCode;
    switch (suit) {
      case 'Hearts':
        suitCode = 'H';
        break;
      case 'Spades':
        suitCode = 'S';
        break;
      default:
        suitCode = 'H';
    }

    return 'https://deckofcardsapi.com/static/img/$rankCode$suitCode.png';
  }
}