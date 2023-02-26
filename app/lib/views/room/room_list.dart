import 'package:comein/components/platform_graphics.dart';
import 'package:comein/models/room_model.dart';
import 'package:comein/views/room/room_tile.dart';
import 'package:flutter/material.dart';

class RoomList extends StatefulWidget {
  const RoomList({
    super.key,
    required this.rooms,
  });
  final List<Room> rooms;

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          children: [
            PlatformListTileGroup(
              header: const Text("Personal"),
              children: widget.rooms.map((e) => RoomTile(room: e)).toList(),
            ),
          ],
        ),
      );
}
