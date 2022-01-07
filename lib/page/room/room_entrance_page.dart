import 'package:flutter/material.dart';
import 'package:live_audio_room_flutter/service/zego_user_service.dart';
import 'package:provider/provider.dart';

class RoomEntrancePage extends StatelessWidget {
  const RoomEntrancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<ZegoUserService>(
            builder: (context, user, child) =>
                Text('Welcome ${user.localUserInfo.userName}', style: Theme.of(context).textTheme.bodyText1)),
      ),
    );
  }
}
