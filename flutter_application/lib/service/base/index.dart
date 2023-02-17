import 'package:sqflite/sqflite.dart';

import 'package:flutter_application/utils/config.dart';
import 'package:flutter_application/service/controller/chatMessage.dart';
import 'package:flutter_application/service/controller/conversation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static String _name = 'hr.db';
  static String _path = '';
  static dynamic _database;
  Future<Database> get db async {
    print('💤----$_database');
    if (_database != null) {
      return _database;
    }
    _database = await init();
    return _database;
  }

  DatabaseHelper.internal();
  static Future<Database> init() async {
    _path = '${await getDatabasesPath()}/$_name';
    _database = await openDatabase(_path, version: Config.databaseVersion, onCreate: (Database db, int version) {
      print('😆 Create');
      db.execute(ChatMessageController.MSG_TABLE_SQL);
      db.execute(ConversationController.CONVERSATION_TABLE_SQL);
      db.execute(ChatMessageController.MSG_INDEX_SQL);
      db.execute(ConversationController.CONVERSATION_INDEX_SQL);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      var batch = db.batch();
      print(oldVersion);
      if (oldVersion == 1) {
        /// TODO:
      }
      await batch.commit();
    });
    return _database;
  }

  /// 删库
  static delete() async {
    try {
      await deleteDatabase(_path);
    } catch (_) {
      print('删除数据库失败');
    }
  }

  /// 表是否存在
  Future<bool> isExistTable(String tableName) async {
    bool _result = false;
    if (tableName == null) {
      return false;
    }
    try {
      Database _db = await db;
      String sql = "select count(*) from sqlite_master where type ='table' and name ='${tableName.trim()}'";
      var cursor = await _db.rawQuery(sql, null);
      if (cursor.length > 0) {
        _result = true;
      }
      return _result;
    } catch (e) {
      return false;
    }
  }

  /// 字段是否存在
  static Future<bool> isFieldExist(Database db, String tableName, String fieldName) async {
    bool _result = false;
    if (tableName == null) {
      return false;
    }
    try {
      String sql = "select * from sqlite_master where name='$tableName' and sql like '%$fieldName%';  ";
      List<Map<String, dynamic>> cursor = await db.rawQuery(sql, null);
      if (cursor != null && cursor.length > 0) {
        Map<String, dynamic> data = cursor[0];
        String sql = data["sql"];
        if (sql.contains(fieldName)) {
          return true;
        } else {
          return false;
        }
      }
      return _result;
    } catch (e) {
      return false;
    }
  }
}
