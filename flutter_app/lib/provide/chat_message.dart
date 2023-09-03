import 'package:flutter/cupertino.dart';

import 'package:flutter_app/enum/index.dart';
import 'package:flutter_app/service/model/chatMessage.dart';
import 'package:flutter_app/service/model/conversation.dart';
import 'package:flutter_app/service/controller/chatMessage.dart';
import 'package:flutter_app/shared/index.dart';

class ChatMessageProvide with ChangeNotifier {
  ///当前正在聊天消息历史记录
  List<ChatMessageModel> curMessages = [];

  List<ChatMessageModel> get messages => curMessages;

  /// 正在聊天会话
  static ConversationModel curConversation = ConversationModel();

  final ChatMessageController _messageController = ChatMessageController();

  final _pageSize = 20;
  bool hasMore = false;

  /// 消息数量
  int count = 0;

  /// 初始化表
  initTable() {
    _messageController.initTable();
  }

  ///  接收消息
  receivedMessage(ChatMessageModel message) async {
    // 消息发送者id
    String userId = message.userId;
    //判断此消息是否属于当前会话或者自己发送消息
    bool isMeMessage = curConversation.chatUserId == userId ||
        userId == SharedPreferencesUtil.userInfo['userId'].toString();
    message.isRead = isMeMessage ? yNStatusEnum['Yes'] : yNStatusEnum["No"];
    message.createTime = message.createTime;

    if (message.conversationId != null) {
      ChatMessageModel addChatMessage =
          await _messageController.addChatMessage(message);
      if (addChatMessage.id == null) {
        //如果插入数据库不成功，就不更新页面
        return;
      }
    }
    if (isMeMessage &&
        message.conversationId == curConversation.conversationId) {
      curMessages.insert(0, message);
      _sortMessages();
      count = await _messageController
          .getChatMessageCount(message.conversationId); //获取消息数量
      notifyListeners();
    }
  }

  ///排序消息
  _sortMessages() {
    curMessages.sort((ChatMessageModel left, ChatMessageModel right) {
      return right.createTime.compareTo(left.createTime);
    });
  }

  /// 消息发送失败
  sendMessageFail(String msgId, String failReason) async {
    ChatMessageModel message = await getMessageById(msgId);
    message.failReason = failReason;
    message.state = chatLogStatusEnum["Failed"];
    _messageController.updateChatMessageState(message);
    notifyListeners();
  }

  /// 消息发送成功
  sendMessageSuccess(String msgId) async {
    ChatMessageModel messageModel = await getMessageById(msgId);
    messageModel.state = chatLogStatusEnum["Success"];
    _messageController.updateChatMessageState(messageModel);
    notifyListeners();
  }

  /// 通过消息id 获取消息
  Future<ChatMessageModel> getMessageById(String msgId) async {
    ChatMessageModel message = ChatMessageModel();
    for (int i = 0; i < curMessages.length; i++) {
      if (curMessages[i].msgId == msgId) {
        message = curMessages[i];
        break;
      }
    }
    if (message.msgId == '') {
      message = await _messageController.getChatMessageById(msgId);
    }
    return message;
  }

  /// 更新消息状态
  cleanMessageState(int conversationId) {
    curMessages.clear(); //清除缓存的消息数据
    if (conversationId != null) {
      _messageController.updateChatMessageRead(
          conversationId, yNStatusEnum["Yes"]); //标记消息已读状态
    }
  }

  /// 更新消息
  updateChatMessage(ChatMessageModel model) async {
    await _messageController.updateChatMessage(model);
    notifyListeners();
  }

  /// 分页获取消息
  getChatMessages(int conversationId) async {
    count = await _messageController.getChatMessageCount(conversationId);
    List<ChatMessageModel> messages = await _messageController.getChatMessages(
        conversationId, curMessages.length);
    curMessages.addAll(messages);
    hasMore = messages.length == _pageSize;
    notifyListeners();
  }

  /// 删除某个会话下所有消息
  delChatMessages(int conversationId) async {
    await _messageController.deleteConversationMessages(conversationId);
    curMessages = [];
    count = 0;
    notifyListeners();
  }

  /// 清除个人信息
  static cleanChat() {
    curConversation = ConversationModel();
  }
}
