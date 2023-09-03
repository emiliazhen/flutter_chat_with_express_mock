import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_app/components/base_toast.dart';

class UtilDialog {
  /// 消息提示框
  static void showMessage(context, String msg,
      {int duration = 2,
      Color backgroundColor = const Color.fromRGBO(0, 0, 0, 0.6),
      int backgroundRadius = 8,
      Color textColor = Colors.white,
      int fontSize = 24,
      String position = 'Center',
      bool canclosed = true}) {
    final Map<String, dynamic> positionList = {
      'Top': BaseToast.TOP,
      'Center': BaseToast.CENTER,
      'Bottom': BaseToast.BOTTOM,
    };
    // 如果提示信息不是中间，则强制设置关闭响应
    if (position != 'Center' && duration == 0) {
      duration = 2;
    }
    BaseToast.show(
      msg,
      context,
      duration: duration,
      gravity: positionList[position],
      backgroundColor: backgroundColor,
      backgroundRadius: backgroundRadius,
      textColor: textColor,
      fontSize: fontSize,
      canclosed: canclosed,
    );
  }

  /// 关闭showMessage的提示信息
  static void closeMessage() {
    BaseToast.close();
  }

  /// 居中提示框
  static void showCenter(BuildContext context, List<Widget> actions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 4 * 3,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15.sp))),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: actions.map((res) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 25.w),
                    decoration: actions.last == res
                        ? null
                        : BoxDecoration(
                            border: BorderDirectional(
                                bottom: BorderSide(
                                    width: 1.h, color: Color(0xFFeeeeee)))),
                    child: res,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 底部弹出提示框
  static void showBottomSheet(BuildContext context, List<Widget> actions) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: actions.map((res) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 25.w),
                  decoration: actions.last == res
                      ? null
                      : BoxDecoration(
                          border: BorderDirectional(
                            bottom: BorderSide(
                              width: 1.h,
                              color: Color(0xFFeeeeee),
                            ),
                          ),
                        ),
                  child: res,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// loading
  static void showLoading(BuildContext context, {String content = '提交中...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Material(
          //创建透明层
          type: MaterialType.transparency, //透明类型
          child: Center(
            //保证控件居中效果
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 40.w,
                  height: 40.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 4.w,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 22.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 确认框
  static void showConfirm(BuildContext context,
      {String content = '',
      Function? callback,
      String title = '提示',
      Widget? widget,
      showBtn = true}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: content == null ? widget : Text(content),
            actions: showBtn
                ? <Widget>[
                    TextButton(
                      child: Text('取消'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('确定'),
                      onPressed: () {
                        callback!();
                      },
                    ),
                  ]
                : null,
          );
        });
  }
}
