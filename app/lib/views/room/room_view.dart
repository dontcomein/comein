import 'package:comein/components/platform_graphics.dart';
import 'package:comein/components/timer.dart';
import 'package:comein/components/user_bubble.dart';
import 'package:comein/main.dart';
import 'package:comein/models/room_model.dart';
import 'package:comein/models/room_state.dart';
import 'package:comein/views/room/room_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:comein/functions/extension_functions.dart';

class RoomView extends StatefulWidget {
  const RoomView(this.room, {super.key});
  final Room room;
  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  Room? roomStore;
  bool manualOverride = false;
  final _periodicStream =
      Stream.periodic(const Duration(milliseconds: 100), (i) => i);
  int? _previousStreamValue;

  @override
  void initState() {
    super.initState();
    roomStore = Room.fromJson(widget.room.toJson(), widget.room.uid);
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
      stream: _periodicStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != _previousStreamValue) {
          _previousStreamValue = snapshot.data;
        }
        return PlatformScaffold(
          appBar: PlatformAppBar(
            title: Text(widget.room.name),
            trailingActions: [
              if (roomStore != widget.room)
                PlatformIconButton(
                  onPressed: () => showPlatformDialog(
                    context: context,
                    builder: (_) => PlatformAlertDialog(
                      title: const Text("Reset State?"),
                      content: Text(
                        "This will reset the room state to ${roomStore?.state?.name}",
                      ),
                      actions: [
                        PlatformDialogAction(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        PlatformDialogAction(
                          child: const Text("Reset"),
                          onPressed: () {
                            setState(() => roomStore
                                ?.let((that) => widget.room.assign(that)));
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  icon: Icon(PlatformIcons(context).refresh),
                ),
              PlatformIconButton(
                icon: Icon(PlatformIcons(context).settings),
                onPressed: () => Navigator.of(context).push(
                  platformPageRoute(
                    context: context,
                    builder: (_) => RoomConfig(widget.room),
                  ),
                ),
              )
            ],
          ),
          body: AnimatedContainer(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  for (int i = 0;
                      i < 10 * (widget.room.state?.percentFinished() ?? 0);
                      i++)
                    Theme.of(context).canvasColor,
                  for (int i = 0;
                      i < 10 - 10 * (widget.room.state?.percentFinished() ?? 0);
                      i++)
                    widget.room.getColor(),
                ],
              ),
            ),
            curve: Curves.linear,
            duration: const Duration(milliseconds: 300),
            child: SafeArea(
              child: ListView(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: widget.room.roommates
                        .map((user) => UserBubble(user))
                        .toList(),
                  ),
                  ...ownershipWrapper(),
                  if (widget.room.state != null)
                    Timer(widget.room.state?.endTime)
                ],
              ),
            ),
          ),
        );
      });

  List<Widget> ownershipWrapper() => widget.room.state == null || manualOverride
      ? [
          PlatformTextField(
            textAlign: TextAlign.center,
            controller: TextEditingController(
              text: roomStore?.message,
            ),
            onChanged: (value) => roomStore?.message = value,
          ),
          PlatformPicker<RoomState>(
            thumbColor: widget.room.getColor(),
            children: {for (final e in widget.room.states) e: Text(e.name)},
            onValueChanged: (e) => setState(() => widget.room.state = e),
            groupValue: widget.room.state,
          ),
          if (roomStore != widget.room)
            PlatformElevatedButton(
              onPressed: () => showPlatformDialog(
                context: context,
                builder: (_) => PlatformAlertDialog(
                  title: const Text("Save State?"),
                  content: Text(
                      "This will change the room state to ${widget.room.state?.name}"),
                  actions: [
                    PlatformDialogAction(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    PlatformDialogAction(
                      child: const Text("Save"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              child: const Text("Save State"),
            ),
        ]
      : [
          Column(
            children: [
              PlatformTextButton(
                onPressed: () => setState(() => manualOverride = true),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    widget.room.lastSetter?.let((user) => UserBubble(user)) ??
                        Icon(
                          PlatformIcons(context).accountCircle,
                          size: 50,
                        ),
                    Icon(PlatformIcons(context).padLock)
                  ],
                ),
              ),
              Text(
                widget.room.lastSetter?.displayName ?? unknown,
                textAlign: TextAlign.center,
              ),
              Text(
                widget.room.state?.name ?? unknown,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          )
        ];
}
