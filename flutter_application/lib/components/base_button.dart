import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 按钮
class BaseButton extends StatelessWidget {
  BaseButton(
      {Key? key,
      required this.submit,
      required this.title,
      this.horizontalMargin = 35})
      : super(key: key);
  final VoidCallback submit;
  final String title;
  final int horizontalMargin;
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80.h,
        margin: EdgeInsets.symmetric(
          vertical: 20.h,
          horizontal: horizontalMargin.w,
        ),
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF3b9afa), Color(0xFF266adc)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
            borderRadius: BorderRadius.all(Radius.circular(40))),
        child: GestureDetector(
          onTap: submit,
          child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Text(
              title,
              style: TextStyle(fontSize: 30.sp, color: Colors.white),
            ),
          ),
        ));
  }
}
