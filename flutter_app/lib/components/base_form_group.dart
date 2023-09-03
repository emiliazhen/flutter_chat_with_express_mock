import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 表单
class BaseFormGroup extends StatelessWidget {
  const BaseFormGroup({
    Key? key,
    required this.child,
    this.label = '',
    this.isRequired = false,
    this.hasChildBg = true,
    this.childVerticalPadding = 20,
    this.childHorizontalPadding = 30,
  }) : super(key: key);
  final Widget child;
  final String label;
  final bool isRequired;
  final bool hasChildBg;
  final int childVerticalPadding;
  final int childHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Column(
        children: [
          _groupLabel,
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: childHorizontalPadding.h,
                vertical: childVerticalPadding.w),
            decoration: hasChildBg
                ? BoxDecoration(
                    color: const Color(0xfff3f9f9),
                    borderRadius: BorderRadius.all(Radius.circular(40.sp)))
                : null,
            clipBehavior: hasChildBg ? Clip.hardEdge : Clip.none,
            child: child,
          )
        ],
      ),
    );
  }

  Widget get _groupLabel => Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.h),
        child: Row(
          children: [
            Offstage(
              offstage: !isRequired,
              child: Padding(
                padding: EdgeInsets.only(top: 7.h, right: 8.w),
                child: Text(
                  '*',
                  style: TextStyle(fontSize: 22.sp, color: Colors.red[300]),
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2e2e2e)),
            )
          ],
        ),
      );
}
