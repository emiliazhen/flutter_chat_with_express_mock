import 'package:flutter/material.dart';
import 'package:flutter_app/apis/index.dart';

// 成员列表
class UserListProvide with ChangeNotifier {
  late List<dynamic> list = [];

  int get userCount => list.length;

  /// 设置成员列表
  setUserList(List<dynamic> res) {
    list = res;
    notifyListeners();
  }
}
