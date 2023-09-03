import 'dart:io';
import 'dart:math';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:flutter_app/components/photo_view_simple.dart';
import 'package:flutter_app/utils/dialog.dart';
import 'package:flutter_app/components/index.dart';
import 'package:flutter_app/enum/index.dart';
import 'package:flutter_app/apis/index.dart';
import 'package:flutter_app/utils/formatter.dart';

// 首页
class CommandDetailPage extends StatefulWidget {
  final int commandId;
  final int type;
  final String content;
  final String time;
  final int state;
  final String tag;
  CommandDetailPage(
      {Key? key,
      required this.commandId,
      required this.type,
      required this.content,
      required this.time,
      required this.state,
      required this.tag})
      : super(key: key);

  @override
  _CommandDetailPageState createState() => _CommandDetailPageState();
}

class _CommandDetailPageState extends State<CommandDetailPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _needPopFresh = false;
  int _currentState = commandStateEnum['read'];

  /// 音频播放器
  final FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();

  /// 音频播放器是否初始化
  bool _mPlayerIsInitialized = false;

  /// 进度条
  double sliderCurrentPosition = 0.0;

  dynamic _playerSubscription;

  /// 时间
  double maxDuration = 1.0;
  String _currentTimeStr = '00:00:00';
  String _endTimeStr = '00:00:00';

  /// 动画控制器
  final List<AnimationController> _controllerList = [];

  /// 动画控件集合
  final List<Widget> _waveList = [];

  /// 动画计时器
  Timer? _waveTimer;

  /// 播放音频
  void _soundPlay() {
    if (!_mPlayerIsInitialized) {
      return;
    }
    _startAnimation();
    if (_mPlayer.isStopped) {
      _mPlayer
          .startPlayer(
              fromURI: widget.content,
              codec: kIsWeb ? Codec.opusWebM : Codec.pcm16WAV,
              whenFinished: () {
                print('💦----------------Finish');
                _disposeSearchAnimation();
                setState(() {
                  _currentTimeStr = '0:00:00';
                  sliderCurrentPosition = 0.0;
                });
              })
          .then((value) {
        print('☮----------------$value');
        if (value != null) {
          setState(() {
            _endTimeStr = FormatterUtil.formatDurationToTimeStr(value);
          });
        }
        _playerSubscription = _mPlayer.onProgress!.listen((e) {
          maxDuration = e.duration.inMilliseconds.toDouble();
          if (maxDuration <= 0) maxDuration = 0.0;

          sliderCurrentPosition =
              min(e.position.inMilliseconds.toDouble(), maxDuration);
          if (sliderCurrentPosition < 0.0) {
            sliderCurrentPosition = 0.0;
          }
          setState(() {
            _currentTimeStr = FormatterUtil.formatDurationToTimeStr(
                Duration(seconds: e.position.inSeconds));
          });
        });
      });
    }
    if (_mPlayer.isPaused) {
      _mPlayer.resumePlayer();
    }
  }

  /// 停止播放音频
  void _stopSoundPlay() {
    _mPlayer.stopPlayer().then((value) {
      setState(() {});
    });
  }

  /// 暂停播放
  void _pauseSoundPlay() async {
    _disposeSearchAnimation();
    await _mPlayer.pausePlayer();
  }

  /// 跳转时间播放
  Future<void> _seekToPlayer(int milliSecs) async {
    //playerModule.logger.d('-->seekToPlayer');
    try {
      if (_mPlayer.isPlaying) {
        await _mPlayer.seekToPlayer(Duration(milliseconds: milliSecs));
      }
    } on Exception catch (err) {
      _mPlayer.logger.e('error: $err');
    }
    setState(() {});
    //playerModule.logger.d('<--seekToPlayer');
  }

  /// 初始化动画，依次添加5个缩放动画，形成水波纹动画效果
  void _startAnimation() {
    // 动画启动前确保_waveList控件总数为0
    _waveList.clear();
    int count = 0;
    //添加第一个圆形缩放动画
    _addSearchAnimation(true);
    //以后每隔1秒，再次添加一个缩放动画，总共添加4个
    _waveTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _addSearchAnimation(true);
      count++;
      if (count >= 4) {
        timer.cancel();
      }
    });
  }

  /// 添加蓝牙检索动画控件 init: 首次添加5个基本控件时，=true，
  void _addSearchAnimation(bool init) {
    var controller = _createController();
    _controllerList.add(controller);
    print("tag——children length : ${_waveList.length}");
    var animation = Tween(begin: 50.0, end: 290.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    if (!init) {
      //5个基本动画控件初始化完成的情况下，每次添加新的动画控件时，移除第一个，确保动画控件始终保持5个
      _waveList.removeAt(0);
      //添加新的动画控件
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        //动画页面没有执行退出情况下，继续添加动画
        _waveList.add(AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget? child) {
              return Opacity(
                // opacity: (300.0 - animation.value) / 300.0,
                opacity: 1.0 - ((animation.value - 50.0) / 240.0),
                child: ClipOval(
                  child: Container(
                    width: animation.value,
                    height: animation.value,
                    color: const Color(0xff9fbaff),
                  ),
                ),
              );
            }));
        try {
          //动画页退出时，捕获可能发生的异常
          controller.forward();
          setState(() {});
        } catch (e) {
          return;
        }
      });
    } else {
      _waveList.add(AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: 1.0 - ((animation.value - 50.0) / 240.0),
              child: ClipOval(
                child: Container(
                  width: animation.value,
                  height: animation.value,
                  color: const Color(0xff9fbaff),
                ),
              ),
            );
          }));
      controller.forward();
      setState(() {});
    }
  }

  /// 创建蓝牙检索动画控制器
  AnimationController _createController() {
    var controller = AnimationController(
        duration: const Duration(milliseconds: 4000), vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        if (_controllerList.contains(controller)) {
          _controllerList.remove(controller);
        }
        //每次动画控件结束时，添加新的控件，保持动画的持续性
        if (mounted) _addSearchAnimation(false);
      }
    });
    return controller;
  }

  ///监听应用状态，
  /// 生命周期变化时回调
  /// resumed:应用可见并可响应用户操作
  /// inactive:用户可见，但不可响应用户操作
  /// paused:已经暂停了，用户不可见、不可操作
  /// suspending：应用被挂起，此状态IOS永远不会回调
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      //应用退至后台，销毁蓝牙检索动画
      _disposeSearchAnimation();
    } else if (state == AppLifecycleState.resumed) {
      //应用回到前台，重新启动动画
      _startAnimation();
    }
  }

  /// 销毁动画
  void _disposeSearchAnimation() {
    //释放动画所有controller
    for (var element in _controllerList) {
      element.dispose();
    }
    _controllerList.clear();
    _waveTimer?.cancel();
    _waveList.clear();
  }

  /// 未读 -> 已读
  void hasRead() {
    if (widget.state == commandStateEnum['unread']) {
      setState(() {
        _needPopFresh = true;
      });
      apiGetCommandEdit(context,
          data: {'id': widget.commandId, 'msgState': commandStateEnum['read']});
    }
  }

  /// 完成
  void _completeCommand() {
    apiGetCommandEdit(context, data: {
      'id': widget.commandId,
      'msgState': commandStateEnum['complete']
    }).then((res) {
      if (res.data['code'] == 200) {
        setState(() {
          UtilDialog.showMessage(context, '提交成功！');
          _currentState = commandStateEnum['complete'];
          _needPopFresh = true;
        });
      }
    });
  }

  Future<void> initPlayer() async {
    await _mPlayer.openPlayer();
    await _mPlayer.openPlayer();
    _mPlayerIsInitialized = true;
    await _mPlayer.setSubscriptionDuration(const Duration(milliseconds: 10));
    await initializeDateFormatting();
  }

  @override
  void initState() {
    super.initState();
    if (widget.state == commandStateEnum['complete']) {
      _currentState = commandStateEnum['complete'];
    }
    Future.delayed(Duration.zero, () {
      if (mounted) {
        hasRead();
      }
    });
    initPlayer();
    //添加应用生命周期监听
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    if (_playerSubscription != null) {
      _playerSubscription!.cancel();
      _playerSubscription = null;
    }
    _mPlayer.closePlayer();
    _disposeSearchAnimation();
    //销毁应用生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: setCustomAppBar(context, '指令详情', onPop: () {
          Navigator.of(context).pop(_needPopFresh);
        }),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF3f9af5), Color(0xFF296fe1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight)),
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30.sp)),
                    color: Colors.white),
                child: Column(children: [
                  _topInfoWidget,
                  _mainContentWidget,
                  _bottomButtonWidget,
                ]))));
  }

  /// 顶部信息
  Widget get _topInfoWidget => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(widget.time, style: TextStyle(fontSize: 26.sp)),
          ),
          Container(
            width: 100.w,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.sp)),
              border: Border.all(
                width: 1.w,
                color: Colors.blueAccent,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.tag,
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          Container(
              width: 100.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _currentState == commandStateEnum['complete']
                      ? Color.fromARGB(255, 82, 168, 238)
                      : Colors.black26),
              child: Text(
                _currentState == commandStateEnum['complete'] ? '已完成' : '已读',
                style: TextStyle(color: Colors.white),
              ))
        ],
      );

  /// 内容
  Widget get _mainContentWidget => Expanded(
        child: widget.type == messageTypeEnum['Text']
            ? Container(
                alignment: Alignment.topLeft,
                color: Colors.transparent,
                padding: EdgeInsets.all(25.w),
                child: Text(
                  widget.content,
                  style: TextStyle(fontSize: 24.sp),
                ))
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                      child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        color: Colors.transparent,
                      ),
                      ..._waveList,
                      GestureDetector(
                          onTap: () {
                            if (_mPlayer.isPlaying) {
                              _pauseSoundPlay();
                            } else {
                              _soundPlay();
                            }
                          },
                          child: CircleAvatar(
                            radius: 40.sp,
                            child: Icon(
                              _mPlayer.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 50.sp,
                            ),
                          ))
                    ],
                  )),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 20.h),
                      child: Slider(
                          value: min(sliderCurrentPosition, maxDuration),
                          min: 0.0,
                          max: maxDuration,
                          onChanged: (value) async {
                            await _seekToPlayer(value.toInt());
                          },
                          divisions:
                              maxDuration == 0.0 ? 1 : maxDuration.toInt())),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currentTimeStr,
                          style: TextStyle(fontSize: 30.sp),
                        ),
                        Text(
                          _endTimeStr,
                          style: TextStyle(fontSize: 30.sp),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      );

  /// 底部按钮
  Widget get _bottomButtonWidget =>
      _currentState == commandStateEnum['complete']
          ? Padding(padding: EdgeInsets.only(bottom: 20.h))
          : BaseButton(
              submit: _completeCommand,
              title: '完成',
              horizontalMargin: 120,
            );
}
