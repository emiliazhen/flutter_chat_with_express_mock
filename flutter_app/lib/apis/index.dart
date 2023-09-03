import 'package:flutter_app/utils/fetch.dart';
import 'package:dio/dio.dart';

/// 获取通讯录列表
Future<Response> apiUserList(context, {Map data = const {}}) async {
  return Fetch(context).fetch(
      {'url': '/res/person/app/getUserList', 'method': 'get', 'data': data});
}

/// 获取通讯录成员详情
Future<Response> apiMembersInfo(context, {Map data = const {}}) async {
  return Fetch(context)
      .fetch({'url': '/app/getUserInfo', 'method': 'get', 'data': data});
}

/// 文件上传-单
Future<Response> apiUploadFile(context, {required FormData data}) async {
  return Fetch(context).fetch({
    'url': '/app/uploadFile',
    'method': 'post',
    'data': data,
  });
}

/// 获取文件列表
Future<Response> apiFilesList(context, {Map data = const {}}) async {
  return Fetch(context)
      .fetch({'url': '/app/filesList', 'method': 'get', 'data': data});
}

/// 人员携带装备上报
Future<Response> apiPersonDeviceReport(context, {Map data = const {}}) async {
  return Fetch(context).fetch({
    'url': '/res/person/app/personDeviceReport',
    'method': 'post',
    'data': data
  });
}

/// 人员位置上报
Future<Response> apiPersonLocationReport(context, {Map data = const {}}) async {
  return Fetch(context).fetch({
    'url': '/res/person/app/personLocationReport',
    'method': 'post',
    'data': data
  });
}

/// 获取当前类型
Future<Response> apiGetType(context, {Map data = const {}}) async {
  return Fetch(context).fetch(
      {'url': '/system/event/app/getType', 'method': 'post', 'data': data});
}

/// 下拉-室
Future<Response> apiGetSectionList(context, {Map data = const {}}) async {
  return Fetch(context)
      .fetch({'url': '/res/getSectionList', 'method': 'get', 'data': data});
}

/// 下拉-层
Future<Response> apiGetFloorList(context, {Map data = const {}}) async {
  return Fetch(context)
      .fetch({'url': '/res/getFloorList', 'method': 'post', 'data': data});
}

/// 指令-列表
Future<Response> apiGetCommandList(context, {Map data = const {}}) async {
  return Fetch(context)
      .fetch({'url': '/msg/command/app/list', 'method': 'get', 'data': data});
}

/// 指令-状态修改
Future<Response> apiGetCommandEdit(context, {Map data = const {}}) async {
  return Fetch(context)
      .fetch({'url': '/msg/command/app/edit', 'method': 'post', 'data': data});
}

/// 指令-未读数量
Future<Response> apiGetUnreadCount(context, {Map data = const {}}) async {
  return Fetch(context).fetch({
    'url': '/msg/command/app/getUnreadCount',
    'method': 'post',
    'data': data
  });
}

/// 下拉-级别
Future<Response> apiGetMsgTagType(context, {Map data = const {}}) async {
  return Fetch(context).fetch({
    'url': '/system/dict/data/app/type/msg_tag',
    'method': 'get',
    'data': data
  });
}

/// 下拉-列表
Future<Response> apiStateUpload(context, {required FormData data}) async {
  return Fetch(context)
      .fetch({'url': '/app/stateUpload', 'method': 'post', 'data': data});
}
