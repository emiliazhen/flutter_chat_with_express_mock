import 'package:sqflite/sqflite.dart';

import 'package:flutter_app/service/base/index.dart';
import 'package:flutter_app/shared/index.dart';
import 'package:flutter_app/utils/system.dart';
import 'package:flutter_app/service/model/conversation.dart';
import 'package:flutter_app/enum/index.dart';

class ConversationController {
  static const String _tableName = 'conversation';

  /// conversationId  会话ID
  /// chatUserId  接收方的ID
  /// trueName 消息接收方的真实姓名
  /// onLineStatus 消息接收方的在线状态
  /// userId 发送方ID
  /// lastMsgContent  最后一次消息内容
  /// lastMsgType  最后一次消息类型
  /// lastMsgTime  最后一次消息时间
  static const String CONVERSATION_TABLE_SQL =
      "CREATE TABLE  If NOT EXISTS  $_tableName" +
          '''(conversationId integer PRIMARY KEY,
          chatUserId text NOT NULL ,
          trueName text,
          onLineStatus integer,
          userId integer NOT NULL,
          lastContent text NOT NULL,
          lastContentType integer NOT NULL,
          isLastSendSuccess integer default(5) NOT NULL,
          lastContentTime text NOT NULL)''';
  dynamic _db;
  //建立索引 加快查询速度
  static const String CONVERSATION_INDEX_SQL =
      "CREATE INDEX  index_conversation ON $_tableName (conversationId,userId)";
  DatabaseHelper _helper = DatabaseHelper();
  int _userId = 0;

  // 初始化数据库连接
  Future<void> _init() async {
    _userId = SharedPreferencesUtil.userInfo['userId'] ?? 0;
    _db ??= await _helper.db;
  }

  // 初始化数据表
  Future<void> initTable() async {
    await _init();
    if (!await _helper.isExistTable(_tableName)) {
      await _db.execute(CONVERSATION_TABLE_SQL);
    }
  }

  /// 查询所有的会话
  Future<List<ConversationModel>> getConversations() async {
    List<ConversationModel> _result = [];
    await _init();
    String childSql =
        "(SELECT conversation.*, COUNT(*) AS `unReadCount` FROM Conversation AS conversation INNER JOIN chat_message msg ON conversation.conversationId = msg.conversationId WHERE msg.isRead = ? AND conversation.userId = ? GROUP BY conversation.conversationId) ";
    List<Map<String, dynamic>> _querys = await _db.rawQuery(
        'SELECT T1.*, ifnull(T2.unReadCount, 0) AS `unReadCount` FROM conversation AS T1 LEFT JOIN $childSql AS T2 ON T1.conversationId = T2.conversationId WHERE T1.userId = ? ORDER BY T1.lastContentTime DESC',
        [yNStatusEnum["No"], _userId, _userId]);
    if (_querys == null) {
      return _result;
    }
    _querys.forEach((q) {
      _result.add(ConversationModel.toModel(q));
    });

    return _result;
  }

  /// 根据会话ID获取会话
  Future<ConversationModel> getConversationById(int id) async {
    try {
      await _init();
      List<Map<String, dynamic>> _query = await _db.query(_tableName,
          columns: ConversationModel().getColumns(),
          where: 'id = ?',
          whereArgs: [id]);
      if (_query.length > 0) {
        return ConversationModel.toModel(_query.first);
      }
      return ConversationModel(); // 查询数据集为空 则返回空实体对象
    } catch (error) {
      SystemOptions.uploadSystemErrorLog(error.toString());
      return ConversationModel();
    }
  }

  /// 根据用户ID获取会话
  Future<ConversationModel> getConversationByUserId(String chatUserId) async {
    try {
      await _init();
      List<Map<String, dynamic>> _query = await _db.query(_tableName,
          columns: ConversationModel().getColumns(),
          where: 'chatUserId=? and userId=?',
          whereArgs: [chatUserId, _userId]);
      if (_query.length > 0) {
        return ConversationModel.toModel(_query.first);
      }
      return ConversationModel(); // 查询数据集为空 则返回空实体对象
    } catch (error) {
      SystemOptions.uploadSystemErrorLog(error.toString());
      return ConversationModel();
    }
  }

  /// 插入会话
  Future<ConversationModel> addConversation(ConversationModel model) async {
    try {
      await _init();
      _db.transaction((txn) async {
        List<Map<String, dynamic>> _query = await txn.query(_tableName,
            columns: ConversationModel().getColumns(),
            where: 'chatUserId=? and userId=?',
            whereArgs: [model.chatUserId, _userId]);
        if (_query.length > 0) {
          throw Exception("会话重复"); //如果存在会话，回滚事务
        }

        print('生成会话id：' + model.conversationId.toString());
        await txn.insert(_tableName, model.toMap());
      });

      return model;
    } catch (error) {
      print(error);
      SystemOptions.uploadSystemErrorLog(error.toString());
      return model;
    }
  }

  /// 更新会话
  void updateConversation(ConversationModel model) async {
    try {
      await _init();
      Future.delayed(Duration(milliseconds: 100), () async {
        int _count = await _db.update(_tableName, model.toMap(),
            where: 'conversationId = ? and userId= ?',
            whereArgs: [model.conversationId, _userId]);
        print('更新会话列表：$_count' + model.toMap().toString());
      });
    } catch (error) {
      SystemOptions.uploadSystemErrorLog(error.toString());
    }
  }

  ///更新会员信息列表：
  void updateMemberInfoConversation(ConversationModel model) async {
    try {
      await _init();
      Future.delayed(Duration(milliseconds: 100), () async {
        int _count = await _db.update(_tableName, model.toMemberInfoMap(),
            where: 'conversationId = ? and userId = ?',
            whereArgs: [model.conversationId, _userId]);
        print('更新会员信息列表：$_count ${model.toMap()}');
      });
    } catch (error) {
      SystemOptions.uploadSystemErrorLog(error.toString());
    }
  }

  /// 删除会话
  Future<int> deleteConversation(int conversationId) async {
    try {
      await _init();
      int _count = await _db.delete(_tableName,
          where: "conversationId = ? and userId=?",
          whereArgs: [conversationId, _userId]);

      return _count;
    } catch (error) {
      SystemOptions.uploadSystemErrorLog(error.toString());
      return 0;
    }
  }

  /// 搜索会话信息
  Future<List<ConversationModel>> searchConversation(String key) async {
    await _init();
    List<ConversationModel> _result = [];
    List<Map<String, dynamic>> _querys = await _db.query(_tableName,
        columns: [],
        where: 'userId = ? and (trueName LIKE  ?)',
        whereArgs: [_userId, '%$key%']);
    if (_querys == null) {
      return _result;
    }
    _querys.forEach((q) {
      _result.add(ConversationModel.toModel(q));
    });
    return _result;
  }
}
