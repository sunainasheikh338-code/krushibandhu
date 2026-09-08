import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static Database? _database;

  // ============================================================
  // ADMIN ACCOUNT
  // ============================================================

  static const String adminMobile = '9741634709';
  static const String adminPassword = 'Admin@12';

  // ============================================================
  // GET DATABASE
  // ============================================================

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  // ============================================================
  // INITIALIZE DATABASE
  // ============================================================

  static Future<Database> _initDatabase() async {
    final String path = join(
      await getDatabasesPath(),
      'krushibandhu.db',
    );

    return await openDatabase(
      path,

      // Keep version 2 so existing database is not unnecessarily
      // recreated.
      version: 2,

      // ========================================================
      // CREATE DATABASE
      // ========================================================

      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            mobile TEXT UNIQUE,
            village TEXT,
            land TEXT,
            crop TEXT,
            password TEXT,
            role TEXT DEFAULT 'farmer'
          )
        ''');
      },

      // ========================================================
      // DATABASE MIGRATION
      // ========================================================

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE users
            ADD COLUMN role TEXT DEFAULT 'farmer'
          ''');
        }
      },

      // ========================================================
      // CREATE / UPDATE ADMIN ACCOUNT
      // ========================================================

      onOpen: (db) async {
        await _createOrUpdateAdmin(db);
      },
    );
  }

  // ============================================================
  // CREATE OR UPDATE ADMIN
  // ============================================================

  static Future<void> _createOrUpdateAdmin(
    Database db,
  ) async {
    final existingAdmin = await db.query(
      'users',
      where: 'mobile = ?',
      whereArgs: [adminMobile],
      limit: 1,
    );

    if (existingAdmin.isEmpty) {
      // --------------------------------------------------------
      // CREATE ADMIN
      // --------------------------------------------------------

      await db.insert(
        'users',
        {
          'name': 'Admin',
          'mobile': adminMobile,
          'village': 'Admin',
          'land': '0',
          'crop': 'Admin',
          'password': adminPassword,
          'role': 'admin',
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      // --------------------------------------------------------
      // MAKE SURE EXISTING ADMIN NUMBER IS ADMIN
      // --------------------------------------------------------

      await db.update(
        'users',
        {
          'name': 'Admin',
          'password': adminPassword,
          'role': 'admin',
        },
        where: 'mobile = ?',
        whereArgs: [adminMobile],
      );
    }
  }

  // ============================================================
  // INSERT USER
  // ============================================================

  static Future<int> insertUser(
    Map<String, dynamic> user,
  ) async {
    final db = await database;

    final Map<String, dynamic> userData =
        Map<String, dynamic>.from(user);

    // Every newly registered user is a farmer.
    userData['role'] = 'farmer';

    return await db.insert(
      'users',
      userData,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<Map<String, dynamic>?> login(
    String mobile,
    String password,
  ) async {
    final db = await database;

    final List<Map<String, dynamic>> result =
        await db.query(
      'users',
      where: 'mobile = ? AND password = ?',
      whereArgs: [
        mobile,
        password,
      ],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // ============================================================
  // GET USER BY MOBILE
  // ============================================================

  static Future<Map<String, dynamic>?> getUserByMobile(
      String mobile,
      ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('mobile', isEqualTo: mobile)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;

      return {
        'id': doc.id,
        ...doc.data(),
      };
    }

    return null;
  }

  // ============================================================
  // UPDATE USER
  // ============================================================

  // static Future<int> updateUser(
  //   int id,
  //   Map<String, dynamic> user,
  // ) async {
  //   final db = await database;
  //
  //   return await db.update(
  //     'users',
  //     user,
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  static Future<void> updateUser(String id,
      Map<String, dynamic> user,) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update(user);
  }

  // ============================================================
  // GET ALL USERS
  // ============================================================

  // static Future<List<Map<String, dynamic>>> getUsers() async {
  //   final db = await database;
  //
  //   return await db.query(
  //     'users',
  //     orderBy: 'id DESC',
  //   );
  // }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  static Future<Map<String, dynamic>?> getUserById(String id,) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .get();

    if (doc.exists) {
      return {
        'id': doc.id,
        ...doc.data()!,
      };
    }

    return null;
  }

  // ============================================================
  // MAKE USER ADMIN
  // ============================================================

  // static Future<int> makeAdmin(int id) async {
  //   final db = await database;
  //
  //   return await db.update(
  //     'users',
  //     {
  //       'role': 'admin',
  //     },
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }

  static Future<void> makeAdmin(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({
      'role': 'admin',
    });
  }

  // ============================================================
  // MAKE USER FARMER
  // ============================================================

  static Future<int> makeFarmer(int id) async {
    final db = await database;

    return await db.update(
      'users',
      {
        'role': 'farmer',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // DELETE USER
  // ============================================================

  static Future<int> deleteUser(int id) async {
    final db = await database;

    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}