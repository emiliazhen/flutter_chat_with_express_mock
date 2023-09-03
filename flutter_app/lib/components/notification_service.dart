import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_app/utils/global_context.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  //Singleton pattern
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // 初始化
  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    //初始化timezone
    tz.initializeTimeZones(); //  <----

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _selectNotification,
    );
  }

  /// 点击
  void _selectNotification(NotificationResponse details) async {
    print(details.toString());
    await cancelAllNotifications();
    print(ModalRoute.of(myGlobals.scaffoldKey!.currentContext!)?.settings.name);
    Navigator.of(myGlobals.scaffoldKey!.currentContext!)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false,
            arguments: {'index': 2});
  }

  // 显示通知
  Future<void> showNotifications(
      int sourceId, String title, String text, String messageId) async {
    await flutterLocalNotificationsPlugin.show(
        sourceId,
        title,
        text,
        const NotificationDetails(
            android: AndroidNotificationDetails(
          'channel ID',
          'channel name',
          channelDescription: 'channel description',
          playSound: true,
          priority: Priority.high,
          importance: Importance.high,
        )),
        payload: messageId);
  }

  /// 清除通知通过id
  Future<void> cancelNotificationsById(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(
      notificationId,
    );
  }

  /// 清除所有通知
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
