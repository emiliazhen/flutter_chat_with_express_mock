import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/pages/member_detail.dart';
import 'package:flutter_app/provide/user_list.dart';
import 'package:flutter_app/shared/index.dart';
import 'package:flutter_app/components/index.dart';
import 'package:flutter_app/apis/index.dart';

final List<String> memberIndexList = [
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z'
];

/// 成员管理页
class MemberMangerPage extends StatefulWidget {
  MemberMangerPage({Key? key}) : super(key: key);

  @override
  _MemberMangerPageState createState() => _MemberMangerPageState();
}

class _MemberMangerPageState extends State<MemberMangerPage> {
  int _total = 0;
  bool _loading = true;
  Map _queryForm = {
    'pageIndex': 1,
  };
  ScrollController _scrollController = ScrollController();

  /// 刷新
  void _refresh() {
    _getData();
  }

  /// 加载更多
  void _loadMoreData() {
    _getData();
  }

  void _getData() {
    setState(() {
      _loading = true;
    });
    apiUserList(context, data: _queryForm).then((res) {
      setState(() {
        _loading = false;
      });
      if (res.data['code'] == 200) {
        dynamic resData = res.data['data'].map((item) {
          item['indexLetter'] = 'a';
          return item;
        }).toList();
        Provider.of<UserListProvide>(context, listen: false)
            .setUserList(resData.map((e) {
          return {'userId': e['personId'], 'name': e['personName']};
        }).toList());
        setState(() {
          _total = resData.length == 0 ? 0 : resData.length - 1;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: setCustomAppBar(context, '通讯录'),
      body: Column(
        children: <Widget>[
          _searchBar,
          Expanded(
              flex: 1,
              child: Consumer<UserListProvide>(builder: (_, userList, child) {
                List resList = List.from(userList.list);
                // resList.sort((a, b) => a['indexLetter'].compareTo(b['indexLetter']));
                resList.removeWhere((item) =>
                    item['userId'] == SharedPreferencesUtil.userInfo['userId']);
                return ListView.builder(
                    controller: _scrollController,
                    itemCount: resList.length,
                    itemBuilder: (context, index) {
                      return _memberItem(resList[index]);
                      // return _memberViewItem(resList[index], index == 0 || resList[index]['indexLetter'] != resList[index - 1]['indexLetter']);
                    });
              })),
        ],
      ),
    );
  }

  /// 搜索条
  Widget get _searchBar => Container(
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(bottom: BorderSide(width: 1.h, color: Color(0xffefefef)))),
      child: GestureDetector(
          onTap: () {
            showSearch(context: context, delegate: MemberSearchDelegate());
            // Navigator.push(context, MaterialPageRoute(builder: (context) => MemberSearchPage()));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            height: 70.h,
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.sp)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 34.sp,
                  color: Colors.grey,
                ),
                Container(
                  margin: EdgeInsets.only(left: 4.w),
                  child: Text(
                    '搜索',
                    style: TextStyle(fontSize: 26.sp, color: Colors.grey),
                  ),
                )
              ],
            ),
          )));

  /// 成员项
  Widget _memberViewItem(Map item, bool showTitle) {
    return showTitle
        ? Column(
            children: [_memberTitle(item['indexLetter']), _memberItem(item)],
          )
        : _memberItem(item);
  }

  /// 成员标题
  Widget _memberTitle(String title) {
    return GestureDetector(
      onTap: () {
        print(title);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        height: 50.h,
        color: Colors.grey.shade300,
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 26.sp,
            color: Color(0xff999999),
          ),
        ),
      ),
    );
  }

  /// 成员项
  Widget _memberItem(Map item) {
    return GestureDetector(
      child: Container(
          width: 1.sw,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                width: 1.w,
                color: Color(0xffeeeeee),
              ),
            ),
          ),
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                item['name'],
                style: TextStyle(fontSize: 30.sp, color: Color(0xff666666)),
              ))),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MemberDetailPage(
                      memberId: item['userId'],
                      memberName: item['name'],
                    )));
      },
    );
  }
}

/// 成员搜索
class MemberSearchDelegate extends SearchDelegate {
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryTextTheme: theme.textTheme,
    );
  }

  /// 右侧图标
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      )
    ];
  }

  /// 左侧图标
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () => close(context, null));
  }

  /// 结果
  @override
  Widget buildResults(BuildContext context) {
    return _resultListView;
  }

  /// 建议区
  @override
  Widget buildSuggestions(BuildContext context) {
    return _resultListView;
  }

  Widget get _resultListView =>
      Consumer<UserListProvide>(builder: (_, userList, child) {
        List<dynamic> nameList = [];
        userList.list.forEach((item) {
          if (item['userId'] != SharedPreferencesUtil.userInfo['userId']) {
            nameList.add(item);
          }
        });
        final resList = query.isEmpty
            ? []
            : nameList.where((input) => input['name'].contains(query)).toList();
        return ListView.builder(
            itemCount: resList.length,
            itemBuilder: (context, index) {
              dynamic item = resList[index];
              String userName = item['name'];
              int queryIndex = userName.indexOf(query);
              return ListTile(
                onTap: () {
                  close(context, null);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MemberDetailPage(
                                memberId: resList[index]['userId'],
                                memberName: userName,
                              )));
                },
                title: queryIndex < 0
                    ? Text(
                        userName,
                      )
                    : RichText(
                        text: TextSpan(
                            text: userName.substring(0, queryIndex),
                            style:
                                TextStyle(color: Colors.grey, fontSize: 30.sp),
                            children: [
                            TextSpan(
                                text: userName.substring(
                                    queryIndex, queryIndex + query.length),
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: userName
                                    .substring(queryIndex + query.length)),
                          ])),
              );
            });
      });
}
