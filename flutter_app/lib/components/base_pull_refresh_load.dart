import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 上拉加载，下拉刷新
class BasePullRefreshLoad extends StatefulWidget {
  // 可以嵌套头部widget的上下拉加载
  BasePullRefreshLoad(
    this.data,
    this.total,
    this.isLoading,
    this.itemBuilder, {
    Key? key,
    this.refresh,
    this.loadMore,
    this.topWidget,
    this.controller,
    this.finishedText = '-- 我是有底线的 --',
  }) : super(key: key);

  /// 数据集
  final List<dynamic> data;

  /// 加载状态
  final bool isLoading;

  /// 总条数
  final int total;

  /// widget渲染函数
  final Function itemBuilder;

  /// 下拉刷新回调
  final Function? refresh;

  /// 上啦加载回调
  final Function? loadMore;

  /// 列表最上方插入widget
  final Widget? topWidget;

  /// 加载完的提示文本
  final String finishedText;

  /// 外部传入滚动控制器控制
  final TrackingScrollController? controller;

  @override
  State<StatefulWidget> createState() {
    return _BasePullRefreshLoadState();
  }
}

class _BasePullRefreshLoadState extends State<BasePullRefreshLoad> {
  TrackingScrollController _scrollController = TrackingScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _scrollController = widget.controller!;
    }
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      // 当没去到底部的时候，maxScrollExtent和offset会相等，可以准确的判断到达底部还有多少距离时开始加载数据了。。
      if (_scrollController.mostRecentlyUpdatedPosition!.maxScrollExtent >= _scrollController.offset &&
          _scrollController.mostRecentlyUpdatedPosition!.maxScrollExtent - _scrollController.offset <= 50) {
        // 要加载更多
        if (widget.data.length < widget.total && !widget.isLoading) {
          _loader();
        }
      }
    }
    return true;
  }

  Future<Null> _refresh() async {
    if (widget.refresh is Function) widget.refresh!();
  }

  Future<Null> _loader() async {
    if (widget.loadMore is Function) widget.loadMore!();
  }

  returnWidgetList() {
    List<Widget> widgetList = [];
    if (widget.topWidget != null) {
      widgetList.add(widget.topWidget!);
    }
    for (var i = 0; i < widget.data.length; i++) {
      widgetList.add(widget.itemBuilder(widget.data[i]));
    }
    widgetList.add(_Loading(
      isLoading: widget.isLoading,
      len: widget.data.length,
      count: widget.total,
      finishedText: widget.finishedText,
    ));

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: _onNotification,
      child: RefreshIndicator(
        child: ListView(
          padding: EdgeInsets.all(0),
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          children: returnWidgetList() ?? <Widget>[Center()],
        ),
        onRefresh: _refresh,
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  _Loading({Key? key, required this.isLoading, this.len = 0, this.count = 0, required this.finishedText}) : super(key: key);
  final bool isLoading;
  final int len;
  final int count;
  final String finishedText;

  final TextStyle styles = TextStyle(
    color: Color(0xff999999),
    fontSize: 24.sp,
  );

  Widget _buildLoading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 30.w,
          height: 30.w,
          margin: EdgeInsets.only(right: 10.w),
          child: CircularProgressIndicator(
            strokeWidth: 3.w,
          ),
        ),
        Text(
          '正在努力加载,请稍候...',
          style: styles,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: isLoading
            ? _buildLoading()
            : (len == 0 && count == 0) // 不传入 len 与 count时 不显示任何Widget
                ? null
                : len < count
                    ? Text('上拉加载更多', style: styles)
                    : len == 0
                        ? Text('暂无数据')
                        : Text(finishedText, style: styles),
      ),
    );
  }
}
