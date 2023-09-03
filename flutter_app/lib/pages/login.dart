import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/components/base_button.dart';
import 'package:flutter_app/components/base_picker_select.dart';
import 'package:flutter_app/shared/index.dart';
import 'package:flutter_app/utils/dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_app/apis/index.dart';
import 'package:flutter_app/provide/user_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 登录页
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// 加载
  bool _isLoading = false;

  /// 当前用户
  Map<String, dynamic> _curInfo = {"userId": 0, 'name': ''};

  /// 选择账号
  void _selectUserTap() async {
    if (_isLoading) {
      UtilDialog.showMessage(context, '正在获取用户列表，请稍等..', duration: 2);
      return;
    }
    if (Provider.of<UserListProvide>(context, listen: false).userCount == 0) {
      setState(() {
        _isLoading = true;
      });
      dynamic res = await apiUserList(context);
      UtilDialog.closeMessage();
      setState(() {
        _isLoading = false;
      });
      if (res.data['code'] == 200) {
        Provider.of<UserListProvide>(context, listen: false)
            .setUserList(res.data['data'].map((e) {
          return {'userId': e['personId'], 'name': e['personName']};
        }).toList());
        _userListDialog();
      }
    } else {
      apiUserList(context).then((res) {
        if (res.data['code'] == 200) {
          Provider.of<UserListProvide>(context, listen: false)
              .setUserList(res.data['data'].map((e) {
            return {'userId': e['personId'], 'name': e['personName']};
          }).toList());
        }
      });
      _userListDialog();
    }
  }

  /// 选择账号对话框
  void _userListDialog() {
    showDialog(
        context: context,
        builder: (context) =>
            Consumer<UserListProvide>(builder: (_, userList, child) {
              return BasePickerSelect(
                value: _curInfo['userId'],
                items: userList.list,
                title: '选择账号',
                props: const {'key': 'userId', 'value': 'name'},
                onSelected: (value) async {
                  for (int i = 0; i < userList.list.length; i++) {
                    if (userList.list[i]['userId'] == value) {
                      setState(() {
                        _curInfo = userList.list[i];
                      });
                      break;
                    }
                  }
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  SharedPreferencesUtil.accessToken = value.toString();
                  SharedPreferencesUtil.userInfo = _curInfo;
                  prefs.setString('userInfo', jsonEncode(_curInfo));
                  Navigator.of(context).pushReplacementNamed('/');
                },
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 228, 229, 231),
          Color.fromARGB(255, 199, 232, 252)
        ], begin: Alignment.bottomLeft, end: Alignment.topRight)),
        width: 1.sw,
        height: 1.sh,
        child: Column(
          children: [
            Container(
              height: 1.sh / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.flutter_dash_rounded,
                    color: Colors.blue.shade300,
                    size: 280.sp,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30.h),
                    child: Text(
                      '沙漠鹧鸪哨',
                      style: TextStyle(
                          color: Colors.blue.shade300,
                          fontSize: 38.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(40.w, 160.h, 40.w, 0),
              child: BaseButton(
                title: '登 录',
                submit: _selectUserTap,
              ),
            )
          ],
        ),
      ),
    );
  }
}
