import 'package:comein/components/platform_graphics.dart';
import 'package:comein/models/room_state.dart';
import 'package:comein/views/room/statebuilder/room_state_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class RoomStateTile extends StatefulWidget {
  const RoomStateTile(
    this.state, {
    super.key,
    this.isActive = false,
  });
  final RoomState state;
  final bool isActive;
  @override
  State<RoomStateTile> createState() => _RoomStateTileState();
}

class _RoomStateTileState extends State<RoomStateTile> {
  @override
  Widget build(BuildContext context) => PlatformListTile(
        leading: widget.isActive ? Icon(PlatformIcons(context).padLock) : null,
        title: Text(widget.state.name),
        backgroundColor: widget.state.color.withOpacity(0.5),
        trailing:
            widget.isActive ? null : Icon(PlatformIcons(context).rightChevron),
        onTap: () => widget.isActive
            ? showPlatformDialog(
                context: context,
                builder: (_) => PlatformAlertDialog(
                  title: const Text('Active State'),
                  content: const Text('This state cannot be edited right now'),
                  actions: [
                    PlatformDialogAction(
                      child: const Text('Okay'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              )
            : Navigator.of(context).push(
                platformPageRoute(
                  context: context,
                  builder: (_) => RoomStateView(widget.state),
                ),
              ),
      );
}
