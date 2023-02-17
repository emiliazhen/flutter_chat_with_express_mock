import 'package:flutter/cupertino.dart';

/// 全局context 实例
MyGlobals myGlobals = MyGlobals();

class MyGlobals {
  GlobalKey<NavigatorState>? _scaffoldKey;
  MyGlobals() {
    _scaffoldKey = GlobalKey<NavigatorState>();
  }
  GlobalKey<NavigatorState>? get scaffoldKey => _scaffoldKey;
}
