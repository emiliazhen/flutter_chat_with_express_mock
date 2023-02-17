import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:intl/intl.dart';

// 日期选择器
class BasePickerDate extends StatefulWidget {
  BasePickerDate({Key? key, this.changeDateFn, this.startTime, this.format, this.mode, this.currentSelected}) : super(key: key);
  final Function? changeDateFn;
  final int? startTime;
  final DateTime? currentSelected;
  final String? format;
  final String? mode;

  @override
  _BasePickerDate createState() => _BasePickerDate();
}

class _BasePickerDate extends State<BasePickerDate> {
  DateTime? _currentSelected;
  int? _type;
  @override
  void initState() {
    super.initState();

    _currentSelected = widget.currentSelected is DateTime ? widget.currentSelected! : DateTime.now();
    if (widget.mode == 'day') {
      _type = PickerDateTimeType.kYMD;
    } else if (widget.mode == 'time') {
      _type = PickerDateTimeType.kYMDHMS;
    } else {
      _type = PickerDateTimeType.kYM;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat(widget.format is String ? widget.format : 'yyyy-MM').format(_currentSelected!),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.normal,
                color: Color(0xff333333),
              ),
            ),
            Container(
              width: 34.w,
              margin: EdgeInsets.only(left: 12.w),
              child: Center(
                child: Icon(
                  Icons.navigate_next,
                  color: Color(0xffc7c7cc),
                  size: 46.sp,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Picker(
            confirmText: '确认',
            cancelText: '取消',
            confirmTextStyle: TextStyle(color: Color(0xff2294e2), fontSize: 34.sp),
            cancelTextStyle: TextStyle(color: Color(0xff2294e2), fontSize: 34.sp),
            adapter: DateTimePickerAdapter(
                type: _type!, isNumberMonth: true, yearBegin: widget.startTime is int ? widget.startTime : 2010, yearEnd: DateTime.now().year + 1, value: _currentSelected!),
            delimiter: [
              PickerDelimiter(
                child: Container(
                  width: 30.0,
                  alignment: Alignment.center,
                  child: Icon(Icons.more_vert),
                ),
              )
            ],
            onConfirm: (Picker picker, List<int> list) {
              _currentSelected = DateTime.parse(picker.adapter.text);
              widget.changeDateFn!(_currentSelected, picker.adapter.text);
            }).showModal(context);
      },
    );
  }
}
