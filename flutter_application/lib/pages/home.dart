import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_application/components/photo_view_simple.dart';
import 'package:flutter_application/utils/dialog.dart';
import 'package:flutter_application/components/index.dart';
import 'package:flutter_application/enum/index.dart';

// 首页
class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _imageFile;
  Map _form = {
    'name': '',
    'event': 0,
    'department': 0,
    'dateTime': '',
    'imgUrl': '',
  };
  final List _departmentType = departmentEnum['TypeArray'];
  final List _eventType = eventEnum['TypeArray'];
  final ImagePicker _picker = ImagePicker();
  final FocusNode _focusNode = FocusNode();

  void _pictureTap() async {
    _focusNode.unfocus();
    List<Widget> _children = [
      ListTile(
        title: Text(
          "${_form['imgUrl'] == '' ? '上传' : '重新上传'}-相机",
          textAlign: TextAlign.center,
        ),
        onTap: () async {
          Navigator.of(context).pop();
          _pictureChange(ImageSource.camera);
        },
      ),
      ListTile(
        title: Text(
          "${_form['imgUrl'] == '' ? '上传' : '重新上传'}-相册",
          textAlign: TextAlign.center,
        ),
        onTap: () async {
          Navigator.of(context).pop();
          _pictureChange(ImageSource.gallery);
        },
      )
    ];
    if (_form['imgUrl'] != '') {
      _children.insert(
          0,
          ListTile(
            title: const Text(
              "查看",
              textAlign: TextAlign.center,
            ),
            onTap: () async {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PhotoViewSimple(
                            imageProvider: FileImage(_imageFile!),
                          )));
            },
          ));
      _children.add(ListTile(
        title: const Text(
          "删除",
          textAlign: TextAlign.center,
        ),
        onTap: () async {
          Navigator.of(context).pop();
          setState(() {
            _form['imgUrl'] = '';
            _imageFile = null;
          });
        },
      ));
    }
    UtilDialog.showBottomSheet(context, _children);
  }

  void _pictureChange(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo != null) {
        String path = photo.path;
        String suff = path.substring(path.length - 3, path.length);
        if (suff == "gif") {
          UtilDialog.showMessage(context, '不支持GIF图片');
          return;
        }
        String _path = photo.path;
        setState(() {
          _form['imgUrl'] = _path;
          _imageFile = File(_path);
        });
      }
    } catch (e) {
      UtilDialog.showMessage(context, '图片获取失败...');
    }
  }

  void _submit() {
    _focusNode.unfocus();
    if (_form['name'] == '') {
      UtilDialog.showMessage(context, '请输入姓名！');
      return;
    }
    if (_form['event'] == 0) {
      UtilDialog.showMessage(context, '请选择事件！');
      return;
    }
    if (_form['department'] == 0) {
      UtilDialog.showMessage(context, '请选择部门！');
      return;
    }
    if (_form['dateTime'] == '') {
      UtilDialog.showMessage(context, '请选择日期！');
      return;
    }
    if (_form['imgUrl'] == '') {
      UtilDialog.showMessage(context, '请上传图片！');
      return;
    }
    UtilDialog.showMessage(context, '提交成功！');
    setState(() {
      _form = {
        'name': '',
        'event': 0,
        'department': 0,
        'dateTime': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'imgUrl': '',
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _form['dateTime'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: setCustomAppBar(context, '',
            leading: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 30.w),
              child: Text(
                '首页',
                style: TextStyle(fontSize: 34.sp, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )),
        body: Container(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF3f9af5), Color(0xFF296fe1)], begin: Alignment.centerLeft, end: Alignment.centerRight)),
            child: ListView(
              children: [
                _formWrapWidget,
              ],
            )));
  }

  Widget get _formWrapWidget => Container(
        margin: EdgeInsets.symmetric(vertical: 20.h, horizontal: 30.w),
        padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 40.w),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              BaseFormGroup(
                  label: '姓名',
                  childVerticalPadding: 0,
                  child: BaseFormInput(
                    value: _form['name'],
                    hint: '请输入姓名',
                    focusNode: _focusNode,
                    changed: (value) {
                      setState(() {
                        _form['name'] = value;
                      });
                    },
                    onChange: (value) {
                      setState(() {
                        _form['name'] = value;
                      });
                    },
                  )),
              BaseFormGroup(
                label: '事件',
                childVerticalPadding: 0,
                childHorizontalPadding: 10,
                hasChildBg: false,
                child: BaseFormRadio(
                  value: _form['event'],
                  items: List.from(_eventType),
                  changed: (value) {
                    _focusNode.unfocus();
                    setState(() {
                      _form['event'] = value;
                    });
                  },
                ),
              ),
              BaseFormGroup(
                label: '部门',
                child: BaseFormPicker(
                  items: _departmentType,
                  value: _form['department'],
                  changed: (value) {
                    _focusNode.unfocus();
                    setState(() {
                      _form['department'] = value;
                    });
                  },
                ),
              ),
              BaseFormGroup(
                  label: '日期',
                  child: BasePickerDate(
                      mode: 'day',
                      format: 'yyyy年MM月dd日',
                      changeDateFn: (time, timeStr) {
                        setState(() {
                          _form['dateTime'] = timeStr;
                        });
                      })),
              BaseFormGroup(
                label: '图片',
                childVerticalPadding: 0,
                childHorizontalPadding: 0,
                child: GestureDetector(
                  onTap: _pictureTap,
                  child: Container(
                      height: 200.h,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Colors.transparent),
                      child: _form['imgUrl'] == ''
                          ? Icon(
                              Icons.camera_alt_outlined,
                              size: 70.sp,
                              color: const Color(0xFFbabdbc),
                            )
                          : SizedBox(
                              width: 1.sw - 60.w,
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.fitWidth,
                              ),
                            )),
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
