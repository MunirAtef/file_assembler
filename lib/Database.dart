
import 'package:sqflite/sqflite.dart' show Database, getDatabasesPath, openDatabase;
import 'package:path/path.dart' show join;

class FilesPath {
  static Database? _db;

  Future<Database?> get db async {
    _db ??= await buildDatabase();

    return _db;
  }

  buildDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "filesPathDb.db");   //add path to name  =>    join(str1, str2, str3, ...) == str1/str2/str3/...
    Database myDatabase = await openDatabase(path, onCreate: _onCreate, version: 1);  //, onUpgrade: _onUpgrade
    return myDatabase;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE files (
        id INTEGER PRIMARY KEY,
        name TEXT,
        favorite INTEGER
      )
    ''');
  }


  readData(String condition) async {
    String sql = "SELECT * FROM 'files' WHERE $condition";
    Database? myDatabase = await db;
    List<Map> response = await myDatabase!.rawQuery(sql);
    return response;
  }


  insertData(String name) async {
    String sql = "INSERT INTO 'files' ('name', 'favorite') VALUES ('$name', 0)";
    Database? myDatabase = await db;
    int response = await myDatabase!.rawInsert(sql);  //response = 0 if it failed
    return response;
  }

  updateData(String condition, String data) async {
    String sql = "UPDATE 'files' SET $data WHERE $condition";
    Database? myDatabase = await db;
    int response = await myDatabase!.rawUpdate(sql);
    return response;
  }

  deleteData(String condition) async {
    String sql = "DELETE FROM 'files' WHERE $condition";
    Database? myDatabase = await db;
    int response = await myDatabase!.rawDelete(sql);
    return response;
  }
}

