import 'package:sqflite/sqflite.dart';

import 'package:flutter_app/service/base/index.dart';
import 'package:flutter_app/service/model/chatMessage.dart';
import 'package:flutter_app/utils/system.dart';

class ChatMessageController {
  static const String _tableName = 'chat_message';

  ///conversationId  会话ID
  ///userId  消息所属者ID
  ///msgId 消息ID
  ///content  消息内容
  ///msgType 消息类型
  ///isRead 消息是否已读
  ///createTime  消息时间
  /// state 消息状态
  ///failReason  发送失败理由
  static const String MSG_TABLE_SQL =
      " CREATE TABLE If NOT EXISTS  $_tableName" +
          '''( id integer primary key autoincrement,
      conversationId integer not null,
      userId text not null,
      msgId text not null UNIQUE,
      content text,
      failReason text,
      isRead integer ,
      state integer not null,
      type integer not null,
      createTime integer not null,
      duration integer)''';
  //建立索引 加快查询速度
  static const String MSG_INDEX_SQL =
      "CREATE INDEX  index_msg ON $_tableName (conversationId)";
  dynamic _db;
  DatabaseHelper _helper = DatabaseHelper();

  // 初始化数据库连接
  Future<void> _init() async {
    _db ??= await _helper.db;
  }

  // 初始化数据表
  Future<void> initTable() async {
    await _init();
    if (!await _helper.isExistTable(_tableName)) {
      await _db.execute(MSG_TABLE_SQL);
    }
  }

  /// 查询聊天信息
  Future<List<ChatMessageModel>> getChatMessages(
      int conversationId, int offset) async {
    List<ChatMessageModel> _result = [];
    try {
      await _init();
      List<Map<String, dynamic>> _query = await _db.query(_tableName,
          columns: <String>[],
          where: 'conversationId= ? ',
          orderBy: 'createTime desc ',
          limit: 20,
          offset: offset,
          whereArgs: [conversationId]);
      if (_query == null) {
        return _result;
      }
      _query.forEach((q) => _result.add(ChatMessageModel.toModel(q)));
      return _result;
    } catch (error) {
      SystemOptions.uploadSystemErrorLog(error.toString());
      return _result;
    }
  }

  /// 根据消息ID获取消息内容
  Future<ChatMessageModel> getChatMessageById(String msgId) async {
    try {
      await _init();
      List<Map<String, dynamic>> _query = await _db.query(_tableName,
          columns: ChatMessageModel().getColumns(),
          where: 'msgId = ?',
          whereArgs: [msgId]);
      if (_query.length > 0) {
        return ChatMessageModel.toModel(_query.first);
      }
      return ChatMessageModel();
    } catch (error) {
      SystemOptions.uploadSystemErrorLog(error.toString());
      return ChatMessageModel();
    }
  }

  Future<int> getChatMessageCount(
    int conversationId,
  ) async {
    try {
      await _init();
      List<Map<String, dynamic>> _query = await _db.query(_tableName,
          columns: ChatMessageModel().getColumns(),
          orderBy: 'createTime asc ',
          where: 'conversationId = ?',
          whereArgs: [conversationId]);
      return _query.length;
    } catch (error) {
      SystemOptions.uploadSystemErrorLog(error.toString());
      return 0;
    }
  }

  /// 插入消息
  Future<ChatMessageModel> addChatMessage(ChatMessageModel model) async {
    try {
      await _init();
      model.id = await _db.insert(_tableName, model.toMap());
      return model;
    } catch (error) {
      print(error);
      SystemOptions.uploadSystemErrorLog(error.toString());
      return model;
    }
  }

  /// 更新消息
  Future<int> updateChatMessage(ChatMessageModel model) async {
    try {
      await _init();
      int _count = await _db.update(_tableName, model.toMap(),
          where: 'id = ?', whereArgs: [model.id]);
      return _count;
    } catch (error) {
      SystemOptions.uploadSystemErrorLog(error.toString());
      return 0;
    }
  }

  /// 更新已读状态
  Future<int> updateChatMessageRead(int conversationId, int isRead) async {
    try {
      Map<String, dynamic> map = Map();
      map["isRead"] = isRead;
      await _init();
      int _count = await _db.update(_tableName, map,
          where: 'conversationId = ?', whereArgs: [conversationId]);
      return _count;
    } catch (error) {
      SystemOptions.uploadSystemErrorLog(error.toString());
      return 0;
    }
  }

  Future<int> updateChatMessageState(ChatMessageModel model) async {
    try {
      await _init();
      int _count = await _db.update(_tableName, model.toMap(),
          where: 'msgId = ?', whereArgs: [model.msgId]);
      return _count;
    } catch (error) {
      print(error);
      SystemOptions.uploadSystemErrorLog(error.toString());
      return 0;
    }
  }

  /// 删除消息
  Future<int> deleteChatMessage(int id) async {
    try {
      await _init();
      int _count =
          await _db.delete(_tableName, where: "id = ?", whereArgs: [id]);
      return _count;
    } catch (_) {
      return 0;
    }
  }

  ///删除会话消息
  Future<int> deleteConversationMessages(int conversationId) async {
    try {
      await _init();
      int _count = await _db.delete(_tableName,
          where: "conversationId = ?", whereArgs: [conversationId]);
      return _count;
    } catch (error) {
      SystemOptions.uploadSystemErrorLog(error.toString());
      return 0;
    }
  }
}
