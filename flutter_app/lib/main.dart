import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/utils/global_context.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/routes/index.dart';
import 'package:flutter_app/shared/index.dart';
import 'package:flutter_app/components/notification_service.dart';
import 'package:flutter_app/provide/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  await SharedPreferencesUtil.init();
  runApp(
    MultiProvider(
      providers: ProvideGlobal().providers,
      child: MyApp(),
    ),
  );
}

/// 我的app
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(750, 1334),
        builder: (context, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            navigatorKey: myGlobals.scaffoldKey,
            theme: ThemeData(
              primaryColor: const Color.fromARGB(255, 41, 111, 225),
              colorScheme: const ColorScheme(
                brightness: Brightness.light,
                primary: Color.fromARGB(255, 41, 111, 225),
                onPrimary: Color.fromARGB(255, 121, 171, 250),
                secondary: Color.fromARGB(255, 19, 177, 224),
                onSecondary: Color(0xFFEAEAEA),
                error: Color(0xFFF32424),
                onError: Color(0xFFF32424),
                background: Color.fromARGB(255, 243, 246, 251),
                onBackground: Color(0xFFFFFFFF),
                surface: Color(0xFF54B435),
                onSurface: Color(0xFF54B435),
              ),
              scaffoldBackgroundColor: const Color.fromARGB(255, 243, 246, 251),
              bottomAppBarTheme: BottomAppBarTheme(color: Colors.white),
              hintColor: Color(0xffbbbbbb),
              disabledColor: Color(0xfff5f5f5),
              canvasColor: Colors.white,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              textSelectionTheme: const TextSelectionThemeData(
                  selectionColor: Color(0xff2294e2)),
              // textTheme: const TextTheme(
              //     subtitle1: TextStyle(textBaseline: TextBaseline.alphabetic)),
              primarySwatch: Colors.blue,
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: SlideTransitionBuilder(),
                  TargetPlatform.iOS: SlideTransitionBuilder(),
                },
              ),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: "/",
            onGenerateRoute: onGenerateRoute,
          );
        });
  }
}

/// 路由动画：滑动
class SlideTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    route,
    context,
    animation,
    secondaryAnimation,
    child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
      child: child,
    );
  }
}
