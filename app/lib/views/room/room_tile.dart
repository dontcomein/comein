import 'package:comein/components/platform_graphics.dart';
import 'package:comein/components/users_row.dart';
import 'package:comein/models/room_model.dart';
import 'package:comein/views/room/room_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class RoomTile extends StatelessWidget {
  const RoomTile({super.key, required this.room});
  final Room room;
  @override
  Widget build(BuildContext context) => PlatformListTile(
        leading: const Icon(Icons.room),
        title: Text(room.name),
        subtitle: UsersRow(users: room.roommates),
        onTap: () => Navigator.of(context).push(
          platformPageRoute(
            context: context,
            builder: (_) => RoomView(room),
          ),
        ),
        trailing: Icon(PlatformIcons(context).rightChevron),
      );
}
