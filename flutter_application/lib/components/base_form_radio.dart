import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 单选
class BaseFormRadio extends StatelessWidget {
  BaseFormRadio(
      {Key? key,
      this.items = const [],
      this.value,
      this.props = const {'key': 'KeyId', 'value': 'Value'},
      this.required = false,
      this.changed})
      : super(key: key);
  final List<dynamic> items;
  final int? value;
  final Map props;
  final bool required;
  final Function? changed;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10.w,
        runSpacing: 8.w,
        alignment: WrapAlignment.start,
        children: items
            .map(
              (dynamic item) => GestureDetector(
                child: Chip(
                  avatar: Container(
                    width: 20.w,
                    height: 20.h,
                    margin: EdgeInsets.only(right: 2.w),
                    child: Radio<int>(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: item[props['key']],
                      groupValue: value,
                      onChanged: (int? curValue) {
                        changed!(curValue);
                      },
                    ),
                  ),
                  label: Text(item[props['value']],
                      style: TextStyle(
                          fontSize: 24.sp, color: const Color(0xFF787878))),
                  backgroundColor: const Color(0xfff3f9f9),
                ),
                onTap: () {
                  changed!(item[props['key']]);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
