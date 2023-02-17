import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart' as curSoundPlatFromInterface;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import 'package:flutter_application/provide/chat_sound.dart';
import 'package:flutter_application/utils/config.dart';
import 'package:flutter_application/utils/emoji.dart';
import 'package:flutter_application/provide/chat_message.dart';
import 'package:flutter_application/provide/chat_conversation.dart';
import 'package:flutter_application/provide/chat_websocket.dart';
import 'package:flutter_application/shared/index.dart';
import 'package:flutter_application/utils/formatter.dart';
import 'package:flutter_application/utils/dialog.dart';
import 'package:flutter_application/service/model/conversation.dart';
import 'package:flutter_application/service/model/chatMessage.dart';
import 'package:flutter_application/enum/index.dart';
import 'package:flutter_application/components/chat_message.dart';
import 'package:flutter_application/components/base_app_bar.dart';
import 'package:flutter_application/apis/index.dart';

/// 录制资源
const theSource = curSoundPlatFromInterface.AudioSource.microphone;

// 聊天详情页
class ChatDetailPage extends StatefulWidget {
  final ConversationModel conversation;
  const ChatDetailPage({Key? key, required this.conversation}) : super(key: key);
  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> with TickerProviderStateMixin {
  /// 输入框控制器
  final TextEditingController _textController = TextEditingController();

  /// 是否能发送
  bool _sendable = false;

  /// 动画控制器
  late AnimationController _expandAnimationController;

  /// 滑动控制器
  final ScrollController _scrollController = ScrollController();

  /// 当前会话ID
  int conversationId = -1;

  /// 是否加载更多
  bool _hasMore = false;

  /// 消息加载
  bool _isLoading = false;

  /// 扩展是否弹出
  bool _isShowExpand = false;

  /// 发送的文字内容
  String _sendContent = '';

  /// 输入框焦点
  final FocusNode focusNode = FocusNode();

  /// 展示表情或者扩展功能
  bool _showEmojiOrExpandItem = false;

  /// 输入框光标位置
  int _cursorStart = 0;

  /// 表情按钮是否展示键盘
  bool _showEmojiHideKeyBoard = true;

  /// 录音按钮是否展示键盘
  bool _showSoundHideKeyBoard = true;

  /// 是否在录音
  bool _isSoundNow = false;

  /// 录音按下时起点Y
  double _soundStartY = 0;

  /// 录制编码
  Codec _codec = Codec.aacMP4;

  /// 录制地址
  String _mPath = 'tau_file.mp4';

  /// 录音器
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();

  /// 音频录制是否初始化
  bool _mRecorderIsInitialized = false;

  /// 播放的消息id
  String _curPlayMessageId = '';

  /// 音频播放器
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();

  /// 音频播放器是否初始化
  bool _mPlayerIsInitialized = false;

  /// 音频播放器回放准备
  bool _mPlaybackReady = false;

  /// 音频录制开始时间
  late DateTime _audioStartTime;

  /// 用播放器查时长
  final durationPlayer = AudioPlayer();

  /// 监听输入框焦点变化
  void onFocusChange() {
    if (!mounted) return;
    if (focusNode.hasFocus) {
      _expandAnimationController.reverse();
      _showEmojiHideKeyBoard = true;
      _showSoundHideKeyBoard = true;
      setState(() {});
    }
  }

  /// 打开录音权限
  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInitialized = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth | AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInitialized = true;
  }

  /// 录制
  void _record() {
    _mRecorder!
        .startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: theSource,
    )
        .then((value) {
      setState(() {
        _audioStartTime = DateTime.now();
      });
    });
  }

  /// 停止录制
  void _stopRecorder() async {
    await _mRecorder!.stopRecorder().then((String? path) async {
      int finallySecond = (DateTime.now().difference(_audioStartTime).inMilliseconds / 1000).ceil();
      if (path != null) {
        try {
          MultipartFile file = await MultipartFile.fromFile(path, filename: _mPath, contentType: MediaType("video", _mPath.substring(_mPath.lastIndexOf('.'))));
          FormData formData = FormData.fromMap({'file': file});
          final res = await apiUploadFile(context, data: formData);
          if (res.data['code'] == 200 && mounted) {
            String audioUrl = res.data['msg'];
            ChatMessageModel message = ChatMessageModel.toOwnMessage(messageTypeEnum["Audio"], audioUrl, mediaDuration: finallySecond);
            Provider.of<WebSocketProvide>(context, listen: false).sendMessage(context, widget.conversation, message);
          }
        } catch (e) {
          print(e);
        }
      }
      setState(() {
        _mPlaybackReady = true;
      });
    });
  }

  // 播放音频
  void _soundPlay(String pathUrl) {
    print('_mPlayerIsInitialized----$_mPlayerIsInitialized');
    print('_mPlaybackReady----$_mPlaybackReady');
    print('_mRecorder----${_mRecorder!.isStopped}');
    print('_mPlayer----${_mPlayer!.isStopped}');
    assert(_mPlayerIsInitialized && _mRecorder!.isStopped && _mPlayer!.isStopped);
    // assert(_mPlayerIsInitialized && _mPlaybackReady && _mRecorder!.isStopped && _mPlayer!.isStopped);
    print('💥${Config.fileDomain}$pathUrl');
    _mPlayer!
        .startPlayer(
            fromURI: Config.fileDomain + pathUrl,
            codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              print('💦----------------Finish');
              setState(() {
                _curPlayMessageId = '';
              });
            })
        .then((value) {
      print('☮----------------$value');
      setState(() {});
    });
  }

  // 停止播放音频
  void _stopSoundPlay() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

  /// 初始化当前人聊天信息
  _initChatUser() async {
    ChatMessageProvide.curConversation = widget.conversation;
    conversationId = widget.conversation.conversationId;
    ConversationModel conversationModel = Provider.of<ConversationProvide>(context, listen: false).getConversationByUserId(widget.conversation.chatUserId);
    if (conversationModel.conversationId != -1) {
      conversationId = conversationModel.conversationId;
      widget.conversation.conversationId = conversationId;
    }
    await Provider.of<ConversationProvide>(context, listen: false).cleanMessageState(context, widget.conversation.chatUserId);
    Provider.of<ChatMessageProvide>(context, listen: false).getChatMessages(conversationId);
  }

  /// 加载更多的消息
  void _loadMoreMessage() {
    setState(() {
      _isLoading = true;
    });
    Provider.of<ChatMessageProvide>(context, listen: false).getChatMessages(conversationId);
  }

  /// 发送文字消息
  void _sendText(String text) {
    if (text.trim().isEmpty) {
      UtilDialog.showMessage(context, '不能发送空白消息');
      return;
    }
    setState(() {
      _sendContent = "";
      _sendable = false;
    });
    ChatMessageModel message = ChatMessageModel.toOwnMessage(messageTypeEnum["Text"], EmojiUtil.emojiCNToCode(text));
    Provider.of<WebSocketProvide>(context, listen: false)
        .sendMessage(
      context,
      widget.conversation,
      message,
    )
        .then((_) {
      _textController.clear();
    });
  }

  ///  隐藏键盘和扩展框
  void _hideKeyboard() {
    if (focusNode.hasFocus || _isShowExpand) {
      focusNode.unfocus();
      _expandAnimationController.reverse();
      setState(() {
        _showEmojiHideKeyBoard = true;
        _showSoundHideKeyBoard = true;
        _isShowExpand = false;
      });
    }
  }

  /// 选择表情
  void _emojiOnPress(String val) {
    // 点击了最后一页空白处
    if (val == 'blank') {
      return;
    }
    var startPos = _cursorStart;
    String beforeEmoji = _textController.text.substring(0, startPos);
    String afterEmoji = _textController.text.substring(startPos);
    RegExp reg = RegExp(r'(\[([\u4E00-\u9FA5]{1,3})\]){1}|(\[OK\]){1}');
    // 点击删除按钮执行的代码
    if (val == '') {
      Iterable<Match> matchEmojis = reg.allMatches(beforeEmoji);
      // 获取最后匹配的emoji的起始位置和截止位置
      var lastEmojiStart = 0;
      var lastEmojiEnd = 0;
      for (Match m in matchEmojis) {
        lastEmojiStart = m.start;
        lastEmojiEnd = m.end;
      }
      // 判断截止位置是否是字符串的结尾， 是，截取emoji之前的长度，不是则删除最后一个字符
      if (lastEmojiEnd == beforeEmoji.length && EmojiUtil.emojiCN[beforeEmoji.substring(lastEmojiStart, lastEmojiEnd)] != null) {
        beforeEmoji = beforeEmoji.substring(0, lastEmojiStart);
      } else {
        beforeEmoji = beforeEmoji.substring(0, beforeEmoji.length - 1);
      }
    }
    _textController.value = _textController.value.copyWith(
        text: beforeEmoji + val + afterEmoji,
        selection: TextSelection(baseOffset: beforeEmoji.length + val.length, extentOffset: beforeEmoji.length + val.length),
        composing: TextRange.empty);
    _cursorStart = _textController.value.selection.start;
    _sendable = true;
    _sendContent = _textController.value.text;
    setState(() {});
  }

  /// 选择图片
  void _selectImage() async {
    final List<AssetEntity>? imgList = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(textDelegate: AssetPickerTextDelegate()),
    );
    if (imgList != null) {
      UtilDialog.showLoading(context);
      bool uploadSuccess = true;
      for (int i = 0; i < imgList.length; i++) {
        File curFile;
        File? resFile = await imgList[i].file;
        if (resFile != null) {
          curFile = resFile;
          String path = curFile.path;
          String name = path.substring(path.lastIndexOf("/") + 1, path.length);
          String suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
          if (suffix != 'png' && suffix != 'jpg') {
            UtilDialog.showMessage(context, '请选择png，jpg格式的图片');
            return;
          }
          if (curFile.lengthSync() > 20 * 1024 * 1024) {
            UtilDialog.showMessage(context, '上传图片不能超过20M');
            return;
          }
          MultipartFile file = await MultipartFile.fromFile(path, filename: name, contentType: MediaType("image", suffix));
          FormData _formData = FormData.fromMap({'file': file});
          try {
            print(_formData);
            final res = await apiUploadFile(context, data: _formData);
            if (res.data['code'] == 200 && mounted) {
              String imageUrl = res.data['msg'];
              ChatMessageModel message = ChatMessageModel.toOwnMessage(messageTypeEnum["Image"], imageUrl);
              Provider.of<WebSocketProvide>(context, listen: false).sendMessage(context, widget.conversation, message);
            }
          } catch (e) {
            print(e);
            uploadSuccess = false;
          }
        }
      }
      if (uploadSuccess) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
        UtilDialog.showMessage(context, '系统繁忙，请稍后再试！');
      }
    }
  }

  /// 选择视频
  void _selectVideo() async {
    final List<AssetEntity>? videoList = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          textDelegate: AssetPickerTextDelegate(),
          requestType: RequestType.video,
          specialPickerType: SpecialPickerType.noPreview,
          filterOptions: FilterOptionGroup(containsLivePhotos: false)),
    );
    if (videoList != null) {
      File? curFile = await videoList[0].file;
      if (curFile != null) {
        if (curFile.lengthSync() > 20 * 1024 * 1024) {
          UtilDialog.showMessage(context, '上传视频不能超过20M');
          return;
        }
        String path = curFile.path;
        final duration = await durationPlayer.setUrl('file:$path');
        final int mediaDuration = duration == null ? 0 : (duration.inMilliseconds / 1000).ceil();
        String name = path.substring(path.lastIndexOf("/") + 1, path.length);
        String suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
        MultipartFile file = await MultipartFile.fromFile(path, filename: name, contentType: MediaType("video", suffix));
        FormData _formData = FormData.fromMap({'file': file});
        bool uploadSuccess = true;
        try {
          print(_formData);
          final res = await apiUploadFile(context, data: _formData);
          if (res.data['code'] == 200 && mounted) {
            String videoUrl = res.data['msg'];
            ChatMessageModel message = ChatMessageModel.toOwnMessage(messageTypeEnum["Video"], videoUrl, mediaDuration: mediaDuration);
            Provider.of<WebSocketProvide>(context, listen: false).sendMessage(context, widget.conversation, message);
          }
        } catch (e) {
          print(e);
          uploadSuccess = false;
        }
        if (!uploadSuccess) {
          UtilDialog.showMessage(context, '系统繁忙，请稍后再试！');
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    Future.delayed(Duration.zero, () {
      _initChatUser();
    });
    _expandAnimationController = AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    _scrollController.addListener(() {
      if (_scrollController.offset == _scrollController.position.maxScrollExtent && _hasMore) {
        _loadMoreMessage();
      }
    });
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInitialized = true;
      });
    });
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    focusNode.removeListener(onFocusChange);
    focusNode.dispose();
    _textController.dispose();
    _expandAnimationController.dispose();
    ChatMessageProvide.cleanChat();
    _mPlayer!.closePlayer();
    _mPlayer = null;
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: setCustomAppBar(
        context,
        widget.conversation.trueName,
      ),
      body: Container(
          child: Column(children: <Widget>[
        Expanded(child: _chatMessageViewArea),
        _chatBottomBar,
        _expandBox,
        Container(
          color: _isShowExpand ? Color(0xfff1f1f1) : Colors.white,
          height: MediaQuery.of(context).padding.bottom,
        )
      ])),
    );
  }

  /// 聊天信息展示区
  Widget get _chatMessageViewArea => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _hideKeyboard,
      onVerticalDragCancel: _hideKeyboard,
      child: Consumer<ChatMessageProvide>(
        builder: (_, chatMessage, child) {
          _isLoading = false;
          _hasMore = chatMessage.hasMore;
          List<Widget> messageViews = [];
          for (var i = 0; i < chatMessage.messages.length; i++) {
            ChatMessageModel curMessage = chatMessage.messages[i];
            bool isMe = curMessage.userId == SharedPreferencesUtil.userInfo['userId'].toString();
            ChatMessageWidget messageView = ChatMessageWidget(
              context,
              Key(curMessage.id.toString()),
              widget.conversation,
              curMessage,
              isMe,
              _curPlayMessageId,
              audioTap: () {
                if (curMessage.msgId == '') {
                  _soundPlay(curMessage.content);
                  setState(() {
                    _curPlayMessageId = curMessage.msgId;
                  });
                } else if (curMessage.msgId == _curPlayMessageId) {
                  _stopSoundPlay();
                } else {
                  _mPlayer!.stopPlayer().then((value) {
                    _soundPlay(curMessage.content);
                    setState(() {
                      _curPlayMessageId = curMessage.msgId;
                    });
                  });
                }
              },
            );
            messageViews.add(messageView);
            if (i + 1 != chatMessage.messages.length && curMessage.createTime - chatMessage.messages[i + 1].createTime >= 5 * 60 * 1000 || i + 1 == chatMessage.messages.length) {
              messageViews.add(_messageDateTime(curMessage.createTime));
            }
          }
          messageViews.add(Offstage(
            offstage: !_isLoading && !_hasMore,
            child: Center(
              child: SizedBox(
                width: 40.h,
                height: 40.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
              ),
            ),
          ));
          return Column(children: <Widget>[
            Flexible(
                child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 20.w),
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    reverse: true,
                    shrinkWrap: true,
                    children: messageViews))
          ]);
        },
      ));

  /// 对话栏显示日期时间
  Widget _messageDateTime(int time) => Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Text(
          FormatterUtil.filtersMsgTime(time),
          style: TextStyle(fontSize: 22.sp, color: Color(0xff999999)),
        ),
      );

  /// 底部栏
  Widget get _chatBottomBar => Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.w),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(width: 1.h, color: Colors.black12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _soundButton,
          Expanded(
            child: Container(margin: EdgeInsets.symmetric(horizontal: 8.w), child: _showSoundHideKeyBoard ? _chatTextField : _chatSoundPressButton),
          ),
          _emojiButton,
          _expandButton,
        ],
      ));

  /// 录音按钮
  Widget get _soundButton => GestureDetector(
      onTap: () {
        if (_showSoundHideKeyBoard) {
          setState(() {
            _showEmojiOrExpandItem = false;
            _showSoundHideKeyBoard = false;
            _showEmojiHideKeyBoard = true;
            // 记录光标位置
            _cursorStart = _textController.selection.start == -1 ? 0 : _textController.selection.start;
          });
          if (focusNode.hasFocus || _isShowExpand) {
            focusNode.unfocus();
            _expandAnimationController.reverse();
            setState(() {
              _isShowExpand = false;
            });
          }
        } else {
          setState(() {
            _isShowExpand = false;
            _showSoundHideKeyBoard = true;
          });
          _expandAnimationController.reverse().then((_) {
            FocusScope.of(context).requestFocus(focusNode);
          });
        }
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: _showSoundHideKeyBoard
              ? Image.asset(
                  'images/chat_sound.png',
                  width: 54.w,
                )
              : Image.asset(
                  'images/chat_keyboard.png',
                  width: 54.w,
                )));

  /// 按住说话按钮
  Widget get _chatSoundPressButton => Listener(
      onPointerDown: (PointerDownEvent event) {
        setState(() {
          _isSoundNow = true;
          _soundStartY = event.position.dy;
        });
        _record();
        UtilDialog.showCenter(context, [
          Material(
              child: Container(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Column(
              children: [
                Icon(
                  Icons.keyboard_voice,
                  color: Colors.green,
                  size: 70.sp,
                ),
                Container(
                    margin: EdgeInsets.only(top: 20.h),
                    child: Consumer<ChatSoundProvide>(builder: (_, chatSound, child) {
                      return Text(
                        chatSound.canCancel ? '松开手指可取消语音' : '上滑取消本次语音',
                        style: TextStyle(fontSize: 24.sp, color: Color(0xff666666)),
                      );
                    }))
              ],
            ),
          ))
        ]);
      },
      onPointerMove: (PointerMoveEvent event) {
        //手指移动的距离
        double diff = event.position.dy - _soundStartY;
        if (diff < -160.h) {
          Provider.of<ChatSoundProvide>(context, listen: false).setCanCancel(true);
        } else {
          Provider.of<ChatSoundProvide>(context, listen: false).setCanCancel(false);
        }
      },
      onPointerUp: (PointerUpEvent event) {
        Navigator.of(context).pop();
        double diff = event.position.dy - _soundStartY;
        setState(() {
          _isSoundNow = false;
        });
        Provider.of<ChatSoundProvide>(context, listen: false).setCanCancel(false);
        _stopRecorder();
        if (diff < -160.h) {
        } else {}
      },
      child: Container(
        padding: EdgeInsets.all(18.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(width: 1.w, color: Color(0xffFe5e5e5)), borderRadius: BorderRadius.all(Radius.circular(10.sp))),
        child: Text(
          _isSoundNow ? '正在说话..' : '按住 说话',
          style: TextStyle(fontSize: 36.sp),
        ),
      ));

  /// 聊天输入框
  Widget get _chatTextField => TextField(
        minLines: 1,
        maxLines: 5,
        focusNode: focusNode,
        controller: _textController,
        maxLength: 680,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        onChanged: (String text) {
          _sendContent = _textController.text;
          setState(() {
            _sendable = text.isNotEmpty;
          });
        },
        onSubmitted: _sendable ? _sendText : null,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.all(18.h),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.w,
              color: Color(0xffFe5e5e5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.w,
              color: Color(0xffFe5e5e5),
            ),
          ),
        ),
      );

  /// 表情按钮
  Widget get _emojiButton => GestureDetector(
      onTap: () {
        if (_showEmojiHideKeyBoard) {
          setState(() {
            _isShowExpand = true;
            _showEmojiOrExpandItem = true;
            _showEmojiHideKeyBoard = false;
            _showSoundHideKeyBoard = true;
            // 记录光标位置
            _cursorStart = _textController.selection.start == -1 ? 0 : _textController.selection.start;
          });
          focusNode.unfocus();
          _expandAnimationController.forward();
        } else {
          setState(() {
            _isShowExpand = false;
            _showEmojiHideKeyBoard = true;
          });
          _expandAnimationController.reverse().then((_) {
            FocusScope.of(context).requestFocus(focusNode);
          });
        }
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: _showEmojiHideKeyBoard
              ? Image.asset(
                  'images/chat_smile.png',
                  width: 54.w,
                )
              : Image.asset(
                  'images/chat_keyboard.png',
                  width: 54.w,
                )));

  /// 扩展按钮
  Widget get _expandButton => GestureDetector(
        onTap: () {
          if (_sendable) {
            setState(() {
              _cursorStart = 0;
            });
            _sendText(_sendContent);
          } else {
            setState(() {
              _isShowExpand = true;
              _showEmojiOrExpandItem = false;
              _showEmojiHideKeyBoard = true;
            });
            focusNode.unfocus();
            _expandAnimationController.forward();
          }
        },
        child: _sendable
            ? Container(
                height: 72.w,
                width: 120.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Color(0xff2294E2), borderRadius: BorderRadius.all(Radius.circular(10.sp))),
                child: Text(
                  '发送',
                  style: TextStyle(color: Colors.white, fontSize: 30.sp),
                ),
              )
            : Image.asset(
                'images/chat_add.png',
                width: 54.w,
              ),
      );

  /// 扩展面板
  Widget get _expandBox => SizeTransition(
        sizeFactor: CurvedAnimation(
          parent: _expandAnimationController,
          curve: Curves.easeOut,
        ),
        child: Container(
            height: 430.h,
            color: Color(0xffF1F1F1),
            child: _showEmojiOrExpandItem
                ? _expandEmojiItem()
                : GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: 20.h,
                      left: 15.w,
                      right: 15.w,
                    ),
                    crossAxisSpacing: 5.w,
                    crossAxisCount: 4,
                    mainAxisSpacing: 30.h,
                    children: <Widget>[
                        _expandItem('图片', Icons.image, _selectImage),
                        _expandItem('拍照', Icons.camera_alt_rounded, () => {}),
                        _expandItem('视频', Icons.video_file_rounded, _selectVideo),
                      ])),
      );

  // 扩展面板项
  Widget _expandItem(String title, IconData iconData, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          child: Column(
        children: [
          Icon(
            iconData,
            size: 80.sp,
            color: Color(0xff666666),
          ),
          Text(title)
        ],
      )),
    );
  }

  /// 扩展面板emoji
  Widget _expandEmojiItem() {
    final emojiList = EmojiUtil.emojiCN.keys.toList();
    return Container(
      // color: Colors.white,
      child: Swiper(
        autoplay: false,
        loop: false,
        pagination: SwiperPagination(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(bottom: 30.h),
          builder: DotSwiperPaginationBuilder(color: Color(0xffcccccc), activeColor: Color(0xff999999), activeSize: 20.w),
        ),
        itemCount: (emojiList.length / 23).ceil(),
        itemBuilder: (BuildContext context, int index) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8, crossAxisSpacing: 10.h, mainAxisSpacing: 20.h),
            physics: NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            itemCount: 24,
            itemBuilder: (BuildContext context, int i) {
              return GestureDetector(
                  onTap: () {
                    _emojiOnPress(
                      emojiList.length <= index * 23 + i && i != 23
                          ? 'blank'
                          : i == 23
                              ? ''
                              : emojiList[index * 23 + i],
                    );
                  },
                  child: emojiList.length <= index * 23 + i && i != 23
                      ? Container()
                      : Image.asset(
                          i == 23 ? 'emoji/emoji_delete.png' : 'emoji/${EmojiUtil.emojiData[EmojiUtil.emojiCN[emojiList[index * 23 + i]]]}.png',
                          width: 36.h,
                        ));
            },
          );
        },
      ),
    );
  }
}
