import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseFormCheckboxBlock extends StatefulWidget {
  const BaseFormCheckboxBlock({super.key});

  @override
  State<BaseFormCheckboxBlock> createState() => _BaseFormCheckboxBlockState();
}

class _BaseFormCheckboxBlockState extends State<BaseFormCheckboxBlock> {
  List _data = [
    {'label': 'a3sde32efe4w', 'value': 0},
    {'label': 'ew33gfw23', 'value': 1},
    {'label': 'g4334g3', 'value': 2},
    {'label': 'g54g3f23', 'value': 3},
    {'label': 'g54gh4', 'value': 4},
    {'label': 'r342tg', 'value': 5},
    {'label': 'h56h12', 'value': 6},
    {'label': 'f34g5hg456h65', 'value': 7},
    {'label': '354tg54', 'value': 8},
    {'label': 'g43g43', 'value': 9},
    {'label': '4g34', 'value': 10},
  ];
  List _selectedList = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: _data.map((item) => _checkboxItem(item)).toList(),
      ),
    );
  }

  Widget _checkboxItem(item) {
    bool isChecked = _selectedList.contains(item['value']);
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked
              ? _selectedList.remove(item['value'])
              : _selectedList.add(item['value']);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
        decoration: BoxDecoration(
            border: Border.all(
              color: isChecked ? Colors.blueAccent : Colors.black54,
            ),
            borderRadius: BorderRadius.all(Radius.circular(16.sp)),
            color: isChecked ? Colors.blueAccent : Colors.transparent),
        child: Text(
          item['label'],
          style: TextStyle(
              fontSize: 26.sp,
              color: isChecked ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}
