import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'package:flutter_app/apis/index.dart';
import 'package:flutter_app/utils/config.dart';
import 'package:flutter_app/utils/dialog.dart';
import 'package:flutter_app/components/index.dart';

// 发现页
class FindPage extends StatefulWidget {
  FindPage({Key? key}) : super(key: key);

  @override
  _FindPageState createState() => _FindPageState();
}

class _FindPageState extends State<FindPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int _downloadingIndex = -1;
  double _progress = 0;
  String _sdCardPath = '/sdCard';
  late Directory directory;
  CancelToken _cancelToken = CancelToken();
  List<dynamic> _data = [];
  int _total = 0;
  bool _loading = true;
  Map _queryForm = {
    'pageIndex': 1,
  };

  /// 初始化
  void _init() async {
    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      setState(() {
        _sdCardPath = directory.path;
      });
      _getData();
    }
  }

  /// 刷新
  void _refresh() {
    setState(() {
      _queryForm['pageIndex'] = 1;
      _data = [];
    });
    _getData();
  }

  /// 加载更多
  void _loadMoreData() {
    setState(() {
      _queryForm['pageIndex'] = _queryForm['pageIndex'] + 1;
    });
    _getData();
  }

  /// 获取数据
  void _getData() {
    _loading = true;
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    apiFilesList(context, data: _queryForm).then((res) {
      if (res.data['code'] == 200) {
        List<dynamic> resList = res.data['data'].map((item) {
          item['isDownloading'] = false;
          File file = File('$_sdCardPath/${item["fileName"]}.pdf');
          item['hasFile'] = file.existsSync();
          return item;
        }).toList();
        if (_queryForm['pageIndex'] == 1) {
          setState(() {
            _data = resList;
            _total = resList.length;
          });
        } else {
          List<dynamic> data = List.from(_data);
          data.addAll(resList);
          setState(() {
            _data = data;
          });
        }
      }
    });
  }

  /// 打开文件
  void _openFileClick(Map<String, dynamic> item) {
    OpenFile.open('$_sdCardPath/${item["fileName"]}.pdf',
        type: 'application/pdf');
  }

  /// 取消下载
  void _cancelDownloadClick(Map<String, dynamic> item) {
    if (_progress < 100) {
      _cancelToken.cancel();
    }
  }

  /// 下载
  void _downloadClick(Map<String, dynamic> item) async {
    String path = '$_sdCardPath/${item["fileName"]}.pdf';
    print(path);
    setState(() {
      _cancelToken = CancelToken();
      _progress = 0;
      _downloadingIndex =
          _data.indexWhere((dataItem) => dataItem['id'] == item['id']);
      _data[_downloadingIndex]['isDownloading'] = true;
    });
    try {
      await Dio().download(
          '${Config.baseUrl}/download/file?fileId=${item['fileId']}', path,
          data: {'fileId': item['fileId']},
          onReceiveProgress: (int count, int total) {
        if (count == -1) {
          UtilDialog.showMessage(context, "下载过程出现错误,请重试!");
          return;
        }
        setState(() {
          _progress = count / total * 100;
        });
        if (count == total) {
          setState(() {
            _data[_downloadingIndex]['hasFile'] = true;
            _data[_downloadingIndex]['isDownloading'] = false;
            _downloadingIndex = -1;
          });
        }
      },
          cancelToken: _cancelToken,
          options: Options(
            headers: {'Connection': 'Keep-Alive'},
          ));
    } on DioError catch (error) {
      if (CancelToken.isCancel(error)) {
        UtilDialog.showMessage(context, '下载已取消！');
      } else {
        print(error);
        UtilDialog.showMessage(context, '系统繁忙，请稍后再试！');
      }
      print(_downloadingIndex);
      setState(() {
        _data[_downloadingIndex]['isDownloading'] = false;
        _downloadingIndex = -1;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelToken.cancel();
  }

  @protected
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: setCustomAppBar(context, '',
          leading: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 30.w),
            child: Text(
              '发现',
              style: TextStyle(
                  fontSize: 34.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          )),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: BasePullRefreshLoad(
              _data,
              _total,
              _loading,
              (item) {
                return _viewItem(item);
              },
              refresh: _refresh,
              loadMore: _loadMoreData,
            ),
          ),
        ],
      ),
    );
  }

  /// 项
  Widget _viewItem(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(
              width: 120.w,
              height: 120.h,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.sp)),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset('images/icon_pdf.png'),
              )),
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Text(
                    item['fileName'],
                    style:
                        TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  item['des'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(fontSize: 20.sp, color: Colors.grey[700]),
                )
              ],
            ),
          )),
          Container(
              width: 120.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(Radius.circular(30.sp)),
              ),
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              child: _itemButton(item))
        ],
      ),
    );
  }

  /// 项按钮
  Widget _itemButton(Map<String, dynamic> item) {
    return item['hasFile']
        ? GestureDetector(
            onTap: () {
              _openFileClick(item);
            },
            child: Container(
              color: Colors.lightBlue.shade100,
              alignment: Alignment.center,
              child: Text(
                '打开',
                style: TextStyle(color: Colors.blue.shade800, fontSize: 24.sp),
              ),
            ))
        : item['isDownloading']
            ? GestureDetector(
                onTap: () {
                  _cancelDownloadClick(item);
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Container(
                      width: 120.w * _progress / 100,
                      height: 60.h,
                      color: Colors.lightBlue.shade50,
                      alignment: Alignment.centerLeft,
                    ),
                    Positioned(
                        child: Container(
                      width: 120.w,
                      height: 60.h,
                      alignment: Alignment.center,
                      child: Text(
                        _progress == 0
                            ? '下载中..'
                            : '${_progress.toStringAsFixed(2)}%',
                        style:
                            TextStyle(color: Colors.lightBlue, fontSize: 24.sp),
                      ),
                    ))
                  ],
                ))
            : GestureDetector(
                onTap: () {
                  _downloadClick(item);
                },
                child: Text(
                  '下载',
                  style: TextStyle(color: Colors.lightBlue, fontSize: 24.sp),
                ),
              );
  }
}
