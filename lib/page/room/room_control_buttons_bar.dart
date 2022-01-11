
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ControllerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;

  const ControllerButton(
      {Key? key, required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
      const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(onPressed: onPressed, icon: icon),
    );
  }
}

class RoomControlButtonsBar extends StatelessWidget {
  const RoomControlButtonsBar({Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ControllerButton(
            icon: const Icon(Icons.chat),
            onPressed: () {},
          ),
          Row(
            children: [
              ControllerButton(
                icon: const Icon(Icons.mic),
                onPressed: () {},
              ),
              ControllerButton(
                icon: const Icon(Icons.people_alt),
                onPressed: () {},
              ),
              ControllerButton(
                icon: const Icon(Icons.card_giftcard_outlined),
                onPressed: () {},
              ),
              ControllerButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
          )
        ],
      ),
    );
  }
}