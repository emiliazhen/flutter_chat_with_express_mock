import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/provide/chat_conversation.dart';
import 'package:flutter_application/provide/chat_websocket.dart';
import 'package:flutter_application/provide/index.dart';
import 'package:flutter_application/utils/global_context.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_application/pages/home.dart';
import 'package:flutter_application/pages/find.dart';
import 'package:flutter_application/pages/mine.dart';
import 'package:flutter_application/pages/chat_manager.dart';
import 'package:provider/provider.dart';

class IndexNavigator extends StatefulWidget {
  final int index;
  const IndexNavigator({Key? key, this.index = 0}) : super(key: key);

  @override
  State<IndexNavigator> createState() => _IndexNavigatorState();
}

class _IndexNavigatorState extends State<IndexNavigator> with WidgetsBindingObserver {
  final Color _defaultColor = Colors.grey;
  final Color _activeColor = Colors.blue;
  final IconData _iconHome = const IconData(0xe65f, fontFamily: 'myfont', matchTextDirection: true);
  final IconData _iconFind = const IconData(0xe65c, fontFamily: 'myfont', matchTextDirection: true);
  final IconData _iconMessage = const IconData(0xe65b, fontFamily: 'myfont', matchTextDirection: true);
  final IconData _iconMine = const IconData(0xe659, fontFamily: 'myfont', matchTextDirection: true);

  /// 双击最后时间
  int _last = 0;

  /// 当前索引
  late int _currentIndex;

  /// 页面显示控制器
  late final PageController _pageController;

  /// 网络状态
  late StreamSubscription<ConnectivityResult> _connectivity;

  /// 双回退
  Future<bool> _doubleClickBack() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _last > 1500 || _last == 0) {
      setState(() {
        _last = now;
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addObserver(this);
    ProvideGlobal().init(context);
    _connectivity = Connectivity().onConnectivityChanged.listen((event) async {
      switch (event) {
        case ConnectivityResult.wifi:
          Provider.of<WebSocketProvide>(context, listen: false).connectWebsocket(context);
          break;
        case ConnectivityResult.mobile:
          Provider.of<WebSocketProvide>(context, listen: false).connectWebsocket(context);
          break;
        case ConnectivityResult.ethernet:
          Provider.of<WebSocketProvide>(context, listen: false).connectWebsocket(context);
          break;
        case ConnectivityResult.none:
          Provider.of<WebSocketProvide>(context, listen: false).closeWebSocket(context);
          break;
        default:
      }
    });
  }

  @override
  void dispose() {
    _connectivity.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        Provider.of<WebSocketProvide>(context, listen: false).connectWebsocket(myGlobals.scaffoldKey!.currentContext!);
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        Provider.of<WebSocketProvide>(context, listen: false).closeWebSocket(context);
        break;
      case AppLifecycleState.detached: // 申请将暂时暂停
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[HomePage(), FindPage(), ChatManagerPage(), MinePage()],
        ),
        onWillPop: _doubleClickBack,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                _iconHome,
                color: _defaultColor,
                size: 44.sp,
              ),
              activeIcon: Icon(
                _iconHome,
                color: _activeColor,
                size: 44.sp,
              ),
              label: '首页'),
          BottomNavigationBarItem(
            icon: Icon(
              _iconFind,
              color: _defaultColor,
              size: 50.sp,
            ),
            activeIcon: Icon(
              _iconFind,
              color: _activeColor,
              size: 50.sp,
            ),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(
                  _iconMessage,
                  color: _defaultColor,
                  size: 50.sp,
                ),
                _messageBadge
              ],
            ),
            activeIcon: Stack(
              children: [
                Icon(
                  _iconMessage,
                  color: _activeColor,
                  size: 50.sp,
                ),
                _messageBadge
              ],
            ),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _iconMine,
              color: _defaultColor,
              size: 50.sp,
            ),
            activeIcon: Icon(
              _iconMine,
              color: _activeColor,
              size: 50.sp,
            ),
            label: '我的',
          )
        ],
      ),
    );
  }

  /// 消息徽标
  Widget get _messageBadge => Positioned(
      top: 3.h,
      right: 3.w,
      child: Consumer<ConversationProvide>(builder: (_, conversation, child) {
        bool isAllRead = true;
        for (int i = 0; i < conversation.conversations.length; i++) {
          if (conversation.conversations[i].unReadCount != 0) {
            isAllRead = false;
            break;
          }
        }
        return Offstage(
          offstage: isAllRead,
          child: CircleAvatar(
            radius: 5.sp,
            backgroundColor: Colors.redAccent,
          ),
        );
      }));
}
