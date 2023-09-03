import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/shared/index.dart';
import 'package:flutter_app/utils/config.dart';
import 'package:flutter_app/utils/dialog.dart';
import 'package:flutter_app/utils/system.dart';

// dio 配置参数
final BaseOptions options = BaseOptions(
  headers: {
    'Content-Type': 'application/json',
  },
  baseUrl: Config.baseUrl,
  connectTimeout: 60000,
  receiveTimeout: 60000,
);

/// new Dio实例    目前写法只添加一个拦截器  后续需要多个拦截器的话再修改...
final Dio _dio = Dio(options)
  ..interceptors.add(
    InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      // 在请求被发送之前做一些事情
      options.headers['access-token'] = SharedPreferencesUtil.accessToken;
      options.headers['last-stamp'] = SharedPreferencesUtil.lastStamp;
      return handler.next(options);
    }, onResponse:
            (Response response, ResponseInterceptorHandler handler) async {
      // 在返回响应数据之前做一些预处理
      Fetch.onResponse(response);
      return handler.next(response);
    }, onError: (DioError e, ErrorInterceptorHandler handler) {
      // 当请求失败时做一些预处理
      Fetch.onError(e);
      return handler.next(e);
    }),
  )
  ..interceptors.add(LogInterceptor(
      request: false,
      requestHeader: true,
      responseHeader: true,
      responseBody: true,
      requestBody: true));

class Fetch {
  // 内部
  final BuildContext _context;

  // 外部
  static late BuildContext context;

  Fetch(this._context) {
    context = _context;
  }

  Future<Response> fetch(Map config) async {
    // http链接地址
    String url = config['url'];
    // 判断 get 或 post
    Response params =
        Response(data: {}, requestOptions: RequestOptions(path: ''));
    try {
      if (config['method'] == 'post') {
        // POST
        if (context != null) {
          UtilDialog.showLoading(context);
        }
        params = await _dio.post(url, data: config['data'] ?? {});
      } else {
        params = await _dio.get(url,
            queryParameters: Map<String, dynamic>.from(config['data'] ?? {}));
        // GET
      }
    } catch (e) {}
    return params;
  }

  // onResponse拦截器
  static void onResponse(Response response) async {
    print('🤎${response.requestOptions.method}');
    if (response.requestOptions.method == 'POST' &&
        context != null &&
        Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // 清除post请求的loading
    }
    if (response.data['Code'] == 'ERROR') {
      // 判断账号是否异常状态
      if (response.data['Command'] == 'UNSESSION' ||
          response.data['Command'] == 'SIGNATURE') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('access_toekn');
        SharedPreferencesUtil.userInfo = {}; // 用户基本信息
        if (context != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', ModalRoute.withName(''));
        }
      } else if (response.data['Command'] == 'EXPIREINS' && context != null) {
        Navigator.pushNamed(context, '/login');
      }
      if (context != null) {
        Future.delayed(Duration.zero).then((v) {
          UtilDialog.showMessage(context,
              response.data['Message'].replaceAll(RegExp('r[<br/>]'), ''));
        });
      }
    } else {
      if (response.headers['last-stamp'] != null) {
        print('🕘---${response.headers['last-stamp']}');
        SharedPreferencesUtil.lastStamp =
            response.headers['last-stamp'].toString();
      }
    }
  }

  // onError拦截器
  static void onError(DioError e) async {
    if (e.requestOptions.method == 'POST' &&
        context != null &&
        Navigator.of(context).canPop()) Navigator.of(context).pop();
    if (context != null && !await SystemOptions.isNetConnectivity()) {
      UtilDialog.showMessage(context, '当前网络不可用，请检查网络');
      return;
    }
    if (context != null) {
      UtilDialog.showMessage(context, '系统繁忙，请稍后再试！');
    }
  }
}
