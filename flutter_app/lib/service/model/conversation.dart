import 'package:flutter_app/shared/index.dart';
import 'package:flutter_app/enum/index.dart';
import 'package:flutter_app/service/model/chatMessage.dart';

/// 会话实体类
class ConversationModel {
  /// 主键ID
  int conversationId = -1;

  /// 会话所属用户ID
  int userId = -1;

  /// 会话用户ID
  String chatUserId = '';

  /// 会话用户真实姓名
  String trueName = '';

  /// 在线状态
  int onLineStatus = yNStatusEnum['No'];

  /// 最后通信内容
  String lastContent = '';

  /// 最后通信时间
  int lastContentTime = 0;

  ///  最后通信内容类型
  int lastContentType = messageTypeEnum["Text"];

  ///  未读消息数
  int unReadCount = 0;

  /// 最后一条是否未发出
  int isLastSendSuccess = -1;

  ConversationModel();

  ConversationModel.toModel(Map<String, dynamic> item) {
    conversationId = item["conversationId"];
    userId = item["userId"];
    trueName = item["trueName"];
    onLineStatus = item["onLineStatus"];
    lastContent = item["lastContent"];
    chatUserId = item["chatUserId"];
    lastContentType = item["lastContentType"];
    lastContentTime = int.parse(item["lastContentTime"]);
    unReadCount = item["unReadCount"];
    isLastSendSuccess = item["isLastSendSuccess"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> _map = {
      "trueName": trueName,
      "chatUserId": chatUserId,
      "onLineStatus": onLineStatus,
      "lastContent": lastContent,
      "lastContentType": lastContentType,
      "lastContentTime": lastContentTime,
      "userId": userId,
      "isLastSendSuccess": isLastSendSuccess,
    };
    if (conversationId != null) {
      _map["conversationId"] = conversationId;
    }
    return _map;
  }

  Map<String, dynamic> toMemberInfoMap() {
    Map<String, dynamic> _map = {
      "trueName": trueName,
      "onLineStatus": onLineStatus,
    };
    if (conversationId != null) {
      _map["conversationId"] = conversationId;
    }
    return _map;
  }

  ConversationModel.toConversation(
      Map<String, dynamic> conversationUser, ChatMessageModel message) {
    chatUserId = conversationUser["memberId"].toString();
    trueName = conversationUser["trueName"] ?? '';
    isLastSendSuccess = message.state;
    lastContentTime = DateTime.now().millisecondsSinceEpoch;
    lastContent = message.content;
    lastContentType = message.type;
    userId = SharedPreferencesUtil.userInfo['userId'];
    onLineStatus = conversationUser["onlineStatus"] ?? yNStatusEnum["No"];
  }

  List<String> getColumns() {
    return [
      "conversationId",
      "userId",
      "chatUserId",
      "trueName",
      "lastContent",
      "lastContentType",
      "onLineStatus",
      "lastContentTime",
      "isLastSendSuccess"
    ];
  }
}
