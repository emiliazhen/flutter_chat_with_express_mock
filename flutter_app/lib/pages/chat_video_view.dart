import 'dart:io';
import 'package:flutter_app/utils/config.dart';
import 'package:video_player/video_player.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/components/base_loading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';

class ChatVideoViewPage extends StatefulWidget {
  const ChatVideoViewPage(
      {Key? key, required this.videoUrl, required this.videoDuration})
      : super(key: key);

  final String videoUrl;
  final int videoDuration;

  @override
  _ChatVideoViewPageState createState() => _ChatVideoViewPageState();
}

class _ChatVideoViewPageState extends State<ChatVideoViewPage> {
  late VideoPlayerController _controller;

  /// 展示播放界面控制组件
  bool _showControlBtns = false;

  /// 当前播放时长
  int _position = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network('${Config.fileDomain}${widget.videoUrl}')
          ..initialize().then((_) {
            _controller.addListener(listenPosition);
          })
          ..play();
  }

  /// 监听当前播放时长
  listenPosition() async {
    Duration? duration = await _controller.position;
    if (mounted && duration != null) {
      if (duration.inSeconds >= widget.videoDuration) {
        _position = widget.videoDuration * 1000;
      } else {
        _position = duration.inMilliseconds;
      }
      setState(() {});
    }
  }

  _closeVideo() {
    Navigator.of(context).pop();
  }

  _controlPlay() async {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      if (Duration(milliseconds: _position).inSeconds >= widget.videoDuration) {
        setState(() {
          _position = 0;
        });
        await _controller.seekTo(Duration.zero);
      }
      _controller.play();
    }
  }

  durationFormat(int duration) {
    String durationStr = '';
    List timeList = Duration(seconds: duration).toString().split(':');
    durationStr = timeList[1] + ':' + timeList[2].split('.')[0];

    return durationStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showControlBtns = !_showControlBtns;
            });
          },
          child: Container(
            color: Colors.black,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Center(
                  child: Container(
                    child: _controller == null
                        ? Container(
                            child: BaseLoading(),
                          )
                        : _controller.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              )
                            : Container(
                                child: BaseLoading(),
                              ),
                  ),
                ),
                Offstage(
                  offstage:
                      _controller == null ? true : _controller.value.isPlaying,
                  child: GestureDetector(
                    onTap: _controlPlay,
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 120.w,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 40.w,
                  left: 20.w,
                  child: Offstage(
                    offstage: !_showControlBtns,
                    child: GestureDetector(
                      onTap: _closeVideo,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xff666666),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.w))),
                        width: 60.w,
                        height: 60.w,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80.w,
                  left: 20.w,
                  right: 20.w,
                  child: Offstage(
                    offstage: !_showControlBtns,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      height: 80.h,
                      decoration: BoxDecoration(
                          color: Color(0xff666666),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.w))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: _controlPlay,
                            child: Icon(
                              _controller == null
                                  ? null
                                  : _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                              color: Colors.white,
                              size: 58.w,
                            ),
                          ),
                          Text(
                            durationFormat(
                                Duration(milliseconds: _position).inSeconds),
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: 6.h,
                            width: 300.w,
                            child: LinearProgressIndicator(
                              value: _position /
                                  (widget.videoDuration * 1000).toDouble(),
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              backgroundColor: Color(0xff999999),
                            ),
                          ),
                          Text(
                            durationFormat(widget.videoDuration),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(listenPosition);
    _controller.dispose();
  }
}
