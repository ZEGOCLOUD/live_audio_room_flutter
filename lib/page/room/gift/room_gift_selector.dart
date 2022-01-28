import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_room_gift.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class RoomGiftSelector extends HookWidget {
  RoomGiftSelector({Key? key, required this.selectedRoomGift})
      : super(key: key);

  ValueNotifier<ZegoRoomGift> selectedRoomGift;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 566.h,
      width: double.infinity,
      child: GridView.count(
        primary: false,
        physics: const ScrollPhysics(),
        padding: EdgeInsets.only(left: 0, top: 20.h, right: 0, bottom: 20.h),
        mainAxisSpacing: 0,
        crossAxisCount: 4,
        children: getGiftWidgets(context),
      ),
    );
  }

  List<Widget> getGiftWidgets(context) {
    List<ZegoRoomGift> gifts = [];
    gifts.add(ZegoRoomGift(
        RoomGiftID.fingerHeart.value,
        AppLocalizations.of(context)!.roomPageGiftHeart,
        StyleIconUrls.roomGiftFingerHeart));

    List<Widget> widgets = [];
    for (var gift in gifts) {
      widgets.add(IconButton(
        icon: Image.asset(gift.res),
        tooltip: gift.name,
        onPressed: () {
          selectedRoomGift.value = gift;
        },
      ));
    }
    return widgets;
  }
}
