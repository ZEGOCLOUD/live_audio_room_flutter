import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:live_audio_room_flutter/page/room/room_main_page.dart';
import 'package:live_audio_room_flutter/service/zego_gift_service.dart';
import 'package:live_audio_room_flutter/service/zego_message_service.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:live_audio_room_flutter/page/login/login_page.dart';
import 'package:live_audio_room_flutter/page/room/room_entrance_page.dart';
import 'package:live_audio_room_flutter/page/settings/settings_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

void main() {
  runApp(const ZegoApp());
  // /// Optimization when screen refresh rate and display rate are inconsistent
  // GestureBinding.instance?.resamplingEnabled = true;
  // runZonedGuarded(() {
  //   ErrorWidget.builder = (FlutterErrorDetails details) {
  //     Zone.current.handleUncaughtError(details.exception, details.stack!);
  //     print(details.toString());
  //
  //     /// TODO@yuyj show error page
  //     return Center(
  //       child: Text(
  //           details.exception.toString() + "\n " + details.stack.toString()),
  //     );
  //   };
  //   runApp(const ZegoApp());
  // }, (Object obj, StackTrace stack) {
  //   print(obj);
  //   print(stack);
  // });
}

class ZegoApp extends StatelessWidget {
  const ZegoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ZegoUserService()),
          ChangeNotifierProvider(create: (context) => ZegoRoomService()),
          ChangeNotifierProvider(create: (context) => ZegoGiftService()),
          ChangeNotifierProvider(create: (context) => ZegoMessageService()),
          ChangeNotifierProxyProvider2<ZegoRoomService, ZegoUserService, ZegoSpeakerSeatService>(
            create: (_) => ZegoSpeakerSeatService(),
            update: (_, room,users, seats) {
              if (seats == null) throw ArgumentError.notNull('seats');
              seats.updateHostID(room.roomInfo.hostID);
              seats.updateLocalUserID(users.localUserInfo.userId);
              return seats;
            },
          )
        ],
        child: ScreenUtilInit(
          designSize: const Size(750, 1334),
          minTextAdapt: true,
          builder: () => MaterialApp(
            title: "ZegoLiveAudio",
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English, no country code
              Locale('zh', ''),
            ],
            initialRoute: "/login",
            routes: {
              "/login": (context) => LoginPage(),
              "/settings": (context) => const SettingsPage(),
              "/room_entrance": (context) => RoomEntrancePage(),
              "/room_main": (context) => const RoomMainPage()
            },
          ),
        ));
  }
}
