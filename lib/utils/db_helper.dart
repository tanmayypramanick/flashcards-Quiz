import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '/models/deck.dart';

class DBHelper {
  static const String _databaseName = 'flashcards.db';
  static const int _databaseVersion = 1;

  DBHelper._();
  static final DBHelper _singleton = DBHelper._();
  factory DBHelper() => _singleton;

  Database? _database;

  Future<Database?> get db async {
    _database ??= await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);

    print(dbPath);

    var db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );

    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE deck(
        id INTEGER PRIMARY KEY,
        title TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE flashcard(
        id INTEGER PRIMARY KEY,
        deck_id INTEGER,
        question TEXT,
        answer TEXT,
        FOREIGN KEY (deck_id) REFERENCES deck(id)
      )
    ''');
  }

  // Insert a record into a table
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int id = await db!.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // Delete a record from a table by ID
  Future<void> delete(String table, int id) async {
    final db = await this.db;
    await db?.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateDeckTitle(int deckId, String newTitle) async {
    final db = await this.db;
    await db!.update(
      'deck',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [deckId],
    );
  }

  Future<List<Flashcard>> getFlashcardsForDeck(int deckId) async {
    final db = await this.db;
    final List<Map<String, dynamic>> flashcards = await db!.query(
      'flashcard',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );

    return flashcards.map((map) => Flashcard.fromMap(map)).toList();
  }

  Future<List<Deck>> getAllDecks() async {
    final db = await this.db;
    final List<Map<String, dynamic>> deckMaps = await db!.query('deck');

    return deckMaps.map((map) => Deck.fromMap(map)).toList();
  }

  Future<void> updateFlashcard(
      int id, int deckId, String question, String answer) async {
    final db = await this.db;
    await db!.update(
      'flashcard',
      {'deck_id': deckId, 'question': question, 'answer': answer},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFlashcardsForDeck(int deckId) async {
    final db = await this.db;
    await db!.delete(
      'flashcard',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );
  }
}
