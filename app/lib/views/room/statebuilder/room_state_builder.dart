import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comein/components/color_picker.dart';
import 'package:comein/components/platform_graphics.dart';
import 'package:comein/models/room_model.dart';
import 'package:comein/models/room_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class RoomStateBuilder extends StatefulWidget {
  const RoomStateBuilder(this.room, {super.key});
  final Room room;
  @override
  State<RoomStateBuilder> createState() => _RoomStateBuilderState();
}

enum DurationMode { minutes, hours }

class _RoomStateBuilderState extends State<RoomStateBuilder> {
  final RoomState state = RoomState(
    name: "Unnamed State",
    color: Colors.blue,
    lastSet: Timestamp.now(),
    duration: const Duration(minutes: 5),
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
              ColorPicker(
                onColorChanged: (color) => state.color = color,
                initial: state.color,
              ),
              Center(
                child: Text(
                  "Duration: ${mode == DurationMode.minutes ? state.duration.inMinutes : state.duration.inHours} ${mode == DurationMode.minutes ? "Minutes" : "Hours"}",
                ),
              ),
              PlatformSlider(
                value: mode == DurationMode.minutes
                    ? state.duration.inMinutes.toDouble()
                    : state.duration.inHours.toDouble(),
                onChanged: (p0) => setState(() => state.duration =
                    mode == DurationMode.minutes
                        ? Duration(minutes: p0.toInt())
                        : Duration(hours: p0.toInt())),
                min: 1,
                max: mode == DurationMode.minutes ? 60 : 24,
                divisions: mode == DurationMode.minutes ? 59 : 23,
              ),
              PlatformPicker(
                children: {
                  for (final e in DurationMode.values)
                    e: Text(e.toString().substring(13))
                },
                onValueChanged: (value) {
                  mode = value ?? DurationMode.minutes;
                  state.duration = value == DurationMode.minutes
                      ? Duration(minutes: state.duration.inHours)
                      : Duration(hours: state.duration.inMinutes.clamp(0, 24));
                  setState(() {});
                },
                groupValue: mode,
              ),
              Row(
                children: [
                  const Text("Private State"),
                  PlatformIconButton(
                    icon: Icon(PlatformIcons(context).help),
                    onPressed: () => showPlatformDialog(
                      context: context,
                      builder: (_) => PlatformAlertDialog(
                        title: const Text("Private States"),
                        content: const Text(
                          "Private states are only visible to you and your roommates.",
                        ),
                        actions: [
                          PlatformDialogAction(
                            child: const Text("Okay"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  PlatformSwitch(
                    value: !state.isComeIn,
                    onChanged: (p0) => setState(() => state.isComeIn = !p0),
                  ),
                ],
              ),
              PlatformTextButton(
                onPressed: () {
                  widget.room.states.add(state);
                  Navigator.pop(context);
                  // widget.room.saveChanges();
                },
                child: const Text("Create State"),
              ),
            ],
          ),
        ),
      );
}
