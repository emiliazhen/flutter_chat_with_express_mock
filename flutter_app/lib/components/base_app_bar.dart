import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 顶部条
setCustomAppBar(BuildContext context, String title,
    {Color? backgroundColor,
    int height = 80,
    List<Widget> actions = const [],
    Widget? leading,
    PreferredSize? bottom,
    VoidCallback? onPop}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(height.h),
    child: AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF3f9af5), Color(0xFF296fe1)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight)),
      ),
      // backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      elevation: 0.0,
      leading: leading ??
          IconButton(
            alignment: Alignment.centerLeft,
            iconSize: 38.sp,
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: onPop ??
                () {
                  Navigator.of(context).maybePop();
                },
          ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 34.sp,
        ),
      ),
      actions: actions,
      centerTitle: true,
      bottom: bottom,
    ),
  );
}
