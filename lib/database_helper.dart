import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Tạo một đối tượng DatabaseHelper dùng chung cho toàn app
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Biến lưu database
  static Database? _database;

  // Constructor riêng
  DatabaseHelper._init();

  // Lấy database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('expense_manager.db');
    return _database!;
  }

  // Khởi tạo database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      fileName,
    );

    return await openDatabase(
      path,

      // Database cũ của bạn là version 1
      // Đổi thành version 2 để thêm cột title
      version: 2,

      // Nếu database chưa tồn tại
      onCreate: _createDB,

      // Nếu database đã tồn tại và nâng version
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE transactions
            ADD COLUMN title TEXT NOT NULL DEFAULT ''
          ''');
        }
      },
    );
  }

  // Tạo bảng transactions
  Future<void> _createDB(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // =====================================================
  // INSERT - THÊM GIAO DỊCH
  // =====================================================

  Future<int> insertTransaction(
      Map<String, dynamic> transaction,
      ) async {
    final db = await database;

    return await db.insert(
      'transactions',
      transaction,
    );
  }

  // =====================================================
  // SELECT - LẤY TẤT CẢ GIAO DỊCH
  // =====================================================

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;

    return await db.query(
      'transactions',
      orderBy: 'id DESC',
    );
  }

  // =====================================================
  // SELECT - LẤY 1 GIAO DỊCH THEO ID
  // =====================================================

  Future<Map<String, dynamic>?> getTransactionById(
      int id,
      ) async {
    final db = await database;

    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // =====================================================
  // UPDATE - SỬA GIAO DỊCH
  // =====================================================

  Future<int> updateTransaction(
      int id,
      Map<String, dynamic> transaction,
      ) async {
    final db = await database;

    return await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =====================================================
  // DELETE - XÓA GIAO DỊCH
  // =====================================================

  Future<int> deleteTransaction(
      int id,
      ) async {
    final db = await database;

    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =====================================================
  // ĐÓNG DATABASE
  // =====================================================

  Future<void> close() async {
    final db = await database;

    await db.close();

    _database = null;
  }
}