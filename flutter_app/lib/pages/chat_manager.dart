import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';

import 'package:flutter_app/enum/index.dart';
import 'package:flutter_app/provide/chat_websocket.dart';
import 'package:flutter_app/provide/chat_conversation.dart';
import 'package:flutter_app/service/model/conversation.dart';
import 'package:flutter_app/utils/dialog.dart';
import 'package:flutter_app/utils/emoji.dart';
import 'package:flutter_app/utils/formatter.dart';
import 'package:flutter_app/pages/member_manager.dart';
import 'package:flutter_app/pages/chat_detail.dart';
import 'package:flutter_app/components/index.dart';

/// 消息管理页
class ChatManagerPage extends StatefulWidget {
  const ChatManagerPage({Key? key}) : super(key: key);

  @override
  State<ChatManagerPage> createState() => _ChatManagerPageState();
}

class _ChatManagerPageState extends State<ChatManagerPage> {
  /// ! 是否在聊天测试 （后期删除）
  bool _isTestChat = false;

  /// 右上角弹出控制器
  final CustomPopupMenuController _popupController =
      CustomPopupMenuController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: setCustomAppBar(context, '',
          leading: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 30.w),
            child: Text(
              '消息',
              style: TextStyle(
                  fontSize: 34.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MemberMangerPage()));
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                ),
                child: Icon(
                  Icons.group_rounded,
                  size: 46.sp,
                  color: Colors.white,
                ),
              ),
            ),
            CustomPopupMenu(
              controller: _popupController,
              pressType: PressType.singleClick,
              arrowColor: Color(0xFF4C4C4C),
              horizontalMargin: 10.w,
              verticalMargin: 2.h,
              menuBuilder: () => Container(
                  decoration: BoxDecoration(
                      color: Color(0xFF4C4C4C),
                      borderRadius: BorderRadius.circular(10.sp)),
                  child: IntrinsicWidth(
                      child: Column(children: <Widget>[
                    _popItem('消息测试', Icons.message, () {
                      setState(() {
                        _isTestChat = !_isTestChat;
                      });
                      if (_isTestChat) {
                        UtilDialog.showMessage(context, '开启测试！');
                        Provider.of<WebSocketProvide>(context, listen: false)
                            .openTestChat(context);
                      } else {
                        UtilDialog.showMessage(context, '关闭测试！');
                        Provider.of<WebSocketProvide>(context, listen: false)
                            .closeTestChat(context);
                      }
                      _popupController.hideMenu();
                    }),
                    _popItem('清空记录', Icons.delete_forever_rounded, () {
                      _popupController.hideMenu();
                    }),
                  ]))),
              child: Container(
                margin: EdgeInsets.only(right: 20.w),
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                ),
                child: Icon(
                  Icons.add,
                  size: 46.sp,
                  color: Colors.white,
                ),
              ),
            )
          ]),
      body: Consumer<ConversationProvide>(builder: (_, conversation, child) {
        return Column(children: [
          conversation.connectState == websocketLinkStatusEnum["Linking"]
              ? _buildIMConnecting
              : conversation.connectState == websocketLinkStatusEnum["LinKFail"]
                  ? _buildFailIMConnect
                  : Container(),
          // _groupConversationItem('一家人', '[恭喜发财 大吉大利]'),
          Expanded(
              child: SlidableAutoCloseBehavior(
                  child: ListView(
            children: conversation.conversations
                .map((item) => _conversationItem(item))
                .toList(),
          )))
        ]);
      }),
    );
  }

  // 气泡选项
  Widget _popItem(String text, IconData iconData, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
            alignment: Alignment.center,
            height: 110.h,
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 40.h),
            child: Row(
              children: <Widget>[
                SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: Icon(
                      iconData,
                      color: Colors.white,
                    )),
                Container(
                  margin: EdgeInsets.only(left: 20.w),
                  child: Text(text,
                      style: TextStyle(
                        fontSize: 30.sp,
                        color: Colors.white,
                      )),
                )
              ],
            )),
      );

  // 网络连接中
  Widget get _buildIMConnecting => Container(
        height: 88.h,
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 50.w, right: 21.h),
              child: Icon(
                Icons.access_time,
                color: const Color(0xff2091DF),
                size: 40.h,
              ),
            ),
            Text(
              "正在连接服务器.....",
              style: TextStyle(color: const Color(0xff333333), fontSize: 26.sp),
            ),
          ],
        ),
      );

  // 网络连接失败
  Widget get _buildFailIMConnect => Container(
        height: 88.h,
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 50.w, right: 21.w),
              height: 34.h,
              width: 34.w,
              child: const Icon(
                Icons.error_rounded,
                color: Colors.red,
              ),
            ),
            Text(
              "当前网络不可用，请检查你的网络设备！",
              style: TextStyle(color: const Color(0xff333333), fontSize: 26.sp),
            ),
            GestureDetector(
              onTap: () {
                /// 重新连接webSocket
                Provider.of<WebSocketProvide>(context, listen: false)
                    .connectWebsocket(context);
              },
              child: Container(
                child: Text(
                  "重试",
                  style: TextStyle(
                      color: const Color(0xff2294E2), fontSize: 26.sp),
                ),
              ),
            )
          ],
        ),
      );

  // 会话消息项
  Widget _conversationItem(ConversationModel conversation) {
    return Slidable(
        key: Key(conversation.chatUserId),
        groupTag: 'conversationItem',
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                Provider.of<ConversationProvide>(context, listen: false)
                    .delConversation(context, conversation);
              },
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              label: '删除',
            ),
          ],
        ),
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatDetailPage(conversation: conversation)));
            },
            child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Container(
                  margin: EdgeInsets.only(left: 30.w),
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom: BorderSide(
                              width: 1.h, color: Color(0xffefefef)))),
                  child: Row(
                    children: [
                      Stack(clipBehavior: Clip.none, children: <Widget>[
                        CircleAvatar(
                          radius: 45.h,
                          child: Text(
                            conversation.trueName.isEmpty
                                ? '-'
                                : conversation.trueName.substring(0, 1),
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white, fontSize: 42.sp),
                          ),
                        ),
                        Positioned(
                            right: -6.w,
                            top: -5.h,
                            child: Offstage(
                              offstage: conversation.unReadCount == 0,
                              child: CircleAvatar(
                                radius: 15.sp,
                                backgroundColor: Color(0xffE72F2F),
                                child: Text(
                                  conversation.unReadCount > 99
                                      ? '99+'
                                      : conversation.unReadCount.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18.sp, color: Colors.white),
                                ),
                              ),
                            ))
                      ]),
                      Expanded(
                          child: Container(
                        height: 90.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                        ),
                        child: _conversationInfo(conversation),
                      ))
                    ],
                  ),
                ))));
  }

  // 消息群聊会话
  Widget _groupConversationItem(String userName, String message) =>
      GestureDetector(
        onTap: () {
          // todo:
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => ChatDetailPage(
          //               userName: userName,
          //             )));
        },
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 20.w),
                  height: 80.h,
                  width: 80.h,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10.sp))),
                  child: Wrap(
                    children: [
                      Icon(
                        Icons.person,
                        size: 34.sp,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.hail,
                        size: 34.sp,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.face_retouching_natural,
                        size: 34.sp,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.seven_k,
                        size: 34.sp,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 2.h, color: Color(0xffdddddd)))),
                  // child: _conversationInfo(userName, message),
                ))
              ],
            )),
      );

  // 消息项文字内容
  Widget _conversationInfo(ConversationModel conversation) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  conversation.trueName,
                  style: TextStyle(fontSize: 30.sp, color: Color(0xff111111)),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.w),
                child: Text(
                  FormatterUtil.filtersMsgTime(conversation.lastContentTime),
                  style: TextStyle(color: Color(0xffBBBBBB), fontSize: 24.sp),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              conversation.isLastSendSuccess == chatLogStatusEnum["Failed"]
                  ? Container(
                      margin: EdgeInsets.only(right: 10.w),
                      height: 26.h,
                      width: 26.h,
                      child: Icon(
                        Icons.error_rounded,
                        size: 24.sp,
                        color: const Color(0xFFFE4A49),
                      ),
                    )
                  : conversation.isLastSendSuccess ==
                          chatLogStatusEnum["Sending"]
                      ? Container(
                          margin: EdgeInsets.only(right: 10.w),
                          height: 26.h,
                          width: 26.h,
                          child: Image.asset("images/icon_msg_sending.png"),
                        )
                      : Container(),
              Expanded(
                child: Text(_showLastContent(conversation),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: Color(0xffa0a0a0), fontSize: 24.sp)),
              )
            ],
          ),
        ],
      );

  String _showLastContent(ConversationModel conversation) {
    int lastContentType = conversation.lastContentType;
    if (lastContentType == messageTypeEnum["Text"]) {
      return EmojiUtil.emojiCodeToCN(conversation.lastContent);
    } else if (lastContentType == messageTypeEnum["Image"]) {
      return "[图片]";
    } else if (lastContentType == messageTypeEnum["Audio"]) {
      return "[语音]";
    } else if (lastContentType == messageTypeEnum["Video"]) {
      return "[视频]";
    } else if (lastContentType == messageTypeEnum["Location"]) {
      return "[位置]";
    }
    return "未知消息";
  }
}
