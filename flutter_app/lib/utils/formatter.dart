import 'package:intl/intl.dart';
import 'dart:convert';

/// 数据格式化
class FormatterUtil {
  /// 所有日期格式化
  /// 默认省略当前年的数据
  static List<String> ignore = ['1900', '9999'];

  /// 显示的时间格式化; 精确到时分秒
  static String filterDateTime(String value,
      {String formatter = 'yyyy-MM-dd HH:mm:ss'}) {
    if (value.isEmpty) {
      return '-';
    }
    String year = DateFormat('yyyy').format(DateTime.parse(value));
    if (ignore.contains(year)) {
      return '-';
    }
    if (year == DateTime.now().year.toString()) {
      return DateFormat(formatter.replaceAll('yyyy-', ''))
          .format(DateTime.parse(value));
    }
    return DateFormat(formatter).format(DateTime.parse(value));
  }

  /// 显示的时间格式化; 精确到时分
  static String filterDateMinutes(value,
      {String formatter = 'yyyy-MM-dd HH:mm'}) {
    if (value.isEmpty) {
      return '-';
    }
    String year = DateFormat('yyyy').format(DateTime.parse(value));
    if (ignore.contains(year)) {
      return '-';
    }
    if (year == DateTime.now().year.toString()) {
      return DateFormat(formatter.replaceAll('yyyy-', ''))
          .format(DateTime.parse(value));
    }
    return DateFormat(formatter).format(DateTime.parse(value));
  }

  /// 显示的时间格式化; 精确到日
  static String filterDate(value, {String formatter = 'yyyy-MM-dd'}) {
    if (value.isEmpty) {
      return '-';
    }
    String year = DateFormat('yyyy').format(DateTime.parse(value));
    if (ignore.contains(year)) {
      return '-';
    }
    if (year == DateTime.now().year.toString()) {
      return DateFormat(formatter.replaceAll('yyyy-', ''))
          .format(DateTime.parse(value));
    }
    if (year == '2100') {
      return '长期';
    }
    return DateFormat(formatter).format(DateTime.parse(value));
  }

  /// 显示的时间格式化; 精确到月
  static String filterMonth(value, {String formatter = 'yyyy-MM'}) {
    if (value.isEmpty) {
      return '-';
    }
    String year = DateFormat('yyyy').format(DateTime.parse(value));
    if (ignore.contains(year)) {
      return '-';
    }
    if (year == DateTime.now().year.toString()) {
      return DateFormat(formatter.replaceAll('yyyy-', ''))
          .format(DateTime.parse(value));
    }
    return DateFormat(formatter).format(DateTime.parse(value));
  }

  /// 显示的时间格式化; 精确到年
  static String filterYear(value, {String formatter = 'yyyy'}) {
    if (value.isEmpty) {
      return '-';
    }
    String year = DateFormat('yyyy').format(DateTime.parse(value));
    if (ignore.contains(year)) {
      return '-';
    }
    return DateFormat(formatter).format(DateTime.parse(value));
  }

  /// 显示的时间格式化; 如：今天 10:00 昨天：10:00 前天：10:00 2019-09-09 10:00
  static String filterTimeTag(value) {
    if (value.isEmpty) {
      return '未知';
    }
    DateTime time = DateTime.parse(value);
    int year = int.parse(DateFormat('yyyy').format(time));
    int month = int.parse(DateFormat('MM').format(time));
    int day = int.parse(DateFormat('dd').format(time));
    String hour = DateFormat('HH:mm').format(time);
    if (ignore.contains(year.toString())) {
      return '未知';
    }
    DateTime now = DateTime.now();
    if (year == now.year && month == now.month) {
      if (day == now.day) {
        return '今天' + hour;
      } else if (now.day - day == 1) {
        return '昨天' + hour;
      } else if (now.day - day == 2) {
        return '前天' + hour;
      }
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(value));
  }

  /// 关于金重，价格，比率的显示转换
  /// value
  /// fixed
  /// rate
  /// showminus不显示负数
  static String filterFloat(value,
      {int fixed = 2,
      int rate = 10000,
      String prefix = '',
      String postfix = '',
      bool showminus = true}) {
    if (value == null || value == '' || (!showminus && value < 0)) {
      value = 0;
    }
    if (value is String) {
      value = double.parse(value);
    }
    return '$prefix${(value / rate).toStringAsFixed(fixed)}$postfix';
  }

  /// 关于金重，价格，比率的保存转换
  /// value
  /// rate
  static int filterInt(value, {int rate = 10000}) {
    if (value == null || value == '') {
      return 0;
    }
    if (value is String) {
      value = double.parse(value);
    }
    return int.parse((value * rate).toStringAsFixed(0));
  }

  /// 价格千位显示转换 eg: 12345678.90 => 12,345,678.90
  /// value
  /// fixed
  /// rate
  /// showminus不显示负数
  static String filterFloatRead(value,
      {int fixed = 2,
      int rate = 10000,
      String prefix = '',
      String postfix = '',
      bool showminus = true}) {
    if (value == null || value == '' || (!showminus && value < 0)) {
      value = 0;
    }
    if (value is String) {
      value = double.parse(value);
    }
    String str = '$prefix${(value / rate).toStringAsFixed(fixed)}$postfix';
    int dotIndex = str.indexOf('.');
    String strLeft = str;
    String strRight = '';
    if (dotIndex > -1) {
      strLeft = str.substring(0, dotIndex);
      strRight = str.substring(dotIndex);
    }
    Iterable strLeftReverse = strLeft.split('').reversed;
    int tmpIndex = 0;
    List arr = [];
    String tmpStr = '';
    for (var item in strLeftReverse) {
      tmpStr = tmpStr + item;
      if (tmpIndex < 2) {
        tmpIndex++;
      } else {
        arr.add(tmpStr);
        tmpStr = '';
        tmpIndex = 0;
      }
    }
    if (tmpIndex < 3 && tmpIndex != 0) {
      arr.add(tmpStr);
    }
    List strLeftList = [];
    for (var item in arr) {
      strLeftList.insert(0, item.split('').reversed.join(''));
    }
    strLeft = strLeftList.join(',');
    return '$strLeft$strRight';
  }

  // 消息时间
  static String filtersMsgTime(int lastMsgTime) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String dateOriginal =
        formatter.format(DateTime.fromMillisecondsSinceEpoch(lastMsgTime));
    DateTime today = DateTime.now();
    DateTime standardDate =
        DateTime(today.year, today.month, today.day, 23, 59, 59);
    //传入的日期与今天的23:59:59秒进行比较
    Duration diff = standardDate.difference(DateTime.parse(dateOriginal));
    if (diff < Duration(days: 1)) {
      return dateOriginal.substring(11, 16);
    } else if (diff >= Duration(days: 1) && diff < Duration(days: 2)) {
      return "昨天 " + dateOriginal.substring(11, 16);
    } else {
      return dateOriginal.substring(0, 16);
    }
  }

  //将秒 转化成  00：00格式
  static String filtersExamTime(int seconds) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    if (hour <= 0) {
      return _formatTime(minute) + ":" + _formatTime(second);
    } else {
      return _formatTime(hour) +
          ":" +
          _formatTime(minute) +
          ":" +
          _formatTime(second);
    }
  }

  static String _formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  // 返回是否是Map
  static bool isMapIfy(String str) {
    bool result = false;
    try {
      var obj = jsonDecode(str);
      if (obj is Map) {
        result = true;
      }
    } catch (e) {
      result = false;
    }
    return result;
  }

  // 时长转时间 h:mm:ss
  static String formatDurationToTimeStr(Duration duration) {
    String hours = duration.inHours.toString().padLeft(0, '2');
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }
}
