import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './base_picker_select.dart';

// 选择器
class BaseFormPicker extends StatelessWidget {
  BaseFormPicker({
    this.items = const [],
    this.value,
    this.disable = false,
    this.props = const {'key': 'KeyId', 'value': 'Value'},
    this.changed,
    this.hasSetting = false,
    this.tapSetting,
    this.loading = false,
  });

  /// 选择列表项
  final List<dynamic> items;

  /// 当前选中value
  final dynamic value;

  final bool disable;

  /// 键值字段 默认{'key': 'Id', 'value': 'Value'}
  final Map props;

  /// 选择变化事件
  final Function? changed;

  /// 选择框右侧设置操作
  final bool hasSetting;

  /// 设置操作事件
  final Function? tapSetting;

  // 在还没有获取到下拉框数据时loading
  final bool loading;
  @override
  Widget build(BuildContext context) {
    Map _item = {};
    items.forEach((i) {
      if (i[props['key']] == value) {
        _item = i;
      }
    });
    return GestureDetector(
      child: loading
          ? Container(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 30.w,
                height: 30.h,
                child: CircularProgressIndicator(
                  strokeWidth: 4.w,
                ),
              ),
            )
          : Container(
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _item[props['value']] ?? '请选择',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.normal,
                          color: disable || _item[props['value']] == '请选择' ? Theme.of(context).hintColor : Color(0xff333333),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 34.w,
                    margin: EdgeInsets.only(left: 12.w),
                    child: Center(
                      child: Icon(
                        Icons.navigate_next,
                        color: Color(0xffc7c7cc),
                        size: 46.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      onTap: () {
        if (disable == true) {
          return;
        }
        showDialog(
          context: context,
          builder: (context) => BasePickerSelect(
            value: value,
            items: items,
            props: props,
            onSelected: (value) {
              changed!(value);
            },
          ),
        );
      },
    );
  }
}
