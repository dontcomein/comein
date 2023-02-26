import 'package:comein/models/room_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class OpenRoomTile extends StatelessWidget {
  const OpenRoomTile(this.room, {super.key});
  final Room room;
  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(room.name),
      );
}
