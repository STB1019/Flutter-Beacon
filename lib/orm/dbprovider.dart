import 'package:Beacon/orm/task.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Desidero definire una classe che mi permetta di accedere al database(file)
/// senza dovermi preoccupare delle "noie" da Directory.
/// Inoltre, voglio che gestisca in autonomia, le azioni CRUD sul DB
class DBMS {
  /// Nome del file
  String _nameDBFile = "db.sqlite";

  // Pattern singleton
  static final DBMS _entity = DBMS.internal();
  factory DBMS() {
    return _entity;
  }
  DBMS.internal();

  // Variabile di comodo
  Database _db;

  Future<Database> get database async {
    if (_db == null) _db = await createDB();
    return _db;
  }

  /// Creazione DB, compresa logica di creazione file
  Future<Database> createDB() async {
    String path = await _create_file_db();
    print("PATH IS $path");
    Database obj_db =
        await openDatabase(
            path,
            version: 1,
            onOpen: (Database db) async {
              print("Open");
              return db;
            },
            onCreate: (Database db, int version) async {
              print("ON CREATE");
              List<dynamic> query = [TaskEntity];
              print("ON CREATE ${query}");
              query.forEach((sql) async {
                var buffer;
                try {
                  print("TEST");
                  print(sql.dbDropTable);
                  buffer = await db.rawQuery(sql.dbDropTable);
                } catch (e) {
                  print(e);
                  print(buffer);
                }
                print("TEST");
                buffer = await db.rawQuery(sql.dbCreateTable);
                print(sql.dbCreateTable);
                print("TEST 1");
                print(sql.dbCreateTable);
                print("TEST 2");
                print(buffer);
              });
                return db;
              }
            );
    print("END");
    return obj_db;
  }

  newObj({String table, List<String> keys, List<dynamic> values}) async {
    if (table == null || keys == null || values == null) return null;
    var db = await database;
    print(keys);
    print(values);
    var raw = await db.rawInsert(
        "INSERT INTO $table (${keys.join(",")})"
        " VALUES (${List.generate(keys.length, (_) => "?").join(",")})",
        values);
    return raw;
  }

  updateObj(tablename, {obj, where, whereArgs}) async {
    var db = await database;
    var res = await db.update(tablename, obj.toMap(),
        where: where, whereArgs: whereArgs);
    return res;
  }

  getObj(tablename, {distinct, columns, where, whereArgs, groupBy, having, orderBy, limit, offset}) async {
    var db = await database;
    var res = [];
    if (columns != null || where != null || whereArgs != null)
      res = await db.query(tablename,
          distinct: distinct,
          columns: columns,
          where: where,
          whereArgs: whereArgs,
          groupBy: groupBy,
          having: having,
          orderBy: orderBy,
          limit: limit,
          offset: offset);
    else
      res = await db.query(tablename);
    return res;
  }

  /// PRIVATE AREA

  Future<String> _create_file_db() async {
    return join(await getDatabasesPath(), _nameDBFile);
  }
}

class ModelEntity {
  ModelEntity();

  factory ModelEntity.fromMap(Map<String, dynamic> obj) {
    return ModelEntity();
  }

  factory ModelEntity.fromSQL(Map<String, dynamic> obj) {
    return ModelEntity();
  }

  static get dbCreateTable => "";

  static get dbDropTable => "";

  Map<String, dynamic> toMap() {
    return Map<String, dynamic>();
  }

  Map<String, dynamic> toSQL() {
    return Map<String, dynamic>();
  }

  static insert(DBMS db, ModelEntity obj, {String tableName}) async {
    await db.newObj(
        table: tableName,
        keys: List.castFrom<dynamic, String>(obj.toSQL().keys.toList()),
        values: List.castFrom<dynamic, dynamic>(obj.toSQL().values.toList()));
  }
}
