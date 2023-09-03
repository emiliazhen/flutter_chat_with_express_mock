import 'package:provider/provider.dart';

import 'package:flutter_app/provide/chat_message.dart';
import 'package:flutter_app/provide/chat_conversation.dart';
import 'package:flutter_app/provide/chat_websocket.dart';
import 'package:flutter_app/provide/chat_sound.dart';
import 'package:flutter_app/provide/user_list.dart';
import 'package:flutter_app/provide/command_list.dart';

class ProvideGlobal {
  final List<ChangeNotifierProvider> _providers = [];
  get providers => _providers;

  final ChatMessageProvide _chatMessageProvide = ChatMessageProvide();
  final ConversationProvide _conversationProvide = ConversationProvide();
  final WebSocketProvide _webSocketProvide = WebSocketProvide();
  final ChatSoundProvide _chatSoundProvide = ChatSoundProvide();
  final UserListProvide _userListProvide = UserListProvide();
  final CommandListProvide _commandListProvide = CommandListProvide();

  ProvideGlobal() {
    _providers.add(ChangeNotifierProvider<ChatMessageProvide>(
        create: (ctx) => _chatMessageProvide));
    _providers.add(ChangeNotifierProvider<ConversationProvide>(
        create: (ctx) => _conversationProvide));
    _providers.add(ChangeNotifierProvider<WebSocketProvide>(
        create: (ctx) => _webSocketProvide));
    _providers.add(ChangeNotifierProvider<ChatSoundProvide>(
        create: (ctx) => _chatSoundProvide));
    _providers.add(ChangeNotifierProvider<UserListProvide>(
        create: (ctx) => _userListProvide));
    _providers.add(ChangeNotifierProvider<CommandListProvide>(
        create: (ctx) => _commandListProvide));
  }

  init(context) async {
    // context = myGlobals.scaffoldKey.currentContext;
    await _conversationProvide.init();
    await _chatMessageProvide.initTable();

    /// todo: 首次进来做用户选择页面
    Provider.of<WebSocketProvide>(context, listen: false)
        .connectWebsocket(context);
  }
}
