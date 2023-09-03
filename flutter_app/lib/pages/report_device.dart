import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_app/utils/dialog.dart';
import 'package:flutter_app/components/index.dart';
import 'package:flutter_app/enum/index.dart';
import 'package:flutter_app/apis/index.dart';
import 'package:flutter_app/shared/index.dart';

// 设备上报
class ReportDevicePage extends StatefulWidget {
  ReportDevicePage({Key? key}) : super(key: key);

  @override
  _ReportDevicePageState createState() => _ReportDevicePageState();
}

class _ReportDevicePageState extends State<ReportDevicePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List _checkedDeviceIdList = [];
  final List _deviceType = deviceEnum['TypeArray'];

  void _submit() {
    if (_checkedDeviceIdList.isEmpty) {
      UtilDialog.showMessage(context, '请至少选择一个设备');
      return;
    }
    List paramList = _checkedDeviceIdList.map((e) {
      return {
        'deviceId': e,
        'personId': SharedPreferencesUtil.userInfo['userId']
      };
    }).toList();
    apiPersonDeviceReport(
      context,
      data: {'personDevices': paramList},
    ).then((res) {
      if (res.data['code'] == 200) {
        UtilDialog.showMessage(context, '提交成功！');
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: setCustomAppBar(
          context,
          '携带装备上报',
        ),
        body: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF3f9af5), Color(0xFF296fe1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight)),
            child: ListView(
              children: [
                _formWrapWidget,
              ],
            )));
  }

  Widget get _formWrapWidget => Container(
        margin: EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.w),
        padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 40.w),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              BaseFormGroup(
                label: '携带设备',
                childVerticalPadding: 0,
                childHorizontalPadding: 10,
                hasChildBg: false,
                // child: BaseFormCheckBox(
                //     values: _checkedDeviceIdList,
                //     title: '携带设备',
                //     items: List.from(_deviceType),
                //     changed: (idList) {
                //       setState(() {
                //         _checkedDeviceIdList = idList;
                //       });
                //     }),
                child: BaseFormCheckboxBlock(),
              ),
              BaseButton(
                submit: _submit,
                title: '提交',
                horizontalMargin: 120,
              )
            ],
          ),
        ),
      );
}
