import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 消息气泡
class BaseToast {
  static const int BOTTOM = 0;
  static const int CENTER = 1;
  static const int TOP = 2;
  static void show(String msg, BuildContext context,
      {int duration = 0,
      int gravity = 0,
      Color backgroundColor = Colors.black,
      Color textColor = Colors.white,
      int backgroundRadius = 5,
      int fontSize = 14,
      bool canclosed = false}) {
    ToastView.dismiss();
    ToastView.createView(msg, context, duration, gravity, backgroundColor, textColor, backgroundRadius, fontSize, canclosed);
  }

  static void close() {
    ToastView.dismiss();
  }
}

class ToastView {
  static final ToastView _singleton = ToastView._internal();

  factory ToastView() {
    return _singleton;
  }

  ToastView._internal();

  static OverlayState? overlayState;
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void createView(String msg, BuildContext context, int duration, int gravity, Color background, Color textColor, int backgroundRadius, int fontSize, bool canclosed) async {
    overlayState = Overlay.of(context);

    Paint paint = Paint();
    paint.strokeCap = StrokeCap.square;
    paint.color = background;

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => ToastWidget(
        widget: InkWell(
          onTap: () {
            if (canclosed) dismiss();
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(
                    backgroundRadius.w,
                  ),
                ),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Text(
                  msg,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: fontSize.sp,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        gravity: gravity,
      ),
    );
    _isVisible = true;
    overlayState!.insert(_overlayEntry!);
    if (duration != 0) {
      await Future.delayed(Duration(seconds: duration));
      dismiss();
    }
  }

  static dismiss() async {
    if (!_isVisible) {
      return;
    }
    _isVisible = false;
    _overlayEntry?.remove();
  }
}

class ToastWidget extends StatelessWidget {
  const ToastWidget({
    Key? key,
    required this.widget,
    required this.gravity,
  }) : super(key: key);

  final Widget widget;
  final int gravity;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: gravity == 2 ? 50 : null,
        bottom: gravity == 0 ? 50 : null,
        child: Material(
          color: Colors.transparent,
          child: widget,
        ));
  }
}
