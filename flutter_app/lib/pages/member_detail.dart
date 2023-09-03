import 'package:flutter/material.dart';
import 'package:flutter_app/apis/index.dart';
import 'package:flutter_app/pages/chat_detail.dart';
import 'package:flutter_app/service/model/chatMessage.dart';
import 'package:flutter_app/service/model/conversation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_app/components/index.dart';

// 成员详情页
class MemberDetailPage extends StatefulWidget {
  final int memberId;
  final String memberName;
  MemberDetailPage({Key? key, required this.memberId, required this.memberName})
      : super(key: key);

  @override
  _MemberDetailPageState createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  bool _isLoading = false;
  Map<String, dynamic> _info = {};

  void _getData() {
    setState(() {
      _info['trueName'] = widget.memberName;
      _info['memberId'] = widget.memberId;
    });
  }

  /// 跳转聊天
  void _goChatDetail() {
    ConversationModel conversation =
        ConversationModel.toConversation(_info, ChatMessageModel());
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatDetailPage(conversation: conversation)));
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? BaseLoading()
          : Column(
              children: <Widget>[
                _userPageTop,
                _descriptionTitle,
                Expanded(child: _descriptionContent)
              ],
            ),
    );
  }

  // 顶部用户区
  Widget get _userPageTop => Stack(
        children: [
          Container(
            height: 720.h,
            padding: EdgeInsets.only(left: 30.w, right: 20.w, top: 60.h),
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color.fromARGB(255, 167, 220, 245),
              Colors.blueGrey
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => {Navigator.pop(context)},
                    child: Container(
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 38,
                    color: Colors.blue,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15.h),
                  child: Text(
                    widget.memberName,
                    style: TextStyle(fontSize: 40.sp),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 5.h),
                  child: Text(
                    '重要成员',
                    style: TextStyle(fontSize: 26.sp, color: Color(0xff333333)),
                  ),
                ),
                BaseButton(submit: _goChatDetail, title: '聊天'),
                _statisticsArea
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                  width: 1.sw,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  height: 60.h))
        ],
      );

  /// 统计区
  Widget get _statisticsArea => Container(
        margin: EdgeInsets.only(top: 15.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statisticsItem('Follower', _info['follower'] ?? 0),
            _statisticsItem('Project', _info['follower'] ?? 0, hasBorder: true),
            _statisticsItem('Points', _info['points'] ?? 0),
          ],
        ),
      );

  /// 统计项
  Widget _statisticsItem(String title, int total, {bool hasBorder = false}) {
    Widget child = Column(
      children: [
        Text(
          total.toString(),
          style: TextStyle(fontSize: 36.sp, color: Colors.white),
        ),
        Text(
          title,
          style: TextStyle(
              fontSize: 24.sp, color: Color.fromARGB(255, 209, 206, 206)),
        )
      ],
    );
    return hasBorder
        ? Container(
            width: 1.sw / 3,
            decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(
                        width: 1.w, color: Color.fromARGB(255, 209, 206, 206)),
                    right: BorderSide(
                        width: 1.w,
                        color: Color.fromARGB(255, 209, 206, 206)))),
            child: child)
        : child;
  }

  /// 介绍标题
  Widget get _descriptionTitle => Container(
        alignment: Alignment.centerLeft,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Text('简介',
            style: TextStyle(fontSize: 36.sp, color: Colors.black87)),
      );

  /// 介绍内容
  Widget get _descriptionContent => Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.all(0.h),
        children: [
          Text(
            _info['paragraph'] ?? '',
            style: TextStyle(fontSize: 32.sp, color: Color(0xff666666)),
          )
        ],
      ));
}
