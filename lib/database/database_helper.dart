import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'study_ease.db');
      return await openDatabase(
        path,
        version: 4, // Incremented version for schema changes
        onCreate: (db, version) async {
          // Create the users table
          await db.execute('''
            CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              email TEXT UNIQUE,
              password TEXT,
              user_type TEXT
            )
          ''');

          // Create the user_detail table linked to users
          await db.execute('''
            CREATE TABLE user_detail(
              id INTEGER PRIMARY KEY, 
              username TEXT, 
              user_fullname TEXT, 
              user_email TEXT UNIQUE, 
              course TEXT, 
              semester TEXT, 
              nric TEXT, 
              nophone TEXT, 
              age INTEGER,
              FOREIGN KEY (id) REFERENCES users (id) ON DELETE CASCADE
            )
          ''');

          // Create the events table
          await db.execute('''
            CREATE TABLE events(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              date TEXT,
              event TEXT,
              FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 4) {
            // Add the new user_detail table if upgrading
            await db.execute('''
              CREATE TABLE IF NOT EXISTS user_detail(
                id INTEGER PRIMARY KEY, 
                username TEXT, 
                user_fullname TEXT, 
                user_email TEXT UNIQUE, 
                course TEXT, 
                semester TEXT, 
                nric TEXT, 
                nophone TEXT, 
                age INTEGER,
                FOREIGN KEY (id) REFERENCES users (id) ON DELETE CASCADE
              )
            ''');
          }
        },
      );
    } catch (e) {
      print("Error initializing database: $e");
      rethrow;
    }
  }

  // Insert a new event into the events table
  Future<int> insertEvent(int userId, String date, String event) async {
    try {
      final db = await database;
      await db.rawQuery(
        'PRAGMA foreign_keys = ON',
      ); // Ensure foreign key constraints are enabled
      return await db.insert('events', {
        'user_id': userId,
        'date': date,
        'event': event,
      });
    } catch (e) {
      print("Error inserting event: $e");
      return -1;
    }
  }

  // Retrieve events for a specific user
  Future<List<Map<String, dynamic>>> getEvents(
    int userId,
    String dateStr,
  ) async {
    try {
      final db = await database;
      return await db.query(
        'events',
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, dateStr],
      );
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  // Delete event from the database
  Future<int> deleteEvent(int userId, String date, String event) async {
    try {
      final db = await database;
      return await db.delete(
        'events',
        where: 'user_id = ? AND date = ? AND event = ?',
        whereArgs: [userId, date, event],
      );
    } catch (e) {
      print("Error deleting event: $e");
      return -1;
    }
  }

  // Retrieve a user by email and password
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  // Insert a new user into the users table
  Future<int> insertUser(Map<String, dynamic> userData) async {
    try {
      final db = await database;
      return await db.insert(
        'users',
        userData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error inserting user: $e");
      return -1;
    }
  }

  // Insert user details into user_detail table
  Future<int> insertUserDetail(Map<String, dynamic> userDetails) async {
    try {
      final db = await database;
      // Ensure that user ID exists before inserting into user_detail table
      final user = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userDetails['id']],
      );

      if (user.isEmpty) {
        print(
          "User with ID ${userDetails['id']} does not exist in the users table.",
        );
        return -1; // Return -1 if the user doesn't exist
      }

      // Insert user details
      int result = await db.insert(
        'user_detail',
        userDetails,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Inserted user detail with result: $result"); // Debugging line

      return result;
    } catch (e) {
      print("Error inserting user details: $e");
      return -1;
    }
  }

  // Retrieve user details by user ID
  Future<Map<String, dynamic>?> getUserDetail(int userId) async {
    try {
      final db = await database;
      print("Fetching user detail for userId: $userId"); // Debugging line

      // Ensure the user exists in the users table
      final user = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      print("User exists: $user");

      if (user.isEmpty) {
        print("User with ID $userId does not exist in the users table.");
        return null; // Return null if user does not exist
      }

      // Query user details for the given userId
      final result = await db.query(
        'user_detail',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (result.isNotEmpty) {
        print("User detail found: ${result.first}");
        return result.first;
      } else {
        print("No user detail found for userId: $userId");
        return null;
      }
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  // Retrieve a user by userId (fetches the email and other basic user data)
  Future<Map<String, dynamic>?> getUserDataById(int userId) async {
    try {
      final db = await database;
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }
}
