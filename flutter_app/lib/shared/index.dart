import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局静态数据共享
class SharedPreferencesUtil {
  /// 时间戳
  static String lastStamp = '1900-01-01 00:00:00';

  /// token令牌
  static late String accessToken;

  /// 用户基本信息
  static late Map userInfo;

  /// 首次安装或更新后
  static bool first = true;

  /// 是否检查过新版本
  static bool isChecked = false;

  ///系统消息
  static late Map firstNotice;

  /// 初始化
  static Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SharedPreferencesUtil.userInfo = json.decode(prefs.getString('userInfo') ?? '{"userId": 0}');
    SharedPreferencesUtil.accessToken = prefs.getString('access_token') ?? '';
    SharedPreferencesUtil.first = prefs.getBool('first') ?? true;
  }

  /// 是否登录
  static bool getIsLogin() {
    return accessToken != '' && userInfo['userId'] != 0;
  }
}
