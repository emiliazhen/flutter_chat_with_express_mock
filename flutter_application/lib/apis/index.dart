import 'package:flutter_application/utils/fetch.dart';
import 'package:dio/dio.dart';

/// 获取通讯录列表
Future<Response> apiUserList(context, {Map data = const {}}) async {
  return Fetch(context).fetch({'url': '/members/getUserList', 'method': 'get', 'data': data});
}

/// 获取通讯录成员详情
Future<Response> apiMembersInfo(context, {Map data = const {}}) async {
  return Fetch(context).fetch({'url': '/members/getUserInfo', 'method': 'get', 'data': data});
}

/// 文件上传-单
Future<Response> apiUploadFile(context, {required FormData data}) async {
  return Fetch(context).fetch({
    'url': '/upload/file',
    'method': 'post',
    'data': data,
  });
}

/// 获取文件列表
Future<Response> apiFilesList(context, {Map data = const {}}) async {
  return Fetch(context).fetch({'url': '/download/getFileList', 'method': 'get', 'data': data});
}
