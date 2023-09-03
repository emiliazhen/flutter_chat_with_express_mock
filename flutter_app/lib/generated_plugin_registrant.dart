//
// Generated file. Do not edit.
//

// ignore_for_file: directives_ordering
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: depend_on_referenced_packages

import 'package:audio_session/audio_session_web.dart';
import 'package:connectivity_plus_web/connectivity_plus_web.dart';
import 'package:device_info_plus_web/device_info_plus_web.dart';
import 'package:flutter_sound_web/flutter_sound_web.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:just_audio_web/just_audio_web.dart';
import 'package:pdfx/src/renderer/web/pdfx_plugin.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:video_player_web/video_player_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  AudioSessionWeb.registerWith(registrar);
  ConnectivityPlusPlugin.registerWith(registrar);
  DeviceInfoPlusPlugin.registerWith(registrar);
  FlutterSoundPlugin.registerWith(registrar);
  ImagePickerPlugin.registerWith(registrar);
  JustAudioPlugin.registerWith(registrar);
  PdfxPlugin.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  VideoPlayerPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
