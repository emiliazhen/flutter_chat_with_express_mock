import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart'
    as curSoundPlatFromInterface;
import 'package:audio_session/audio_session.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

import 'package:flutter_app/components/photo_view_simple.dart';
import 'package:flutter_app/utils/dialog.dart';
import 'package:flutter_app/components/index.dart';
import 'package:flutter_app/apis/index.dart';
import 'package:flutter_app/shared/index.dart';

/// 录制资源
const theSource = curSoundPlatFromInterface.AudioSource.microphone;

// 态势上报
class ReportSituationPage extends StatefulWidget {
  ReportSituationPage({Key? key}) : super(key: key);

  @override
  _ReportSituationPageState createState() => _ReportSituationPageState();
}

class _ReportSituationPageState extends State<ReportSituationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _imageFile;
  XFile? _videoFile;
  File? _audioFile;
  Map _form = {
    'level': 0,
    'imgUrl': '',
    'videoUrl': '',
    'audioUrl': '',
    'textContent': '',
  };
  List _tagTypeList = [];
  final ImagePicker _picker = ImagePicker();
  final FocusNode _focusNodeText = FocusNode();

  /// 是否在录音
  bool _isSoundNow = false;

  /// 录制编码
  Codec _codec = Codec.pcm16WAV;

  /// 录制地址
  String _tmpFilePath = '';
  String _mPath = 'tau_file.wav';

  /// 录音器
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();

  /// 音频录制是否初始化
  bool _mRecorderIsInitialized = false;

  /// 音频播放器
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();

  /// 音频播放器是否初始化
  bool _mPlayerIsInitialized = false;

  /// 音频播放器回放准备
  bool _mPlaybackReady = false;

  /// 音频录制开始时间
  late DateTime _audioStartTime;

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
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
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
  void _record() async {
    Directory tmpFileDirectory = await getTemporaryDirectory();
    File tmpFile = File('${tmpFileDirectory.path}/$_mPath');
    print('------🤣------${tmpFile.path}');
    if (!tmpFile.existsSync()) {
      tmpFile.createSync();
      print('--------------------------------------test.txt创建成功');
    }
    _tmpFilePath = tmpFile.path;
    _mRecorder!
        .startRecorder(
            toFile: _tmpFilePath,
            codec: _codec,
            bitRate: 8000,
            audioSource: theSource,
            numChannels: 1,
            sampleRate: 8000)
        .then((value) {
      setState(() {
        _audioStartTime = DateTime.now();
      });
    });
  }

  /// 停止录制
  void _stopRecorder() async {
    await _mRecorder!.stopRecorder();
    int finallySecond =
        (DateTime.now().difference(_audioStartTime).inMilliseconds / 1000)
            .ceil();

    try {
      setState(() {
        _form['audioUrl'] = _tmpFilePath;
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      _mPlaybackReady = true;
    });
  }

  /// 播放音频
  void _soundPlay() {
    assert(
        _mPlayerIsInitialized && _mRecorder!.isStopped && _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: _tmpFilePath,
            codec: kIsWeb ? Codec.opusWebM : Codec.pcm16WAV,
            whenFinished: () {
              print('💦----------------Finish');
            })
        .then((value) {
      print('☮----------------$value');
      setState(() {});
    });
  }

  /// 停止播放音频
  void _stopSoundPlay() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

  /// 清除临时音频文件
  void _clearTmpAudioFile() {
    Directory directory = Directory(_tmpFilePath);
    if (directory.existsSync()) {
      List<FileSystemEntity> files = directory.listSync();
      if (files.length > 0) {
        files.forEach((file) {
          file.deleteSync();
        });
      }
      directory.deleteSync();
    }
  }

  /// 选择图片
  void _pictureTap() async {
    _focusNodeText.unfocus();
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

  /// 图片选择
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

  /// 选择视频
  void _videoTap() async {
    _focusNodeText.unfocus();
    List<Widget> _children = [
      ListTile(
        title: Text(
          "${_form['videoUrl'] == '' ? '上传' : '重新上传'}-相机",
          textAlign: TextAlign.center,
        ),
        onTap: () async {
          Navigator.of(context).pop();
          _videoChange(ImageSource.camera);
        },
      ),
      ListTile(
        title: Text(
          "${_form['videoUrl'] == '' ? '上传' : '重新上传'}-相册",
          textAlign: TextAlign.center,
        ),
        onTap: () async {
          Navigator.of(context).pop();
          _videoChange(ImageSource.gallery);
        },
      )
    ];
    if (_form['videoUrl'] != '') {
      _children.add(ListTile(
        title: const Text(
          "删除",
          textAlign: TextAlign.center,
        ),
        onTap: () async {
          Navigator.of(context).pop();
          setState(() {
            _form['videoUrl'] = '';
            _videoFile = null;
          });
        },
      ));
    }
    UtilDialog.showBottomSheet(context, _children);
  }

  /// 视频选择
  void _videoChange(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(source: source);
      if (video != null) {
        setState(() {
          _form['videoUrl'] = video.path;
          _videoFile = video;
        });
      }
    } catch (e) {
      UtilDialog.showMessage(context, '视频获取失败...');
    }
  }

  /// 获取级别
  void _getMsgType() {
    apiGetMsgTagType(context).then((res) {
      if (res.data['code'] == 200) {
        setState(() {
          _tagTypeList = res.data['data'].map((e) {
            return {
              'KeyId': int.parse(e['dictValue']),
              'Value': e['dictLabel']
            };
          }).toList();
        });
      }
    });
  }

  /// 提交
  Future<void> _submit() async {
    _focusNodeText.unfocus();
    Map<String, dynamic> tmpMap = {
      'content': _form['textContent'],
      'maker': SharedPreferencesUtil.userInfo['userId'].toString(),
      'tag': _form['level'],
    };
    if (_imageFile != null) {
      tmpMap['pictureFile'] = await MultipartFile.fromFile(
        _imageFile!.path,
      );
    }
    if (_videoFile != null) {
      tmpMap['videoFile'] = await MultipartFile.fromFile(
        _videoFile!.path,
      );
    }
    if (_form['audioUrl'] != '') {
      tmpMap['audioFile'] = await MultipartFile.fromFile(
        _tmpFilePath,
        filename: _mPath,
      );
    }
    apiStateUpload(context, data: FormData.fromMap(tmpMap)).then((res) {
      if (res.data['code'] == 200 && mounted) {
        UtilDialog.showMessage(context, '提交成功！');
        _imageFile = null;
        _videoFile = null;
        setState(() {
          _form = {
            'level': 0,
            'imgUrl': '',
            'videoUrl': '',
            'audioUrl': '',
            'textContent': '',
          };
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      _getMsgType();
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
    _clearTmpAudioFile();
    _focusNodeText.dispose();
    _mPlayer!.closePlayer();
    _mPlayer = null;
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    _imageFile = null;
    _videoFile = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: setCustomAppBar(
          context,
          '现场情况上报',
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
                label: '级别',
                childVerticalPadding: 0,
                childHorizontalPadding: 10,
                hasChildBg: false,
                child: BaseFormRadio(
                  value: _form['level'],
                  items: List.from(_tagTypeList),
                  changed: (value) {
                    _focusNodeText.unfocus();
                    setState(() {
                      _form['level'] = value;
                    });
                  },
                ),
              ),
              BaseFormGroup(
                  label: '文字',
                  childVerticalPadding: 0,
                  child: BaseFormInput(
                    value: _form['textContent'],
                    hint: '请输入文字',
                    focusNode: _focusNodeText,
                    changed: (value) {
                      setState(() {
                        _form['textContent'] = value;
                      });
                    },
                    onChange: (value) {
                      setState(() {
                        _form['textContent'] = value;
                      });
                    },
                  )),
              BaseFormGroup(
                label: '图片',
                childVerticalPadding: 0,
                childHorizontalPadding: 0,
                child: GestureDetector(
                  onTap: _pictureTap,
                  child: Container(
                      height: 200.h,
                      alignment: Alignment.center,
                      decoration:
                          const BoxDecoration(color: Colors.transparent),
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
              BaseFormGroup(
                label: '语音',
                childVerticalPadding: 0,
                childHorizontalPadding: 0,
                child: GestureDetector(
                  onTap: () {
                    if (_form['audioUrl'] == '') {
                      return;
                    }
                    if (_mPlayer!.isPlaying) {
                      _stopSoundPlay();
                    } else {
                      _soundPlay();
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      _isSoundNow = true;
                    });
                    _record();
                  },
                  onLongPressEnd: (LongPressEndDetails detail) {
                    setState(() {
                      _isSoundNow = false;
                    });
                    _stopRecorder();
                  },
                  child: Container(
                    height: 100.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: _form['audioUrl'] == ''
                            ? Colors.transparent
                            : Colors.black),
                    child: _form['audioUrl'] == ''
                        ? Text(
                            _isSoundNow ? '正在说话.. 松开停止录音' : '长按开始录音',
                            style: TextStyle(
                                fontSize: 26.sp,
                                color: const Color(0xFFbabdbc)),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 10.w),
                                child: Icon(
                                  Icons.audio_file_outlined,
                                  size: 40.sp,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                  _isSoundNow ? '正在说话.. 松开停止录音' : '轻击播放，长按重新录音',
                                  style: TextStyle(
                                      fontSize: 26.sp,
                                      color: const Color(0xFFbabdbc)))
                            ],
                          ),
                  ),
                ),
              ),
              BaseFormGroup(
                label: '视频',
                childVerticalPadding: 0,
                childHorizontalPadding: 0,
                child: GestureDetector(
                  onTap: _videoTap,
                  child: Container(
                      height: 200.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: _form['videoUrl'] == ''
                              ? Colors.transparent
                              : Colors.black),
                      child: Icon(
                        _form['videoUrl'] == ''
                            ? Icons.video_call_outlined
                            : Icons.video_file_outlined,
                        size: 70.sp,
                        color: const Color(0xFFbabdbc),
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
