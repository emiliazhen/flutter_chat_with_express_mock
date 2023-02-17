import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 浮点输入框
class FormDoubleInput extends StatelessWidget {
  FormDoubleInput(
      {Key? key,
      this.maxlength = 9,
      this.hint = '点击输入',
      this.startValue,
      this.endValue,
      this.keyboardType = TextInputType.text, // 默认文字，有数字电话链接等
      this.inputFormatters = const [],
      this.required = false,
      this.changeStart,
      this.changeEnd})
      : super(key: key);

  final int maxlength;
  final String hint;
  final String? startValue;
  final String? endValue;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool required;
  final Function? changeStart;
  final Function? changeEnd;

  final FocusNode startFsNode = new FocusNode();
  final FocusNode endFsNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: startValue,
            maxLength: maxlength,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26.sp,
              color: Color(0xff333333),
            ),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(
                vertical: 30.h,
              ),
            ),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onSaved: (value) {
              changeStart!(value);
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              '-',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: endValue,
            maxLength: maxlength,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26.sp,
              color: Color(0xff333333),
            ),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(
                vertical: 30.h,
              ),
            ),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onSaved: (value) {
              changeEnd!(value);
            },
          ),
        ),
      ],
    );
  }
}
