import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_app/components/photo_view_simple.dart';
import 'package:flutter_app/utils/dialog.dart';
import 'package:flutter_app/components/index.dart';
import 'package:flutter_app/enum/index.dart';

// 资源上报
class ReportResourcePage extends StatefulWidget {
  ReportResourcePage({Key? key}) : super(key: key);

  @override
  _ReportResourcePageState createState() => _ReportResourcePageState();
}

class _ReportResourcePageState extends State<ReportResourcePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _imageFile;
  Map _form = {
    'water': '',
    'oil': '',
    'note': '',
  };
  final List _departmentType = departmentEnum['TypeArray'];
  final List _eventType = eventEnum['TypeArray'];
  final ImagePicker _picker = ImagePicker();
  final FocusNode _focusNodeWater = FocusNode();
  final FocusNode _focusNodeOil = FocusNode();
  final FocusNode _focusNodeNote = FocusNode();

  void _pictureTap() async {
    _focusNodeWater.unfocus();
    _focusNodeOil.unfocus();
    _focusNodeNote.unfocus();
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
    _focusNodeWater.unfocus();
    _focusNodeOil.unfocus();
    _focusNodeNote.unfocus();
    UtilDialog.showMessage(context, '提交成功！');
    setState(() {
      _form = {
        'water': '',
        'oil': '',
        'note': '',
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
    _focusNodeWater.dispose();
    _focusNodeOil.dispose();
    _focusNodeNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: setCustomAppBar(
          context,
          '资源上报',
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
                  label: '淡水余量',
                  childVerticalPadding: 0,
                  child: BaseFormInput(
                    value: _form['water'],
                    hint: '请输入淡水余量',
                    focusNode: _focusNodeWater,
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
                  label: '柴油余量',
                  childVerticalPadding: 0,
                  child: BaseFormInput(
                    value: _form['oil'],
                    hint: '请输入柴油余量',
                    focusNode: _focusNodeOil,
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
                  label: '备注',
                  childVerticalPadding: 0,
                  child: BaseFormInput(
                    value: _form['note'],
                    hint: '请输入备注',
                    focusNode: _focusNodeNote,
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
              // BaseFormGroup(
              //   label: '事件',
              //   childVerticalPadding: 0,
              //   childHorizontalPadding: 10,
              //   hasChildBg: false,
              //   child: BaseFormRadio(
              //     value: _form['event'],
              //     items: List.from(_eventType),
              //     changed: (value) {
              //       _focusNode.unfocus();
              //       setState(() {
              //         _form['event'] = value;
              //       });
              //     },
              //   ),
              // ),
              // BaseFormGroup(
              //   label: '部门',
              //   child: BaseFormPicker(
              //     items: _departmentType,
              //     value: _form['department'],
              //     changed: (value) {
              //       _focusNode.unfocus();
              //       setState(() {
              //         _form['department'] = value;
              //       });
              //     },
              //   ),
              // ),
              // BaseFormGroup(
              //     label: '日期',
              //     child: BasePickerDate(
              //         mode: 'day',
              //         format: 'yyyy年MM月dd日',
              //         changeDateFn: (time, timeStr) {
              //           setState(() {
              //             _form['dateTime'] = timeStr;
              //           });
              //         })),
              // BaseFormGroup(
              //   label: '图片',
              //   childVerticalPadding: 0,
              //   childHorizontalPadding: 0,
              //   child: GestureDetector(
              //     onTap: _pictureTap,
              //     child: Container(
              //         height: 200.h,
              //         alignment: Alignment.center,
              //         decoration:
              //             const BoxDecoration(color: Colors.transparent),
              //         child: _form['imgUrl'] == ''
              //             ? Icon(
              //                 Icons.camera_alt_outlined,
              //                 size: 70.sp,
              //                 color: const Color(0xFFbabdbc),
              //               )
              //             : SizedBox(
              //                 width: 1.sw - 60.w,
              //                 child: Image.file(
              //                   _imageFile!,
              //                   fit: BoxFit.fitWidth,
              //                 ),
              //               )),
              //   ),
              // ),
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
