import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './base_app_bar.dart';

// 下拉选择器
class BasePickerSelect extends StatefulWidget {
  BasePickerSelect(
      {Key? key,
      this.value,
      this.items = const [],
      this.props = const {'key': 'KeyId', 'value': 'Value'},
      this.onSelected,
      this.json = false,
      this.title = '选择'})
      : super(key: key);
  final dynamic value;
  final List items;
  final Map props;
  final Function? onSelected;

  /// 标题
  final String title;

  /// 是否需要整个json格式
  final bool json;
  @override
  State<StatefulWidget> createState() {
    return BasePickerSelectState();
  }
}

class BasePickerSelectState extends State<BasePickerSelect>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _offsetFloat;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _offsetFloat = Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero)
        .animate(_controller!);
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Widget _buildItem(item) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.centerLeft,
        height: 88.h,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 1.w,
              color: Color(0xffeeeeee),
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                item[widget.props['value']],
                style: TextStyle(
                  fontSize: 30.sp,
                  color:
                      item['disable'] == true ? Colors.grey : Color(0xff666666),
                ),
              ),
            ),
            Offstage(
              offstage: item[widget.props['key']] != widget.value,
              child: Container(
                width: 100.w,
                child: Icon(
                  Icons.done,
                  size: 40.sp,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        if (item['disable'] == true) {
          return;
        }
        widget.onSelected!(widget.json ? item : item[widget.props['key']]);
        _controller!.reverse();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetFloat!,
      child: Scaffold(
        appBar: setCustomAppBar(context, widget.title, onPop: () {
          _controller!.reverse();
          Navigator.of(context).pop();
        }),
        body: ListView(
          padding: EdgeInsets.all(0.0),
          children: widget.items.map((item) => _buildItem(item)).toList(),
        ),
      ),
    );
  }
}
