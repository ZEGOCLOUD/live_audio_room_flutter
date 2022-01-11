import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SeatItem extends StatelessWidget {
  const SeatItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108 + 13 + 28,
      width: 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            backgroundImage: NetworkImage(
                "https://avatarfiles.alphacoders.com/182/182854.jpg"),
          ),
          Container(
            width: 94 / 2,
            height: 24 / 2,
            color: const Color(0xFF0000FF),
            child: const Text(
              "Owner",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10
              ),
            ),
          ),
          const Text(
            "User Name",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20 / 2
            ),
          )
        ],
      ),
    );
  }
}


class RoomCenterContentFrame extends StatelessWidget {
  const RoomCenterContentFrame({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 149 * 2,
            width: 108 * 3,
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.fromLTRB(0, 34, 0, 0),
              crossAxisSpacing: 20,
              mainAxisSpacing: 0,
              crossAxisCount: 4,
              children: const <Widget>[
                SeatItem(),
                SeatItem(),
                SeatItem(),
                SeatItem(),
                SeatItem(),
                SeatItem(),
                SeatItem(),
                SeatItem(),
              ],
            ),
          ),
          const Expanded(child: Text("Message"))
        ],
      ),
    );
  }
}