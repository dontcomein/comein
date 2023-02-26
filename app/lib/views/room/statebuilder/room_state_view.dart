import 'dart:math';

import 'package:comein/components/platform_graphics.dart';
import 'package:comein/models/room_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class RoomStateView extends StatefulWidget {
  const RoomStateView(this.state, {super.key});
  final RoomState state;
  @override
  State<RoomStateView> createState() => _RoomStateViewState();
}

class _RoomStateViewState extends State<RoomStateView> {
  final _periodicStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
  int? _previousStreamValue;
  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
        stream: _periodicStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != _previousStreamValue) {
            _previousStreamValue = snapshot.data;
          }
          return PlatformScaffold(
            appBar: PlatformAppBar(
              title: const Text("Room State"),
            ),
            body: SafeArea(
              child: AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.linear,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).canvasColor,
                      Theme.of(context).canvasColor,
                      Theme.of(context).canvasColor,
                      Theme.of(context).canvasColor,
                      widget.state.color,
                      for (int i = 0;
                          i < sin(_previousStreamValue ?? pi / 2);
                          i++)
                        widget.state.color,
                    ],
                  ),
                ),
                child: PlatformListView(
                  children: [
                    PlatformTextField(
                      hintText: "State Name",
                      controller:
                          TextEditingController(text: widget.state.name),
                      onChanged: (value) => widget.state.name = value,
                    ),
                    PlatformTextButton(
                      onPressed: () {},
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
