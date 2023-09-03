import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseLoading extends StatelessWidget {
  const BaseLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 60.w,
        height: 60.w,
        child: CircularProgressIndicator(
          strokeWidth: 4.w,
        ),
      ),
    );
  }
}
