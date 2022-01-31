import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:live_audio_room_flutter/service/zego_room_manager.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:live_audio_room_flutter/service/zego_loading_service.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

import 'package:live_audio_room_flutter/page/room/room_main_page.dart';
import 'package:live_audio_room_flutter/page/login/login_page.dart';
import 'package:live_audio_room_flutter/page/room/room_entrance_page.dart';
import 'package:live_audio_room_flutter/page/settings/settings_page.dart';

void main() {
  runApp(const ZegoApp());
}

class ZegoApp extends StatelessWidget {
  const ZegoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => ZegoRoomManager.shared.roomService),
          ChangeNotifierProvider(
              create: (context) => ZegoRoomManager.shared.speakerSeatService),
          ChangeNotifierProvider(
              create: (context) => ZegoRoomManager.shared.userService),
          ChangeNotifierProvider(
              create: (context) => ZegoRoomManager.shared.giftService),
          ChangeNotifierProvider(
              create: (context) => ZegoRoomManager.shared.messageService),
          ChangeNotifierProvider(
              create: (context) => ZegoRoomManager.shared.loadingService),
          ChangeNotifierProxyProvider<ZegoSpeakerSeatService, ZegoUserService>(
            create: (context) => context.read<ZegoUserService>(),
            update: (_, seats, users) {
              if (users == null) throw ArgumentError.notNull('users');
              users.updateSpeakerSet(seats.speakerIDSet);
              return users;
            },
          ),
          ChangeNotifierProxyProvider<ZegoUserService, ZegoSpeakerSeatService>(
            create: (context) => context.read<ZegoSpeakerSeatService>(),
            update: (_, users, seats) {
              if (seats == null) throw ArgumentError.notNull('seats');
              // Note: Update localUserID before update hostID cause we will call takeSeat() after hostID updated.
              seats.updateUserIDSet(
                  users.userList.map((user) => user.userID).toSet());
              return seats;
            },
          ),
        ],
        child: GestureDetector(
          onTap: () {
            //  for hide keyboard when click on empty place of all pages
            hideKeyboard(context);
          },
          child: MediaQuery(
              data: MediaQueryData.fromWindow(WidgetsBinding.instance!.window),
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
                    "/login": (context) => const LoginPage(),
                    "/settings": (context) => const SettingsPage(),
                    "/room_entrance": (context) => const RoomEntrancePage(),
                    "/room_main": (context) => roomMainLoadingPage(),
                  },
                ),
              )),
        ));
  }

  roomMainLoadingPage() {
    return Consumer<ZegoLoadingService>(
      builder: (context, loadingService, child) => LoaderOverlay(
        child: const RoomMainPage(),
        useDefaultLoading: false,
        overlayColor: Colors.grey,
        overlayOpacity: 0.8,
        overlayWidget: SizedBox(
          width: 750.w,
          height: 1334.h,
          child: Center(
            child: Column(
              children: [
                const Expanded(child: Text('')),
                const CupertinoActivityIndicator(
                  radius: 14,
                ),
                SizedBox(height: 5.h),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: Colors.grey,
                  ),
                  child: Text(loadingService.loadingText(),
                      style: StyleConstant.loadingText),
                ),
                const Expanded(child: Text(''))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}
