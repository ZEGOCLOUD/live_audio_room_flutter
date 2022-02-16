import 'package:flutter/material.dart';

/// colors
class StyleColors {
  static const Color dark = Color(0xff1B1B1B);
  static const Color red = Color(0xffEE1515);
  static const Color gray = Color(0xff989BA8);
  static const Color blue = Color(0xff0055FF);

  static const Color switchActiveColor = Colors.white;
  static const Color switchActiveTrackColor = blue;
  static const Color switchInactiveTrackColor = Color(0xff787880);

  static const Color settingsVersion = gray;
  static const Color settingsBackgroundColor = Color(0xffF4F5F6);
  static const Color settingsTitleBackgroundColor = Colors.white;
  static const Color settingsCellBackgroundColor = Colors.white;

  static const Color loginTextInputColor = dark;
  static const Color loginTextInputHintColor = gray;
  static const Color loginTextBorderColor = Color(0xffF0F0F0);

  static const Color blueButtonEnabledColor = blue;
  static Color blueButtonDisableColor = blue.withOpacity(0.3);

  static const Color roomPopUpPageBackgroundColor = Colors.white;
  static const Color giftMemberListBackgroundColor = Color(0xffF7F7F8);

  static const Color roomChatBackgroundColor = Color(0xffe6eaed);
  static const Color roomChatHostRoleBackgroundColor = Color(0xffF7d046);
  static const Color roomChatUserNameColor = blue;
  static const Color roomChatMessageColor = dark;

  static const Color roomMessageSendButtonBgColor = blue;
  static Color roomMessageSendButtonBgDisableColor = blue.withOpacity(0.3);
  static Color roomMessageSendButtonDisableBgColor =
      roomMessageSendButtonBgColor.withOpacity(0.3);
  static const Color roomMessageInputBgColor = Color(0xffF7F7F8);

  static const Color giftMessageTypeTextColor = Color(0xffFFCE00);
  static const Color giftMessageContentColor = Colors.white;
  static Color giftMessageBackgroundStartColor =
      const Color(0xffA500FF).withOpacity(0.8);
  static Color giftMessageBackgroundEndColor =
      const Color(0xff6C00FF).withOpacity(0.8);
}

/// icons
class StyleIconUrls {
  static const String navigatorBack = 'images/navigator_back.png';
  static const String roomBottomGift = 'images/room_bottom_gift.png';
  static const String roomBottomIm = 'images/room_bottom_im.png';
  static const String roomBottomImDisable = 'images/room_bottom_im_disable.png';
  static const String roomBottomMember = 'images/room_bottom_member.png';
  static const String roomBottomMicrophone =
      'images/room_bottom_microphone.png';
  static const String roomBottomMicrophoneMuted =
      'images/room_bottom_microphone_muted.png';
  static const String roomSeatMicrophoneMuted =
      'images/room_seat_microphone_muted.png';
  static const String roomBottomSettings = 'images/room_bottom_settings.png';
  static const String roomBottomMore = 'images/room_bottom_more.png';
  static const String roomGiftFingerHeart = 'images/room_gift_finger_heart.png';
  static const String roomMemberDropDownArrow =
      'images/room_member_drop_down_arrow.png';
  static const String roomSeatDefault = 'images/room_seats_default.png';
  static const String roomSeatAdd = 'images/room_seats_add.png';
  static const String roomSeatLock = 'images/room_seats_lock.png';
  static const String roomSeatsHost = 'images/room_seats_host.png';
  static const String roomTopQuit = 'images/room_top_quit.png';
  static const String roomSoundWave = 'images/room_sound_wave.png';
  static const String roomNetworkStatusBad =
      'images/room_network_status_bad.png';
  static const String roomNetworkStatusGood =
      'images/room_network_status_good.png';
  static const String roomNetworkStatusNormal =
      'images/room_network_status_normal.png';
  static const String roomMemberMore = 'images/room_member_more.png';
}

/// constant style
class StyleConstant {
  static const appBarTitleSize = 17.0;
  static const settingsFontSize = 14.0;
  static const roomBottomPopupTitleSize = 17.0;
  static const roomSettingsSwitchFontSize = 14.0;
  static const loginTitleFontSize = 30.0;
  static const longTextInputFontSize = 14.0;

  static const settingAppBar = TextStyle(
    color: Colors.black,
    fontSize: appBarTitleSize,
  );
  static const settingTitle = TextStyle(
    color: StyleColors.dark,
    fontSize: settingsFontSize,
  );
  static const settingVersion = TextStyle(
    color: StyleColors.settingsVersion,
    fontSize: settingsFontSize,
  );
  static const settingLogout = TextStyle(
    color: StyleColors.red,
    fontSize: settingsFontSize,
  );

  static const loginTitle = TextStyle(
    color: Colors.black,
    fontSize: loginTitleFontSize,
  );
  static const loginTextInput = TextStyle(
    color: StyleColors.loginTextInputColor,
    fontSize: longTextInputFontSize,
  );
  static const loginTextInputHintStyle = TextStyle(
    color: StyleColors.loginTextInputHintColor,
    fontSize: longTextInputFontSize,
  );

  static const roomBottomPopUpTitle = TextStyle(
    color: StyleColors.dark,
    fontSize: roomBottomPopupTitleSize,
  );
  static const roomSettingSwitchText = TextStyle(
    color: StyleColors.dark,
    fontSize: roomSettingsSwitchFontSize,
  );

  static const roomGiftSendButtonText = TextStyle(
    color: Colors.white,
    fontSize: 13.0,
  );
  static const roomGiftInputText = TextStyle(
    color: StyleColors.dark,
    fontSize: 13.0,
  );
  static const roomGiftMemberListText = TextStyle(
      color: StyleColors.dark, fontSize: 13.0, decoration: TextDecoration.none);

  static const roomMemberListNameText = TextStyle(
    color: StyleColors.dark,
    fontSize: 14.0,
  );
  static const roomMemberListRoleText = TextStyle(
    color: StyleColors.gray,
    fontSize: 12.0,
  );

  static const roomChatHostRoleText = TextStyle(
    color: Colors.white,
    backgroundColor: StyleColors.roomChatHostRoleBackgroundColor,
    fontSize: 11.0,
  );
  static const roomChatUserNameText = TextStyle(
    color: StyleColors.roomChatUserNameColor,
    fontWeight: FontWeight.bold,
    fontSize: 12.0,
  );
  static const roomChatMessageText = TextStyle(
    color: StyleColors.roomChatMessageColor,
    fontSize: 12.0,
  );

  static const roomMessageInputText = TextStyle(
    color: StyleColors.dark,
    fontSize: 13.0,
  );
  static const roomMessageSendButtonText = TextStyle(
    color: Colors.white,
    fontSize: 13.0,
  );

  static const giftMessageContentText = TextStyle(
    color: StyleColors.giftMessageContentColor,
    fontSize: 12.0,
  );
  static const giftMessageTypeText = TextStyle(
    color: StyleColors.giftMessageTypeTextColor,
    fontSize: 12.0,
  );

  static const loadingText = TextStyle(
      color: Colors.white, fontSize: 10.0, decoration: TextDecoration.none);
}
