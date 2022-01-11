import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoomTitleBar extends StatelessWidget {
  const RoomTitleBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(36, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Room Name",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF1B1B1B),
                  fontSize: 32,
                ),
              ),
              Text(
                "ID:123456",
                style: TextStyle(
                  color: Color(0xFF606060),
                  fontSize: 20,
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          width: 68,
          height: 68,
          child: Icon(
            Icons.power_settings_new,
            color: Colors.grey,
            size: 32.0,
          ),
        ),
      ],
    );
  }
}
