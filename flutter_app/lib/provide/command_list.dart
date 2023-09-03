import 'package:flutter/cupertino.dart';

class CommandListProvide with ChangeNotifier {
  int unreadCount = 0;
  List tagList = [];

  /// 设置未读数
  void setUnreadCount(int value) {
    unreadCount = value;
    notifyListeners();
  }

  /// 设置标签列表
  void setTagList(List value) {
    tagList = value;
    notifyListeners();
  }
}
