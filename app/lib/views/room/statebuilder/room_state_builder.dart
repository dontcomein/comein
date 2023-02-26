import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comein/components/color_picker.dart';
import 'package:comein/components/platform_graphics.dart';
import 'package:comein/models/room_model.dart';
import 'package:comein/models/room_state.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class RoomStateBuilder extends StatefulWidget {
  const RoomStateBuilder(this.room, {super.key, this.isComeIn = false});
  final Room room;
  final bool isComeIn;
  @override
  State<RoomStateBuilder> createState() => _RoomStateBuilderState();
}

enum DurationMode { minutes, hours }

class _RoomStateBuilderState extends State<RoomStateBuilder> {
  final RoomState state = RoomState(
    name: "Unnamed State",
    color: Colors.blue,
    setAt: Timestamp.now(),
    duration: const Duration(minutes: 5),
    description: 'Description',
  );
  DurationMode mode = DurationMode.minutes;
  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text("Create State"),
        ),
        body: SafeArea(
          child: PlatformListView(
            children: [
              PlatformTextField(
                hintText: "State Name",
                onChanged: (value) => state.name = value,
              ),
              PlatformTextField(
                hintText: "Description",
                onChanged: (value) => state.description = value,
              ),
              ColorPicker(
                onColorChanged: (color) => state.color = color,
                initial: state.color,
              ),
              if (!widget.isComeIn)
                Center(
                  child: Text(
                    "Duration: ${mode == DurationMode.minutes ? state.duration?.inMinutes : state.duration?.inHours} ${mode == DurationMode.minutes ? "Minutes" : "Hours"}",
                  ),
                ),
              if (!widget.isComeIn)
                PlatformSlider(
                  value: (mode == DurationMode.minutes
                          ? state.duration?.inMinutes.toDouble()
                          : state.duration?.inHours.toDouble()) ??
                      0,
                  onChanged: (p0) => setState(() => state.duration =
                      mode == DurationMode.minutes
                          ? Duration(minutes: p0.toInt())
                          : Duration(hours: p0.toInt())),
                  min: 1,
                  max: mode == DurationMode.minutes ? 60 : 24,
                  divisions: mode == DurationMode.minutes ? 59 : 23,
                ),
              if (!widget.isComeIn)
                PlatformPicker(
                  children: {
                    for (final e in DurationMode.values)
                      e: Text(e.toString().substring(13))
                  },
                  onValueChanged: (value) {
                    mode = value ?? DurationMode.minutes;
                    state.duration = value == DurationMode.minutes
                        ? Duration(minutes: state.duration?.inHours ?? 0)
                        : Duration(
                            hours: state.duration?.inMinutes.clamp(0, 24) ?? 0);
                    setState(() {});
                  },
                  groupValue: mode,
                ),
              PlatformTextButton(
                onPressed: () async {
                  if (!widget.isComeIn) widget.room.states.add(state);
                  if (widget.isComeIn) {
                    state.duration = null;
                    state.isComeIn = widget.isComeIn;
                    widget.room.state = state;
                    widget.room.setState(state);
                  }
                  state.isComeIn = widget.isComeIn;
                  // widget.room.isComeIn = widget.isComeIn;
                  bool isConnected = await widget.room.isConnected();
                  widget.room.saveChanges().then((_) {
                    if (widget.isComeIn) {
                      widget.room.notifyState(notifyFriends: 1);
                    }
                    Navigator.pop(context);
                  });
                },
                child: const Text("Create State"),
              ),
            ],
          ),
        ),
      );
}
