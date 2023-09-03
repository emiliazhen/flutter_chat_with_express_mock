import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_app/provide/chat_websocket.dart';
import 'package:flutter_app/shared/index.dart';

// 我的页
class MinePage extends StatefulWidget {
  MinePage({Key? key}) : super(key: key);

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  /// 退出登录
  void _logout() async {
    SharedPreferencesUtil.accessToken = '';
    SharedPreferencesUtil.userInfo = {};
    SharedPreferences sPref = await SharedPreferences.getInstance();
    sPref.remove('access_token');
    sPref.remove('userInfo');
    Provider.of<WebSocketProvide>(context, listen: false)
        .closeWebSocket(context);
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[_userPageTop, _controlWrap],
      ),
    );
  }

  /// 顶部
  Widget get _userPageTop => Stack(
        children: [
          Container(
              height: 420.h,
              color: Colors.white,
              alignment: Alignment.topCenter,
              child: ClipPath(
                clipper: TopBackgroundClipper(),
                child: Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xFF0074ff), Color(0xFF019cfe)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter)),
                    width: 1.sw,
                    height: 350.h,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 35.w, vertical: 70.h),
                      alignment: Alignment.topLeft,
                      child: Icon(
                        Icons.qr_code,
                        color: Colors.white,
                        size: 44.sp,
                      ),
                    )),
              )),
          Positioned(
              top: 160.h,
              left: 0,
              child: Container(
                width: 1.sw,
                padding: EdgeInsets.symmetric(horizontal: 35.w),
                height: 200.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 35.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20.sp)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(
                            5.h,
                            5.h,
                          ),
                          blurRadius: 10.sp,
                          spreadRadius: 2.sp,
                        ),
                        const BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 0.0,
                          spreadRadius: 0.0,
                        ),
                      ]),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40.w,
                        backgroundColor: Colors.grey,
                        backgroundImage: AssetImage(
                          'images/user_unknown.png',
                        ),
                      ),
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 15.h),
                              child: Text(
                                SharedPreferencesUtil.userInfo['name'] ?? '-',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xff333333),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                  text: 'ID：',
                                  style: TextStyle(
                                      fontSize: 24.sp,
                                      color: Color(0xff999999)),
                                  children: [
                                    TextSpan(
                                      text: SharedPreferencesUtil
                                          .userInfo['userId']
                                          .toString(),
                                    )
                                  ]),
                            )
                          ],
                        ),
                      )),
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 10.h),
                          child: Icon(
                            Icons.logout_rounded,
                            color: Colors.red.shade400,
                            size: 50.sp,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ))
        ],
      );

  /// 入口面板
  Widget get _controlWrap => Expanded(
          child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _controlItem('个人信息', 'info', () {}),
            _controlItem('日程安排', 'date', () {}),
            _controlItem('数据报表', 'performance', () {}),
            _controlItem('警报通知', 'wage', () => {}),
            _controlItem('系统设置', 'setting', () {}),
          ],
        ),
      ));

  /// 入口项
  Widget _controlItem(String title, String iconName, VoidCallback tapFunction) {
    return GestureDetector(
        onTap: tapFunction,
        child: Container(
          margin: EdgeInsets.only(bottom: 70.h),
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 55.w,
                    height: 55.w,
                    child: Image.asset("images/icon_user_$iconName.png"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 25.w),
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 26.sp, color: const Color(0xFF0a1c32)),
                    ),
                  )
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 30.sp,
                color: const Color(0xFFeaeaea),
              ),
            ],
          ),
        ));
  }
}

/// 顶部贝塞尔切割
class TopBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldCliper) {
    return false;
  }
}
