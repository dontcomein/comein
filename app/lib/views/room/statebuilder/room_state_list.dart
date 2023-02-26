import 'package:comein/components/platform_graphics.dart';
import 'package:comein/models/room_model.dart';
import 'package:comein/views/room/statebuilder/room_state_builder.dart';
import 'package:comein/views/room/statebuilder/room_state_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class RoomStateList extends StatefulWidget {
  const RoomStateList(this.room, {super.key});
  final Room room;
  @override
  State<RoomStateList> createState() => _RoomStateListState();
}

class _RoomStateListState extends State<RoomStateList> {
  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('States'),
          trailingActions: [
            PlatformIconButton(
              onPressed: () => showPlatformModal(
                context: context,
                builder: (_) => RoomStateBuilder(widget.room),
              ).then((_) => setState(() {})),
              icon: Icon(PlatformIcons(context).add),
            ),
          ],
        ),
        body: SafeArea(
          child: PlatformListView(
            children: widget.room.states
                .map((e) => RoomStateTile(e, isActive: e == widget.room.state))
                .toList(),
          ),
        ),
      );
}
