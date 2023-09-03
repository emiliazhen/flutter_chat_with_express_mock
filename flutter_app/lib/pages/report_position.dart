import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_app/utils/dialog.dart';
import 'package:flutter_app/components/index.dart';
import 'package:flutter_app/apis/index.dart';
import 'package:flutter_app/shared/index.dart';

// 位置上报
class ReportPositionPage extends StatefulWidget {
  ReportPositionPage({Key? key}) : super(key: key);

  @override
  _ReportPositionPageState createState() => _ReportPositionPageState();
}

class _ReportPositionPageState extends State<ReportPositionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map _form = {
    'section': '',
    'id': -1,
  };
  int _sectionIndex = -1;
  List _sectionList = [];
  List _floorList = [];

  void _submit() {
    if (_form['section'] == '') {
      UtilDialog.showMessage(context, '请选择室！');
      return;
    }
    if (_form['id'] == -1) {
      UtilDialog.showMessage(context, '请选择层！');
      return;
    }
    apiPersonLocationReport(context, data: _form).then((res) {
      if (res.data['code'] == 200 && mounted) {
        UtilDialog.showMessage(context, '提交成功！');
        Navigator.of(context).pop();
      }
    });
  }

  void getSectionList() {
    apiGetType(context).then((res) {
      if (res.data['code'] == 200 && mounted) {
        setState(() {
          _form['boatType'] = res.data['data'];
        });
        apiGetSectionList(context, data: {'boatType': _form['boatType']})
            .then((res2) {
          if (res2.data['code'] == 200) {
            int index = -1;
            List resList = [];
            for (var element in res2.data['rows']) {
              index++;
              resList.add({'KeyId': index, 'Value': element['section']});
            }
            setState(() {
              _sectionList = resList;
            });
          }
        });
      }
    });
  }

  void sectionChange(value) {
    setState(() {
      _sectionIndex = value;
      _form['section'] = _sectionList[value]['Value'];
      _form['id'] = -1;
    });
    apiGetFloorList(context, data: _form).then((res) {
      if (res.data['code'] == 200) {
        setState(() {
          _floorList = res.data['data'].map((e) {
            return {'KeyId': e['id'], 'Value': e['floor']};
          }).toList();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _form['personId'] = SharedPreferencesUtil.userInfo['userId'];
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      getSectionList();
    });
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
          '位置上报',
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
                label: '室',
                childVerticalPadding: 0,
                childHorizontalPadding: 10,
                hasChildBg: false,
                child: BaseFormRadio(
                    value: _sectionIndex,
                    items: _sectionList,
                    changed: sectionChange),
              ),
              Offstage(
                offstage: _sectionIndex == -1,
                child: BaseFormGroup(
                  label: '所处层',
                  childVerticalPadding: 0,
                  childHorizontalPadding: 10,
                  hasChildBg: false,
                  child: BaseFormRadio(
                    value: _form['id'],
                    items: _floorList,
                    changed: (value) {
                      setState(() {
                        _form['id'] = value;
                      });
                    },
                  ),
                ),
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
