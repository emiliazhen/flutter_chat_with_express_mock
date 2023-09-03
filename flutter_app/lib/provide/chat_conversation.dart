import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/service/model/conversation.dart';
import 'package:flutter_app/service/model/chatMessage.dart';
import 'package:flutter_app/service/controller/conversation.dart';
import 'package:flutter_app/enum/index.dart';
import 'package:flutter_app/provide/chat_message.dart';
import 'package:flutter_app/shared/index.dart';

class ConversationProvide with ChangeNotifier {
  /// 当前用户会话列表
  List<ConversationModel> conversations = [];

  /// 连接状态
  int connectState = websocketLinkStatusEnum["Linking"];

  /// 会话控制器
  final ConversationController _controller = ConversationController();

  void webSocketConnection(int connection) {
    connectState = connection;
    notifyListeners();
  }

  init() {
    _controller.initTable();
    notifyListeners();
  }

  /// 添加对话
  Future<void> addConversation(
      ConversationModel conversation, ChatMessageModel message) async {
    conversations.insert(0, conversation);
    String userId = message.userId;
    bool isMeMessage =
        ChatMessageProvide.curConversation.chatUserId == userId ||
            userId == SharedPreferencesUtil.userInfo['userId'].toString();
    if (!isMeMessage) {
      conversation.unReadCount = conversation.unReadCount + 1;
    }
    _controller.addConversation(conversation);
    _sortConversations();
    notifyListeners();
  }

  /// 更新对话
  updateConversation(ConversationModel model, ChatMessageModel message) async {
    ConversationModel conversation = getConversationByUserId(model.chatUserId);
    message.createTime = message.createTime == -1
        ? DateTime.now().millisecondsSinceEpoch
        : message.createTime;
    // 会话列表消息保留当前时间最新的消息
    if (message.createTime >= conversation.lastContentTime) {
      conversation.lastContent = message.content;
      conversation.lastContentType = message.type;
      conversation.isLastSendSuccess = message.state;
      conversation.onLineStatus = model.onLineStatus; //在线状态
      conversation.lastContentTime = message.createTime;
      String userId = message.userId;
      bool isMeMessage =
          ChatMessageProvide.curConversation.chatUserId == userId ||
              userId == SharedPreferencesUtil.userInfo['userId'].toString();
      if (!isMeMessage) {
        model.unReadCount = model.unReadCount + 1;
      }
      _controller.updateConversation(model);
      _sortConversations();
      notifyListeners();
    }
  }

  /// 更新会话人信息
  updateConversationMemberInfo(ConversationModel model) async {
    ConversationModel conversation = getConversationByUserId(model.chatUserId);
    conversation.trueName = model.trueName;
    conversation.onLineStatus = model.onLineStatus;
    _controller.updateMemberInfoConversation(conversation);
    notifyListeners();
  }

  ///获取聊天人ID会话
  ConversationModel getConversationByUserId(String chatUserId) {
    ConversationModel model = ConversationModel();
    for (int i = 0; i < conversations.length; i++) {
      if (conversations[i].chatUserId == chatUserId) {
        model = conversations[i];
        break;
      }
    }
    return model;
  }

  /// 检查会话是否存在
  bool checkConversation(String chatUserId) {
    bool isExit = false;
    for (int i = 0; i < conversations.length; i++) {
      if ((conversations[i].chatUserId == chatUserId) &&
          (conversations[i].userId ==
              SharedPreferencesUtil.userInfo['userId'])) {
        isExit = true;
        break;
      }
    }
    return isExit;
  }

  /// 清除消息状态
  cleanMessageState(BuildContext context, String chatUserId) async {
    ConversationModel model = getConversationByUserId(chatUserId);
    if (model.conversationId != null) {
      model.unReadCount = 0;
      notifyListeners();
    }
    Provider.of<ChatMessageProvide>(context, listen: false)
        .cleanMessageState(model.conversationId);
  }

  /// 搜索会话列表
  Future<List<ConversationModel>> searchConversation(String key) async {
    return _controller.searchConversation(key);
  }

  /// 排序会话
  _sortConversations() {
    conversations.sort((ConversationModel left, ConversationModel right) {
      return right.lastContentTime.compareTo(left.lastContentTime);
    });
  }

  /// 获取所有人会话
  getConversations() async {
    conversations = await _controller.getConversations();
    notifyListeners();
  }

  /// 删除会话
  delConversation(BuildContext context, ConversationModel conversation) async {
    conversations.remove(conversation);
    await _controller.deleteConversation(conversation.conversationId);
    Provider.of<ChatMessageProvide>(context, listen: false)
        .delChatMessages(conversation.conversationId);
    notifyListeners();
  }

  /// 清除上次登录人的会话
  cleanConversation() {
    print("清除上次登录人的会话");
    conversations = [];
  }
}
