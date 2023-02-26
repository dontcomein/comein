import 'package:comein/components/platform_graphics.dart';
import 'package:comein/models/room_model.dart';
import 'package:comein/views/room/room_share.dart';
import 'package:comein/views/room/statebuilder/room_state_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class RoomConfig extends StatefulWidget {
  const RoomConfig(this.room, {super.key});
  final Room room;

  @override
  State<RoomConfig> createState() => _RoomConfigState();
}

class _RoomConfigState extends State<RoomConfig> {
  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text("Settings"),
        ),
        body: SafeArea(
          child: PlatformListView(
            children: [
              PlatformListTileGroup(
                header: const Text("Configure"),
                children: [
                  PlatformTextFormField(
                    hintText: "Room Name",
                    initialValue: widget.room.name,
                  ),
                  PlatformListTile(
                    title: const Text("Edit Roommates"),
                    onTap: () => showPlatformModal(
                      context: context,
                      builder: (_) => RoomShare(widget.room),
                    ),
                  ),
                  PlatformListTile(
                    title: const Text("Edit States"),
                    onTap: () => showPlatformModal(
                      context: context,
                      builder: (_) => RoomStateList(widget.room),
                    ),
                  ),
                ],
              ),
              PlatformTextButton(
                onPressed: widget.room.saveChanges,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      );
}
