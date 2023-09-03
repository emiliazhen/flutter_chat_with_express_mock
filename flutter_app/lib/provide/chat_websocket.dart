import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/provide/command_list.dart';
// import 'package:flutter_app/components/notification_service.dart';
import 'package:flutter_app/provide/user_list.dart';
import 'package:web_socket_channel/io.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter_app/utils/config.dart';
import 'package:flutter_app/enum/index.dart';
import 'package:flutter_app/provide/chat_conversation.dart';
import 'package:flutter_app/provide/chat_message.dart';
import 'package:flutter_app/shared/index.dart';
import 'package:flutter_app/service/model/chatMessage.dart';
import 'package:flutter_app/service/model/conversation.dart';
import 'package:flutter_app/utils/system.dart';

/// websocket连接状态枚举
enum ConnectEnums { success, connect, fail, serverKill }

class WebSocketProvide with ChangeNotifier {
  /// socket连接状态
  var connecting = ConnectEnums.fail;

  /// 最大重连次数
  final int maxRetryCount = 3;

  /// 重连次数
  int _retryCount = 0;

  IOWebSocketChannel? _channel;

  /// 设备信息
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  /// 连接
  connectWebsocket(BuildContext context) async {
    if (connecting == ConnectEnums.fail ||
        connecting == ConnectEnums.serverKill) {
      connecting = ConnectEnums.connect;
      Map<String, dynamic> header = {};
      header["access-token"] = SharedPreferencesUtil.userInfo['userId'];
      print(header["access-token"]);
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      header["deviceId"] = androidInfo.id;
      print(header["deviceId"]);
      await Provider.of<ConversationProvide>(context, listen: false)
          .cleanConversation();
      await Provider.of<ConversationProvide>(context, listen: false)
          .getConversations();
      Provider.of<ConversationProvide>(context, listen: false)
          .webSocketConnection(websocketLinkStatusEnum["Linking"]);
      _channel = IOWebSocketChannel.connect(Config.im, headers: header);

      /// 监听到服务器返回消息
      _channel!.stream.listen((data) => listenMessage(context, data),
          onError: (error) {
        onError(context, error);
        print('🐛');
        print(error);
      }, onDone: () {
        if (connecting == ConnectEnums.success) {
          connecting = ConnectEnums.serverKill;
          Provider.of<ConversationProvide>(context, listen: false)
              .webSocketConnection(websocketLinkStatusEnum["LinKFail"]);
        }
      });
    }
  }

  /// 发送消息
  sendMessage(BuildContext context, ConversationModel conversation,
      ChatMessageModel message) async {
    Map<String, dynamic> sendData = {};
    int msgTyp = message.type;
    sendData['messageType'] = msgTyp;
    if (msgTyp == messageTypeEnum["Text"]) {
      sendData['content'] = message.content;
    } else if (msgTyp == messageTypeEnum["Image"]) {
      sendData['imageUrl'] = message.content;
    } else if (msgTyp == messageTypeEnum["Audio"] ||
        msgTyp == messageTypeEnum["Video"]) {
      sendData['linkUrl'] = message.content;
      sendData['content'] = message.duration;
    }
    sendData['messageId'] = message.msgId;
    sendData["targetId"] = conversation.chatUserId;
    String jsonSendData = json.encode(sendData);
    await handleSendMessage(context, conversation, message);
    _channel!.sink.add(jsonSendData);
  }

  /// 处理发送方消息
  handleSendMessage(BuildContext context, ConversationModel conversation,
      ChatMessageModel message) async {
    int conversationId;
    if (!await SystemOptions.isNetConnectivity() ||
        connecting == ConnectEnums.fail) {
      message.failReason = "恢复网络后，点击可以重新发送成功";
      message.state = chatLogStatusEnum["Failed"];
    }
    if (connecting == ConnectEnums.serverKill) {
      message.failReason = "连接服务器失败";
      message.state = chatLogStatusEnum["Failed"];
    }
    conversation.lastContent = message.content;
    conversation.lastContentType = message.type;
    conversation.isLastSendSuccess = message.state;
    conversation.lastContentTime = message.createTime;
    if (conversation.conversationId == -1) {
      conversation.conversationId =
          (conversation.chatUserId + message.msgId).hashCode;
      await Provider.of<ConversationProvide>(context, listen: false)
          .addConversation(conversation, message);
      conversationId = conversation.conversationId;
    } else {
      await Provider.of<ConversationProvide>(context, listen: false)
          .updateConversation(conversation, message);
      conversationId = conversation.conversationId;
    }
    message.conversationId = conversationId;
    await Provider.of<ChatMessageProvide>(context, listen: false)
        .receivedMessage(message);
  }

  /// 处理接收方消息
  handleReceivedMessage(
      BuildContext context, String fromId, ChatMessageModel message) async {
    int conversationId = -1;
    bool isExist = Provider.of<ConversationProvide>(context, listen: false)
        .checkConversation(fromId);
    print('是否已存在会话列表页面：$isExist');
    if (!isExist) {
      ConversationModel addConversation = _createConversation(fromId, message);
      addConversation.conversationId =
          (addConversation.chatUserId + message.msgId).hashCode;
      await Provider.of<ConversationProvide>(context, listen: false)
          .addConversation(addConversation, message);
      _getMemberInfo(context, fromId, message);
      conversationId = addConversation.conversationId;
      // NotificationService().showNotifications(int.parse(fromId), addConversation.trueName, message.content, message.msgId);
    } else {
      ConversationModel conversation =
          Provider.of<ConversationProvide>(context, listen: false)
              .getConversationByUserId(fromId);
      print('id----${conversation.conversationId}');
      if (message.createTime >= conversation.lastContentTime) {
        conversation.lastContent = message.content;
        conversation.lastContentType = message.type;
        conversation.isLastSendSuccess = message.state;

        /// 收到消息就将离线变在线
        conversation.onLineStatus = yNStatusEnum["Yes"];
        conversation.lastContentTime = message.createTime;
        conversationId = conversation.conversationId;
        await Provider.of<ConversationProvide>(context, listen: false)
            .updateConversation(conversation, message);
        // NotificationService().showNotifications(int.parse(fromId), conversation.trueName, message.content, message.msgId);
      }
    }
    message.conversationId = conversationId;
    Provider.of<ChatMessageProvide>(context, listen: false)
        .receivedMessage(message);
  }

  /// 处理重推消息
  _handleRePushMessage(
      BuildContext context, String from, ChatMessageModel newMessage) async {
    ChatMessageModel message =
        await Provider.of<ChatMessageProvide>(context, listen: false)
            .getMessageById(newMessage.msgId);

    if (message == null || message.id == null) {
      ConversationModel conversation =
          Provider.of<ConversationProvide>(context, listen: false)
              .getConversationByUserId(from);

      if (conversation.conversationId != null) {
        newMessage.conversationId = conversation.conversationId;
        if (DateTime.fromMillisecondsSinceEpoch(newMessage.createTime)
                .compareTo(DateTime.fromMillisecondsSinceEpoch(
                    conversation.lastContentTime)) >=
            0) {
          conversation.lastContent = message.content;
          conversation.lastContentType = message.type;
          conversation.isLastSendSuccess = message.state;
          conversation.lastContentTime = message.createTime;
          await Provider.of<ConversationProvide>(context, listen: false)
              .updateConversation(conversation, newMessage);
        }
        print('重新推送消息插入');
        Provider.of<ChatMessageProvide>(context, listen: false)
            .receivedMessage(newMessage);
      }
    }
  }

  /// 创建会话
  _createConversation(String chatUserId, message) {
    Map<String, dynamic> conversationInfo = {};
    conversationInfo["memberId"] = chatUserId;
    conversationInfo["trueName"] = "";
    conversationInfo["onlineStatus"] = yNStatusEnum["No"];
    return ConversationModel.toConversation(conversationInfo, message);
  }

  /// 获取用户信息
  _getMemberInfo(BuildContext context, String memberId, message) async {
    List<dynamic> userList =
        Provider.of<UserListProvide>(context, listen: false).list;
    dynamic curUser = null;
    for (int i = 0; i < userList.length; i++) {
      if (userList[i]['userId'].toString() == memberId) {
        curUser = userList[i];
        break;
      }
    }
    if (curUser != null) {
      ConversationModel model = ConversationModel();
      model = ConversationModel.toConversation({
        'memberId': curUser['userId'],
        'trueName': curUser['name'],
      }, message);
      await Provider.of<ConversationProvide>(context, listen: false)
          .updateConversationMemberInfo(model);
    }
  }

  /// 监听消息
  listenMessage(context, data) async {
    //处理多消息
    String newDataJson = "[" + data.replaceAll('}{', '},{') + "]";
    List msgList = json.decode(newDataJson);
    print("====listenMessage 💌 =======$data========");
    for (int i = 0; i < msgList.length; i++) {
      Map<String, dynamic> data = msgList[i];
      int command = data["command"];
      if (data["code"] == "CORRECT") {
        if (command == appCommandTypesEnum["LinkSuccess"]) {
          /// 连接成功
          connecting = ConnectEnums.success;
          Provider.of<ConversationProvide>(context, listen: false)
              .webSocketConnection(websocketLinkStatusEnum["LinkComplete"]);
        } else if (command == appCommandTypesEnum["ReceiveMessage"]) {
          /// 接收消息
          Map<String, dynamic> message = data["reqData"] is String
              ? json.decode(data["reqData"])
              : data["reqData"];
          ChatMessageModel newMessage = ChatMessageModel.toMessage(message);

          /// 通知后台，app接收到发来的消息
          _channel!.sink
              .add(json.encode({'messageType': messageTypeEnum['Ack']}));
          await handleReceivedMessage(context, message["sourceId"], newMessage);
        } else if (command == appCommandTypesEnum["System"]) {
          /// 系统
          SharedPreferences sp = await SharedPreferences.getInstance();
          sp.setBool("isOnlyDevice", true);

          /// todo: 退出登录 清空token
        } else if (command == appCommandTypesEnum["CommandUnread"]) {
          /// 指令未读数量
          Map<String, dynamic> message = data["reqData"] is String
              ? json.decode(data["reqData"])
              : data["reqData"];
          Provider.of<CommandListProvide>(context, listen: false)
              .setUnreadCount(int.parse(message['content']));
        } else if (command == appCommandTypesEnum["SendSuccess"]) {
          /// 发送成功
          Map<String, dynamic> message = data["reqData"] is String
              ? json.decode(data["reqData"])
              : data["reqData"];
          String msgId = message["messageId"];
          Provider.of<ChatMessageProvide>(context, listen: false)
              .sendMessageSuccess(msgId);
          ConversationModel conversation =
              Provider.of<ConversationProvide>(context, listen: false)
                  .getConversationByUserId(message["targetId"]);
          ChatMessageModel successMessage =
              await Provider.of<ChatMessageProvide>(context, listen: false)
                  .getMessageById(message["messageId"]);
          print('🛴====消息发送者ID====${conversation.userId}');
          print('🚐====会话ID====${conversation.conversationId}');
          // 如果会话列表当前最新消息还是已发消息，就更新消息状态
          if (successMessage.content == conversation.lastContent) {
            successMessage.state = chatLogStatusEnum['Success'];
            await Provider.of<ConversationProvide>(context, listen: false)
                .updateConversation(conversation, successMessage);
          }
        } else if (command == appCommandTypesEnum["RePush"]) {
          /// 重推
          Map<String, dynamic> message = data["reqData"] is String
              ? json.decode(data["reqData"])
              : data["reqData"];
          ChatMessageModel newMessage = ChatMessageModel.toMessage(message);
          _handleRePushMessage(context, message["sourceId"], newMessage);
        } else if (command == appCommandTypesEnum["OnlineOrOffline"]) {}
        if (command == appCommandTypesEnum["Ack"]) {
          // 客户端确认收到消息
        } else {}
      } else {
        if (command == appCommandTypesEnum["SendFail"] ||
            command == appCommandTypesEnum["Error"]) {
          Map<String, dynamic> message;
          if (data['Data'] != null) {
            Map<String, dynamic> message = data["reqData"] is String
                ? json.decode(data["reqData"])
                : data["reqData"];
            await Provider.of<ChatMessageProvide>(context, listen: false)
                .sendMessageFail(message["messageId"], data["message"]);
            ConversationModel conversation =
                Provider.of<ConversationProvide>(context, listen: false)
                    .getConversationByUserId(message["targetId"]);
            conversation.isLastSendSuccess = chatLogStatusEnum['Failed'];
            ChatMessageModel failMessage =
                await Provider.of<ChatMessageProvide>(context, listen: false)
                    .getMessageById(message["messageId"]);
            await Provider.of<ConversationProvide>(context, listen: false)
                .updateConversation(conversation, failMessage);
          }
        }
      }
    }
  }

  /// socket 连接出错
  onError(BuildContext context, error) {
    print('💥 error------------>$error');
    connecting = ConnectEnums.fail;
    _retryCount++;
    print("🔗 开始重连。。。。。。。。。。");
    Provider.of<ConversationProvide>(context, listen: false)
        .webSocketConnection(websocketLinkStatusEnum["LinKFail"]);
    if (_retryCount <= maxRetryCount) {
      connectWebsocket(context);
    }
  }

  /// 关闭socket
  closeWebSocket(BuildContext context) {
    print("🔴 手动关闭websocket连接");
    connecting = ConnectEnums.fail;
    Provider.of<ConversationProvide>(context, listen: false)
        .webSocketConnection(websocketLinkStatusEnum["LinKFail"]);
    _channel!.sink.close();
  }

  /// ! 开启聊天测试 （后期删除）
  openTestChat(BuildContext context) {
    _channel!.sink.add(json.encode({'messageType': 999}));
  }

  /// ! 关闭聊天测试（后期删除）
  closeTestChat(BuildContext context) {
    _channel!.sink.add(json.encode({'messageType': -999}));
  }
}
