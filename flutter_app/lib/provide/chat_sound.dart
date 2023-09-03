import 'package:flutter/cupertino.dart';

class ChatSoundProvide with ChangeNotifier {
  bool canCancel = false;

  /// 设置是否能取消
  void setCanCancel(bool value) {
    canCancel = value;
    notifyListeners();
  }
}
