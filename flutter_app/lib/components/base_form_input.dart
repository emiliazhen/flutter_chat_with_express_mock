import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 输入框
class BaseFormInput extends StatelessWidget {
  BaseFormInput(
      {Key? key,
      this.maxLength = 30,
      this.hint = '请输入',
      this.value = '',
      this.keyboardType = TextInputType.text, // 默认文字，有数字电话链接等
      this.textAlign = TextAlign.start,
      this.required = false,
      this.focusNode,
      this.enabled = true,
      this.changed,
      this.onChange})
      : super(key: key);
  final int maxLength;
  final String hint;
  final String value;
  final TextInputType keyboardType;
  final bool required;
  final Function? changed;
  final Function? onChange;
  final TextAlign textAlign;
  final FocusNode? focusNode;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      enabled: enabled,
      focusNode: focusNode,
      maxLength: maxLength,
      textAlign: textAlign,
      style: TextStyle(
          fontSize: 26.sp,
          color: Color(0xff333333),
          textBaseline: TextBaseline.alphabetic),
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        counterText: '',
        contentPadding: EdgeInsets.symmetric(
          vertical: 10.h,
        ),
      ),
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.words,
      onChanged: (value) {
        if (onChange is Function) {
          onChange!(value);
        }
      },
      onFieldSubmitted: (value) {
        changed!(value);
      },
    );
  }
}
