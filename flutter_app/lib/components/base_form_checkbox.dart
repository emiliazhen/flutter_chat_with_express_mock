import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_app/components/index.dart';
import 'package:flutter_app/utils/dialog.dart';

class BaseFormCheckBox extends StatefulWidget {
  const BaseFormCheckBox(
      {super.key,
      this.items = const [],
      this.values = const [],
      this.minLength = 1,
      this.title = '',
      required this.changed});
  final int minLength;
  final String title;
  final List<dynamic> items;
  final List<dynamic> values;
  final Function changed;

  @override
  State<BaseFormCheckBox> createState() => _BaseFormCheckBoxState();
}

class _BaseFormCheckBoxState extends State<BaseFormCheckBox> {
  String _valuesText = '';
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => FormCheckBoxItem(
              items: widget.items,
              values: widget.values,
              minLength: widget.minLength,
              title: widget.title,
              onSubmit: (valueList, nameList) {
                widget.changed(valueList);
                setState(() {
                  _valuesText = nameList.join('，');
                });
              }),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(_valuesText == '' ? '请选择' : _valuesText,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: Theme.of(context).hintColor,
                    ))),
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
    );
  }
}

class FormCheckBoxItem extends StatefulWidget {
  const FormCheckBoxItem({
    super.key,
    required this.items,
    required this.values,
    required this.minLength,
    required this.title,
    required this.onSubmit,
  });
  final List<dynamic> items;
  final List<dynamic> values;
  final int minLength;
  final String title;
  final Function onSubmit;

  @override
  State<FormCheckBoxItem> createState() => _FormCheckBoxItemState();
}

class _FormCheckBoxItemState extends State<FormCheckBoxItem> {
  List<dynamic> _itemList = [];
  bool _checkAll = false;

  @override
  void initState() {
    super.initState();
    _itemList = widget.items.map((e) {
      e['checked'] = widget.values.contains(e['KeyId']);
      return e;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: setCustomAppBar(context, '请选择${widget.title}', actions: [
        TextButton(
          child: const Text(
            '确定',
            style: TextStyle(color: Color(0xffffffff)),
          ),
          onPressed: () {
            List valueList = [];
            List nameList = [];
            for (var item in _itemList) {
              if (item['checked']) {
                valueList.add(item['KeyId']);
                nameList.add(item['Value']);
              }
            }
            if (valueList.length < widget.minLength) {
              UtilDialog.showMessage(context, '请至少需要选择${widget.minLength}项！');
              return;
            }
            widget.onSubmit(valueList, nameList);
            Navigator.of(context).pop();
          },
        ),
      ]),
      body: Column(
        children: [
          CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              value: _checkAll,
              title: Text('所有'),
              onChanged: (value) {
                setState(() {
                  _checkAll = value!;
                  for (var item in _itemList) {
                    item['checked'] = value;
                  }
                });
              }),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: _itemList.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(_itemList[index]['Value']),
                    value: _itemList[index]['checked'],
                    onChanged: (value) {
                      setState(() {
                        _itemList[index]['checked'] = value;
                        _checkAll = _itemList.every((item) => item['checked']);
                      });
                    },
                  );
                }),
          )
        ],
      ),
    );
  }
}
