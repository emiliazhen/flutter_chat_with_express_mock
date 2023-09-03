import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_app/utils/dialog.dart';
import 'package:flutter_app/shared/index.dart';
import 'package:flutter_app/utils/config.dart';

class SystemOptions {
  /// 写入外部存储，检测权限状态，同意则写入   callBack 回调函数
  static Future requestPermission(context, {callBack}) async {
    PermissionStatus permission = await Permission.storage.status;
    if (permission == PermissionStatus.granted) {
      callBack();
    } else {
      await Permission.storage.request();
      PermissionStatus permission = await Permission.storage.status;
      if (permission == PermissionStatus.granted) {
        callBack();
      } else {
        UtilDialog.showMessage(context, "您拒绝读写权限，系统的部分功能将受到影响!");
      }
    }
  }

  /// 网络是否连接  true 网络连接良好
  static Future<bool> isNetConnectivity() async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity()); //无网络状态
    return connectivityResult != ConnectivityResult.none;
  }

  ///获取网络类型
  static Future<ConnectivityResult> getConnectivityType() async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity()); //无网络状态
    return connectivityResult;
  }

  static void uploadSystemErrorLog(String errorLog) async {
    Dio dio = Dio();
    dio.options.headers['access-token'] = SharedPreferencesUtil.accessToken;
    dio.options.headers['last-stamp'] = SharedPreferencesUtil.lastStamp;
    String url = "${Config.baseUrl}/log/app";
    Map<String, dynamic> data = {"AppName": 'hr', "Log": errorLog};
    print('⚠⚠⚠---$errorLog');
    dio.post(url, data: data).then((res) {
      print("错误上传成功$res");
    }, onError: (error) {
      print("erro$error");
    });
  }
}
