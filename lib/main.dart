import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:live_audio_room_flutter/service/zego_gift_service.dart';
import 'package:live_audio_room_flutter/service/zego_message_service.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';

import 'package:live_audio_room_flutter/page/room/room_main_page.dart';
import 'package:live_audio_room_flutter/page/login/login_page.dart';
import 'package:live_audio_room_flutter/page/room/room_entrance_page.dart';
import 'package:live_audio_room_flutter/page/settings/settings_page.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

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
          ChangeNotifierProvider(create: (context) => ZegoRoomService()),
          ChangeNotifierProvider(create: (context) => ZegoSpeakerSeatService()),
          ChangeNotifierProvider(create: (context) => ZegoUserService()),
          ChangeNotifierProvider(create: (context) => ZegoGiftService()),
          ChangeNotifierProvider(create: (context) => ZegoMessageService()),
          ChangeNotifierProxyProvider2<ZegoRoomService, ZegoSpeakerSeatService,
              ZegoUserService>(
            create: (context) => context.read<ZegoUserService>(),
            update: (_, room, seats, users) {
              if (users == null) throw ArgumentError.notNull('users');
              users.updateUserRole(room.roomInfo.hostID, seats.speakerIDList);
              return users;
            },
          ),
          ChangeNotifierProxyProvider<ZegoUserService, ZegoRoomService>(
              create: (context) => context.read<ZegoRoomService>(),
              update: (_, users, room) {
                if (room == null) throw ArgumentError.notNull('room');
                room.localUserID = users.localUserInfo.userID;
                room.localUserName = users.localUserInfo.userName;
                return room;
              }),
          ChangeNotifierProxyProvider2<ZegoRoomService, ZegoUserService, ZegoMessageService>(
              create: (context) => context.read<ZegoMessageService>(),
              update: (_, roomService, userService, message) {
                //  sync member online/offline message
                if (message == null) throw ArgumentError.notNull('message');

                message.onRoomMemberJoined(userService.addedUserInfo);
                message.onRoomMemberLeave(userService.leaveUserInfo);

                //  clear data
                if(roomService.roomInfo.roomID.isEmpty) {
                  message.onRoomLeave();
                }

                return message;
              }),
          ChangeNotifierProxyProvider<ZegoRoomService, ZegoGiftService>(
              create: (context) => context.read<ZegoGiftService>(),
              update: (_, roomService, giftService) {
                if (giftService == null) throw ArgumentError.notNull('gift');

                //  clear data
                if(roomService.roomInfo.roomID.isEmpty) {
                  giftService.onRoomLeave();
                }

                return giftService;
              }),
          ChangeNotifierProxyProvider2<ZegoRoomService, ZegoUserService,
              ZegoSpeakerSeatService>(
            create: (context) => context.read<ZegoSpeakerSeatService>(),
            update: (_, room, users, seats) {
              if (seats == null) throw ArgumentError.notNull('seats');
              // Note: Update localUserID before update hostID cause we will call takeSeat() after hostID updated.
              seats.updateLocalUserID(users.localUserInfo.userID);
              seats.updateRoomInfo(room.roomInfo.roomID, room.roomInfo.hostID,
                  room.roomInfo.isSeatClosed);
              return seats;
            },
          ),
        ],
        child: GestureDetector(
            onTap: () {
              //  for hide keyboard when click on empty place of all pages
              hideKeyboard(context);
            },
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
            )));
  }

  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}
