import 'dart:math';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/chat_video_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_app/provide/chat_websocket.dart';
import 'package:flutter_app/service/model/conversation.dart';
import 'package:flutter_app/utils/emoji.dart';
import 'package:flutter_app/provide/chat_message.dart';
import 'package:flutter_app/utils/config.dart';
import 'package:flutter_app/enum/index.dart';
import 'package:flutter_app/service/model/chatMessage.dart';
import 'package:flutter_app/components/status_view.dart';
import 'package:flutter_app/components/photo_view_simple.dart';

// 消息项组件
class ChatMessageWidget extends StatelessWidget {
  final Key key;
  final BuildContext context;
  final ConversationModel conversation;
  final ChatMessageModel message;
  final bool isMe;
  final String curPlayMessageId;
  final Function? audioTap;
  final Function? videoTap;
  const ChatMessageWidget(
    this.context,
    this.key,
    this.conversation,
    this.message,
    this.isMe,
    this.curPlayMessageId, {
    this.audioTap,
    this.videoTap,
  }) : super(key: key);

  /// 重新发送消息
  void _resendMessage() {
    ChatMessageModel newMessage = ChatMessageModel();
    newMessage.state = chatLogStatusEnum['Sending'];
    newMessage.type = message.type;
    newMessage.content = message.content;
    newMessage.userId = message.userId;
    newMessage.conversationId = message.conversationId;
    newMessage.duration = message.duration;
    newMessage.msgId = Uuid().v4(); //生成消息id
    Provider.of<WebSocketProvide>(context, listen: false)
        .sendMessage(context, conversation, newMessage);
  }

  /// EmojiCode转图片url处理
  void _emojiToImg(List<String> msgList, String content) {
    if (content.isEmpty) {
      return;
    }
    Match? match = EmojiUtil.codeReg.firstMatch(content);
    if (match != null) {
      if (match.start == 0) {
        msgList.add(content.substring(match.start, match.end));
      } else {
        msgList.add(content.substring(0, match.start));
        msgList.add(content.substring(match.start, match.end));
      }
      _emojiToImg(msgList, content.substring(match.end));
    } else {
      msgList.add(content);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.w),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: isMe
              ? [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[_messageStateArea(), _messageMainArea],
                  ),
                  _buildMsgHead,
                ]
              : [
                  _buildMsgHead,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[_messageMainArea, _messageStateArea()],
                  )
                ]),
    );
  }

  /// 消息状态
  Widget _messageStateArea() {
    int state = message.state;
    EdgeInsetsGeometry curMargin =
        isMe ? EdgeInsets.only(right: 15.w) : EdgeInsets.only(left: 15.w);
    if (state == chatLogStatusEnum["Sending"] &&
        DateTime.now().millisecondsSinceEpoch - message.createTime >= 10000) {
      message.state = chatLogStatusEnum["Failed"];
      message.failReason = '发送超时，请重试！';
      Provider.of<ChatMessageProvide>(context, listen: false)
          .updateChatMessage(message);
    }
    if (state == chatLogStatusEnum["Failed"]) {
      return GestureDetector(
        onTap: () => showDialog(
            context: context,
            builder: (_) {
              return _showMessageFailDialog;
            }),
        child: Container(
          height: 34.h,
          width: 34.h,
          margin: curMargin,
          child: Icon(
            Icons.error_rounded,
            size: 34.sp,
            color: const Color(0xFFFE4A49),
          ),
        ),
      );
    } else if (state == chatLogStatusEnum["Sending"]) {
      return Container(
        height: 34.h,
        width: 34.h,
        margin: curMargin,
        child: Image.asset("images/icon_message_sending.gif"),
      );
    } else {
      return Container();
    }
  }

  /// 消息主体
  Widget get _messageMainArea => LimitedBox(
      maxWidth: 490.w,
      child: Container(
          margin:
              isMe ? EdgeInsets.only(right: 24.w) : EdgeInsets.only(left: 24.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          child: message.type == messageTypeEnum['Text']
              ? _messageContentText()
              : message.type == messageTypeEnum['Image']
                  ? _messageContentImage
                  : message.type == messageTypeEnum['Audio']
                      ? _messageContentAudio
                      : message.type == messageTypeEnum['Video']
                          ? _messageContentVideo
                          : Container()));

  /// 文字消息
  Widget _messageContentText() {
    List<String> msgList = [];
    _emojiToImg(msgList, message.content);
    List<Widget> resultItems = msgList.map((item) {
      if (EmojiUtil.codeReg.hasMatch(item) &&
          EmojiUtil.emojiData[item] != null) {
        return Image.asset(
          'emoji/${EmojiUtil.emojiData[item]}.png',
          width: 36.h,
        );
      } else {
        return Text(
          item,
          style: TextStyle(
            color: isMe ? Colors.white : Color(0xff333333),
            fontSize: 30.sp,
          ),
        );
      }
    }).toList();
    CustomPopupMenuController popupController = CustomPopupMenuController();
    return CustomPopupMenu(
      controller: popupController,
      barrierColor: Colors.transparent,
      pressType: PressType.longPress,
      verticalMargin: 5.h,
      menuBuilder: () => GestureDetector(
          onTap: () {
            Clipboard.setData(
                ClipboardData(text: EmojiUtil.emojiCodeToCN(message.content)));
            popupController.hideMenu();
          },
          child: Container(
            width: 120.w,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            color: const Color(0xFF4C4C4C),
            alignment: Alignment.center,
            child: Text(
              '复制',
              style: TextStyle(fontSize: 24.sp, color: Colors.white),
            ),
          )),
      child: LimitedBox(
        maxWidth: 490.w,
        child: Stack(
            alignment: isMe
                ? AlignmentDirectional.topEnd
                : AlignmentDirectional.topStart,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(minHeight: 80.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: isMe ? Color(0xff2294E2) : Colors.white),
                child: Wrap(
                  children: resultItems,
                ),
              ),
              _messageBackgroundTriangle
            ]),
      ),
    );
  }

  /// 图片消息
  Widget get _messageContentImage => GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return PhotoViewSimple(
                  imageProvider:
                      NetworkImage(Config.fileDomain + message.content),
                );
              },
              fullscreenDialog: true,
            ),
          );
        },
        child: Container(
          width: 200.w,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: StatusImage(
              imageSrc: Config.fileDomain + message.content,
              width: 200.w,
              fit: BoxFit.fill,
            ),
          ),
        ),
      );

  /// 语音消息
  Widget get _messageContentAudio => Stack(
          alignment: isMe
              ? AlignmentDirectional.topEnd
              : AlignmentDirectional.topStart,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (audioTap != null) {
                  audioTap!();
                }
              },
              child: Container(
                  width: 240.w,
                  height: 80.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: isMe ? Color(0xff2294E2) : Colors.white,
                    borderRadius: BorderRadius.circular(5.sp),
                  ),
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 12.w),
                          child: Icon(
                            curPlayMessageId == message.msgId
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: isMe ? Colors.white : Color(0xff6c98b7),
                          )),
                      message.duration > 0
                          ? Text(
                              '${message.duration.toString()}″',
                              style: TextStyle(
                                  color:
                                      isMe ? Colors.white : Color(0xff6c98b7)),
                            )
                          : SizedBox(
                              width: 25.w,
                              height: 25.w,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    isMe ? Colors.white : Color(0xff6c98b7)),
                                strokeWidth: 2.w,
                              ),
                            ),
                    ],
                  )),
            ),
            _messageBackgroundTriangle
          ]);

  /// 视频消息
  Widget get _messageContentVideo => Stack(
        alignment:
            isMe ? AlignmentDirectional.topEnd : AlignmentDirectional.topStart,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatVideoViewPage(
                              videoUrl: message.content,
                              videoDuration: message.duration,
                            )));
              },
              child: Container(
                width: 240.w,
                height: 80.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: isMe ? Color(0xff2294E2) : Colors.white,
                  borderRadius: BorderRadius.circular(5.sp),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.w),
                      alignment: Alignment.center,
                      width: 40.w,
                      height: 40.w,
                      color: Colors.black,
                      child: Icon(
                        Icons.play_arrow,
                        size: 40.w,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '视频',
                      style: TextStyle(
                          fontSize: 24.sp,
                          color: isMe ? Colors.white : Color(0xff6c98b7)),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10.w),
                      child: Text(
                        '${message.duration}″',
                        style: TextStyle(
                            color: isMe ? Colors.white : Color(0xff6c98b7)),
                      ),
                    )
                  ],
                ),
              )),
          _messageBackgroundTriangle
        ],
      );

  /// 气泡小三角
  Widget get _messageBackgroundTriangle => Positioned(
        top: 30.h,
        child: Container(
          transform: Matrix4.identity()..translate(isMe ? 8.w : -8.w),
          child: Transform(
            // Matrix4.translation(v.Vector3()
            transform: Matrix4.identity()..rotateZ(pi / 4),
            origin: Offset(8.w, 8.w),
            child: Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  color: isMe ? Color(0xff2294E2) : Colors.white),
            ),
          ),
        ),
      );

  /// 头像
  Widget get _buildMsgHead => CircleAvatar(
        child: Text(isMe
            ? '我'
            : conversation.trueName.isEmpty
                ? '-'
                : conversation.trueName.substring(0, 1)),
      );

  /// 失败弹窗
  Widget get _showMessageFailDialog => AlertDialog(
        title: Text('系统提示'),
        content: Text(message.failReason.replaceAll('\'', '')),
        actions: <Widget>[
          TextButton(
            child: Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('重新发送'),
            onPressed: () {
              _resendMessage();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}
