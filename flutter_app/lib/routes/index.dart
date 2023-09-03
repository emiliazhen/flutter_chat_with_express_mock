import 'package:flutter/material.dart';

import 'package:flutter_app/pages/index_navigator.dart';
import 'package:flutter_app/pages/login.dart';
import 'package:flutter_app/shared/index.dart';

/// 配置路由
final Map<String, Function> routes = {
  '/': (_, {arguments}) =>
      IndexNavigator(index: arguments == null ? 0 : arguments['index']),
  '/login': (_) => LoginPage(),
};

/// 固定写法
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  //String? 表示name为可空类型
  final String? name = settings.name;
  //Function? 表示pageContentBuilder为可空类型
  final Function? pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (!SharedPreferencesUtil.getIsLogin()) {
      return MaterialPageRoute(builder: (context) => LoginPage());
    }
    final Route route = MaterialPageRoute(
        builder: (context) =>
            pageContentBuilder(context, arguments: settings.arguments));
    return route;
  }
  return null;
}
