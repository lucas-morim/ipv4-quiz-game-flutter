import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:io';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pl04sqlite.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    var exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
        ByteData data = await rootBundle.load('assets/database/$filePath');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        print("Error copying database: $e");
      }
    }

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE users ADD COLUMN profile_icon INTEGER DEFAULT 0');
        }
        if (oldVersion < 3) { 
          await db.execute('DROP TABLE IF EXISTS scores');
          await _createDB(db, newVersion);
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        email TEXT UNIQUE,
        profile_icon INTEGER DEFAULT 0,  -- 0 para o ícone padrão, 1-4 para os outros
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        level1_score INTEGER DEFAULT 0,
        level2_score INTEGER DEFAULT 0,
        level3_score INTEGER DEFAULT 0,
        last_played TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> registerUser(String username, String password, String email) async {
    final db = await database;
    return db.insert('users', {
      'username': username,
      'password': password,
      'email': email
    });
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateLevelScore(int userId, int score, int level) async {
    final db = await database;
    
    try {
      final scores = await db.query(
        'scores',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (scores.isEmpty) {
        return await db.insert('scores', {
          'user_id': userId,
          'level1_score': level == 1 ? score : 0,
          'level2_score': level == 2 ? score : 0,
          'level3_score': level == 3 ? score : 0,
          'last_played': DateTime.now().toIso8601String(),
        });
      } else {
        
        final currentScore = scores.first['level${level}_score'] as int? ?? 0;
        
        // Só atualiza se a nova pontuação for maior
        if (score > currentScore) {
          return await db.update(
            'scores',
            {
              'level${level}_score': score,
              'last_played': DateTime.now().toIso8601String(),
            },
            where: 'user_id = ?',
            whereArgs: [userId],
          );
        } else {
          return 0;
        }
      }
    } catch (e) {
      print('Erro ao atualizar pontuação: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserStats(int userId) async {
    final db = await database;
    final result = await db.query(
      'scores',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getTopScoresByLevel(int level) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        users.id as user_id,
        users.username,
        scores.level${level}_score as score
      FROM scores
      JOIN users ON users.id = scores.user_id
      WHERE scores.level${level}_score > 0
      ORDER BY scores.level${level}_score DESC
      LIMIT 5
    ''');
    
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUserProfile(int userId, {String? username, String? email, String? password}) async {
    final db = await database;
    return await db.update(
      'users',
      {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateProfileIcon(int userId, int iconIndex) async {
    final db = await database;
    return await db.update(
      'users',
      {'profile_icon': iconIndex},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}