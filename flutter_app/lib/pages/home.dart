import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/apis/index.dart';
import 'package:flutter_app/pages/report_device.dart';
import 'package:flutter_app/pages/report_position.dart';
import 'package:flutter_app/pages/report_resource.dart';
import 'package:flutter_app/pages/report_situation.dart';
import 'package:flutter_app/shared/index.dart';
import 'package:flutter_app/provide/command_list.dart';
import 'package:flutter_app/enum/index.dart';
import 'package:flutter_app/pages/command_detail.dart';

// 首页
class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<dynamic> _data = [];
  int _total = 0;
  bool _loading = true;
  final Map _queryForm = {
    'pageIndex': 1,
  };
  final TrackingScrollController _scrollController = TrackingScrollController();
  final _topBarList = [
    {
      'id': 1,
      'icon': 'icon_report_device',
      'title': '携带设备上报',
    },
    {
      'id': 2,
      'icon': 'icon_report_position',
      'title': '位置上报',
    },
    {
      'id': 3,
      'icon': 'icon_report_resource',
      'title': '资源上报',
    },
    {
      'id': 4,
      'icon': 'icon_report_situation',
      'title': '现场情况上报',
    },
  ];

  bool _onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      // 当没去到底部的时候，maxScrollExtent和offset会相等，可以准确的判断到达底部还有多少距离时开始加载数据了。。
      if (_scrollController.mostRecentlyUpdatedPosition!.maxScrollExtent >=
              _scrollController.offset &&
          _scrollController.mostRecentlyUpdatedPosition!.maxScrollExtent -
                  _scrollController.offset <=
              50) {
        // 要加载更多
        print('👌---------------------------');
        if (_data.length < _total && !_loading) {
          _loadMoreData();
        }
      }
    }
    return true;
  }

  /// 获取未读数量
  void _getUnreadCommand() {
    if (!mounted) return;
    apiGetUnreadCount(context,
            data: {'personId': SharedPreferencesUtil.userInfo['userId']})
        .then((res) {
      if (res.data['code'] == 200) {
        Provider.of<CommandListProvide>(context, listen: false)
            .setUnreadCount(res.data['data']);
      }
    });
  }

  /// 刷新
  Future<Null> _refresh() {
    setState(() {
      _queryForm['pageIndex'] = 1;
      _data = [];
    });
    apiGetCommandList(context, data: _queryForm).then((res) {
      if (res.data['code'] == 200) {
        List<dynamic> resList = res.data['rows'];
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
    return Future.value(null);
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
    apiGetCommandList(context, data: _queryForm).then((res) {
      if (res.data['code'] == 200) {
        List<dynamic> resList = res.data['rows'];
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

  @override
  void initState() {
    super.initState();
    _queryForm['consumer'] = SharedPreferencesUtil.userInfo['userId'];
    Future.delayed(Duration.zero, () {
      _getUnreadCommand();
      _getData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF3f9af5), Color(0xFF296fe1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight)),
      child: NotificationListener(
          onNotification: _onNotification,
          child: RefreshIndicator(
              //可滚动组件在滚动时会发送ScrollNotification类型的通知
              notificationPredicate: (ScrollNotification notification) {
                //该属性包含当前ViewPort及滚动位置等信息
                ScrollMetrics scrollMetrics = notification.metrics;
                if (scrollMetrics.minScrollExtent == 0) {
                  return true;
                } else {
                  return false;
                }
              },
              //下拉刷新回调方法
              onRefresh: _refresh,
              child: NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        floating: true,
                        snap: false,
                        expandedHeight: 270.h,
                        title: Text(
                          '首页',
                          style: TextStyle(
                              fontSize: 34.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        pinned: true, // 固定在顶部
                        forceElevated: innerBoxIsScrolled,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                    Color(0xFF3f9af5),
                                    Color(0xFF296fe1)
                                  ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 15.w),
                                    child: Row(
                                        children: _topBarList
                                            .map((item) => _reportItem(item))
                                            .toList()),
                                  )
                                ],
                              )),
                        ),
                        elevation: 0.0,
                      )
                    ];
                  },
                  body: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.w, vertical: 15.h),
                      // controller: _scrollController,
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        final item = _data[index];
                        return _cardItem(
                            item['id'],
                            item['type'],
                            item['inTime'],
                            item['content'],
                            item['msgState'],
                            item['tagValue']);
                      })))),
    ));
  }

  Widget _reportItem(item) {
    return Expanded(
        flex: 1,
        child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                switch (item['id']) {
                  case 1:
                    return ReportDevicePage();
                  case 2:
                    return ReportPositionPage();
                  case 3:
                    return ReportResourcePage();
                  case 4:
                    return ReportSituationPage();
                  default:
                    return ReportSituationPage();
                }
              }));
            },
            child: Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 46.sp,
                    backgroundColor: Colors.transparent,
                    child: Image.asset('images/${item['icon']}.png'),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    child: Text(
                      item['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 24.sp),
                    ),
                  )
                ],
              ),
            )));
  }

  /// 指令Item
  Widget _cardItem(int commandId, int type, String time, String content,
      int state, String tag) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CommandDetailPage(
                    commandId: commandId,
                    type: type,
                    content: content,
                    time: time,
                    state: state,
                    tag: tag))).then((value) {
          if (value) _refresh();
        });
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          height: 240.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      time,
                      style: TextStyle(fontSize: 26.sp),
                    ),
                  ),
                  _tagWidget(tag),
                  _stateWidget(state)
                ],
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  type == messageTypeEnum['Text'] ? '[文字指令]$content' : '[语音指令]',
                  softWrap: true,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(color: Colors.black54),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  /// 状态
  Widget _stateWidget(int state) {
    return Container(
      width: 100.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6.sp)),
          color: state == commandStateEnum['unread']
              ? Color.fromARGB(255, 248, 90, 79)
              : state == commandStateEnum['read']
                  ? Colors.black26
                  : Color.fromARGB(255, 82, 168, 238)),
      alignment: Alignment.center,
      child: Text(
        commandStateEnum['Types'][state],
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  /// 标签
  Widget _tagWidget(String tag) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.sp)),
        border: Border.all(
          width: 1.w,
          color: Colors.blueAccent,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        tag,
        style: TextStyle(color: Colors.blueAccent),
      ),
    );
  }
}
