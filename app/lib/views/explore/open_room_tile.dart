import 'package:comein/components/platform_graphics.dart';
import 'package:comein/models/room_model.dart';
import 'package:flutter/material.dart';

class OpenRoomTile extends StatelessWidget {
  const OpenRoomTile(this.room, {super.key});
  final Room room;
  @override
  Widget build(BuildContext context) => PlatformListTile(
        title: Text(room.state?.name ?? "Mystery State"),
        trailing: Text(room.number.toString()),
        subtitle: Text(room.state?.description ?? "Mystery State"),
        backgroundColor: room.state?.color ?? Colors.grey,
      );
}
