import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class ChatMessageModel {
  ZegoUserInfo userInfo = ZegoUserInfo.empty();
  String message = "";

  ChatMessageModel(this.userInfo, this.message);
}

class ChatMessageItem extends StatelessWidget {
  const ChatMessageItem({Key? key, required this.message}) : super(key: key);
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Flexible(
        flex: 10,
        child: Container(
          padding:
              EdgeInsets.only(left: 21.w, top: 21.h, right: 21.w, bottom: 21.h),
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            color: StyleColors.roomChatBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(children: <TextSpan>[
                getRoleWidget(message.userInfo),
                getSpacerWidgetByRole(message.userInfo),
                TextSpan(
                    text: message.userInfo.userName + ": ",
                    style: StyleConstant.roomChatUserNameText),
                TextSpan(
                    text: message.message,
                    style: StyleConstant.roomChatMessageText),
              ])),
        ),
      ),
      const Expanded(flex: 1, child: Text('')),
    ]);
  }

  TextSpan getRoleWidget(ZegoUserInfo sender) {
    if (ZegoRoomUserRole.roomUserRoleHost == sender.userRole) {
      return const TextSpan(
          text: "Host", style: StyleConstant.roomChatHostRoleText);
    }
    return const TextSpan(text: '');
  }

  TextSpan getSpacerWidgetByRole(ZegoUserInfo sender) {
    if (ZegoRoomUserRole.roomUserRoleHost == sender.userRole) {
      return const TextSpan(text: " ");
    }
    return const TextSpan(text: '');
  }
}

class ChatMessagePage extends StatefulWidget {
  const ChatMessagePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatMessagePageState();
  }
}

class _ChatMessagePageState extends State<ChatMessagePage> {
  //  todo@yuyuj this is some test data
  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
        ZegoUserInfo('0001', 'Liam', ZegoRoomUserRole.roomUserRoleHost),
        "haha, i am host..."),
    ChatMessageModel(
        ZegoUserInfo('0002', 'Noah', ZegoRoomUserRole.roomUserRoleSpeaker),
        "haha, i am speaker 1..."),
    ChatMessageModel(
        ZegoUserInfo('0003', 'Oliver', ZegoRoomUserRole.roomUserRoleSpeaker),
        "haha, i am speaker 2..."),
    ChatMessageModel(
        ZegoUserInfo('0004', 'William', ZegoRoomUserRole.roomUserRoleListener),
        "Tis the season, and it’s time to decorate the Christmas Tree. We’ll need lights, ornaments, some tinsel, and a star for the top! Let’s go!"),
    ChatMessageModel(
        ZegoUserInfo('0005', 'Elijah', ZegoRoomUserRole.roomUserRoleListener),
        """There's a hero
        If you look inside your heart
        You don't have to be afraid of what you are
        There's an answer If you reach into your soul
        And the sorrow that you know will melt away"""),
    ChatMessageModel(
        ZegoUserInfo('0006', 'James', ZegoRoomUserRole.roomUserRoleListener),
        """And then a hero comes alone
With the strength to carry on
And you cast your fears aside
And you know you can survive
So when you feel like hope is gone
Look inside you and be strong
And you'll finally see the truth
That a hero lies in you"""),
    ChatMessageModel(
        ZegoUserInfo('0007', 'Benjamin', ZegoRoomUserRole.roomUserRoleListener),
        """It's a long road
When you face the world alone
No one reaches out a hand for you to hold
You can find love if you search within yourself
And the emptiness you felt will disappear"""),
    ChatMessageModel(
        ZegoUserInfo('0008', 'Lucas', ZegoRoomUserRole.roomUserRoleListener),
        """Lord knows dreams are hard to follow, But don't let anyone tear them away, Hold on, there will be tomorrow, In time, you'll find the way"""),
    ChatMessageModel(
        ZegoUserInfo('0009', 'Mason', ZegoRoomUserRole.roomUserRoleListener),
        """LOL"""),
    ChatMessageModel(
        ZegoUserInfo('0010', 'Ethan', ZegoRoomUserRole.roomUserRoleListener),
        """Let it be, let it be"""),
    ChatMessageModel(
        ZegoUserInfo(
            '0011', 'Alexander', ZegoRoomUserRole.roomUserRoleListener),
        """There is still a light that shines on me""")
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: (118 - 32).w),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _messages.length,
          itemBuilder: (_, index) {
            ChatMessageModel message = _messages[index];
            return ChatMessageItem(message: message);
          },
        ));
  }
}
