import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_app/shared/index.dart';
import 'package:flutter_app/enum/index.dart';

// 聊天信息实体类
class ChatMessageModel {
  /// 主键ID
  int id = -1;

  /// 消息体ID
  String msgId = '';

  /// 创建时间
  int createTime = -1;

  /// 会话ID
  int conversationId = -1;

  /// 消息所属者
  String userId = '';

  /// 消息已读状态
  int isRead = yNStatusEnum['No'];

  /// 消息类型
  int type = messageTypeEnum["Text"];

  /// 消息内容
  String content = '';

  /// 消息发送失败原因
  String failReason = '';

  /// 时长
  int duration = 0;

  ///消息状态
  int state = -1;

  ChatMessageModel();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> _map = {
      "id": id == -1 ? null : id,
      "msgId": msgId,
      "conversationId": conversationId,
      "userId": userId,
      "isRead": isRead,
      "type": type,
      "content": content,
      "createTime": createTime,
      "failReason": failReason,
      "duration": duration,
      "state": state,
    };
    return _map;
  }

  ChatMessageModel.toOwnMessage(int msgType, String msgContent,
      {int mediaDuration = 0}) {
    userId = SharedPreferencesUtil.userInfo['userId'].toString();
    type = msgType;
    msgId = Uuid().v4(); //生成消息id
    content = msgContent;
    state = chatLogStatusEnum["Sending"];
    duration = mediaDuration;
  }

  ChatMessageModel.toModel(Map<String, dynamic> item) {
    id = item["id"];
    msgId = item["msgId"];
    conversationId = item["conversationId"];
    userId = item["userId"];
    isRead = item["isRead"];
    type = item["type"];
    content = item["content"];
    failReason = item['failReason'];
    createTime = int.parse(item["createTime"].toString());
    duration = item["duration"];
    state = item["state"];
  }

  ChatMessageModel.toMessage(Map<String, dynamic> message) {
    msgId = message["messageId"];
    type = message["messageType"];
    String receivedTime = message["createTime"];
    DateFormat dateFormat = DateFormat(
        "yyyy-MM-dd HH:mm:ss${receivedTime.length == 21 ? '.SSS' : ''}");
    DateTime dt = dateFormat.parse(receivedTime);
    createTime = dt.millisecondsSinceEpoch;
    userId = message["sourceId"];
    content = _getMsgContent(message);
    if (type == messageTypeEnum["Audio"] || type == messageTypeEnum["Video"]) {
      duration = int.parse(message["content"]);
    } else {
      duration = 0;
    }
    state = chatLogStatusEnum["Success"];
  }

  String _getMsgContent(Map<String, dynamic> msg) {
    int type = msg['messageType'];
    if (type == messageTypeEnum["Text"]) {
      return msg["content"];
    }
    if (type == messageTypeEnum["Image"]) {
      return msg["imageUrl"];
    }
    if (type == messageTypeEnum["Audio"]) {
      return msg["linkUrl"];
    }
    if (type == messageTypeEnum["Video"]) {
      return msg["linkUrl"];
    }
    return msg["content"];
  }

  List<String> getColumns() {
    return [
      "id",
      "msgId",
      "conversationId",
      "userId",
      "isRead",
      "type",
      "content",
      "createTime",
      "duration",
      "state",
    ];
  }
}
