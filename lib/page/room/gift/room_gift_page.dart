import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:live_audio_room_flutter/model/zego_room_gift.dart';
import 'package:live_audio_room_flutter/page/room/gift/room_gift_selector.dart';
import 'package:live_audio_room_flutter/page/room/gift/room_gift_bottom_bar.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class RoomGiftPage extends HookWidget {
  const RoomGiftPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var selectedRoomGift = useState<ZegoRoomGift>(ZegoRoomGift(
        RoomGiftID.fingerHeart.value,
        AppLocalizations.of(context)!.roomPageGiftHeart,
        StyleIconUrls.roomGiftFingerHeart));

    return Container(
      decoration:
          const BoxDecoration(color: StyleColors.roomPopUpPageBackgroundColor),
      padding:
          EdgeInsets.only(left: 36.w, top: 20.h, right: 36.w, bottom: 22.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
              height: 72.h,
              width: double.infinity,
              child: Center(
                  child: Text(AppLocalizations.of(context)!.roomPageGift,
                      textAlign: TextAlign.center,
                      style: StyleConstant.roomBottomPopUpTitle))),
          RoomGiftSelector(selectedRoomGift: selectedRoomGift),
          RoomGiftBottomBar(selectedRoomGift: selectedRoomGift)
        ],
      ),
    );
  }
}
