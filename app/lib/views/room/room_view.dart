import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comein/components/platform_graphics.dart';
import 'package:comein/components/state_description.dart';
import 'package:comein/components/user_bubble.dart';
import 'package:comein/models/room_model.dart';
import 'package:comein/models/room_state.dart';
import 'package:comein/views/room/room_config.dart';
import 'package:comein/views/room/statebuilder/room_state_builder.dart';
import 'package:confetti/confetti.dart';
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
  late ConfettiController _controllerCenter;
  late ConfettiController _controllerCenterRight;
  late ConfettiController _controllerCenterLeft;
  late ConfettiController _controllerTopCenter;
  late ConfettiController _controllerBottomCenter;

  @override
  void dispose() {
    _controllerCenter.dispose();
    _controllerCenterRight.dispose();
    _controllerCenterLeft.dispose();
    _controllerTopCenter.dispose();
    _controllerBottomCenter.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    roomStore = Room.fromJson(widget.room.toJson(), widget.room.uid);
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 1));
    _controllerCenterRight =
        ConfettiController(duration: const Duration(seconds: 1));
    _controllerCenterLeft =
        ConfettiController(duration: const Duration(seconds: 1));
    _controllerTopCenter =
        ConfettiController(duration: const Duration(seconds: 1));
    _controllerBottomCenter =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  bool confettiPlayed = false;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: widget.room.getRef().snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data?.data();
                if (data != null) {
                  widget.room.update(snapshot.data);
                }
              }
              if (widget.room.state?.isComeIn == true) {
                if (!confettiPlayed) {
                  confettiPlayed = true;
                  _controllerCenter.play();
                  _controllerCenterRight.play();
                  _controllerCenterLeft.play();
                  _controllerTopCenter.play();
                  _controllerBottomCenter.play();
                }
              }
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              return StreamBuilder<int>(
                stream: _periodicStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != _previousStreamValue) {
                    _previousStreamValue = snapshot.data;
                  }
                  return PlatformScaffold(
                    appBar: PlatformAppBar(
                      title: Text(widget.room.name),
                      trailingActions: [
                        PlatformIconButton(
                          onPressed: () => showPlatformDialog(
                            context: context,
                            builder: (_) => PlatformAlertDialog(
                              title: const Text("Reset State?"),
                              content: const Text(
                                "This will reset the room state",
                              ),
                              actions: [
                                PlatformDialogAction(
                                  child: const Text("Cancel"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                PlatformDialogAction(
                                  child: const Text("Reset"),
                                  onPressed: () {
                                    widget.room.setState(null);
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
                                i <
                                    10 *
                                        (widget.room.currentState
                                                ?.percentFinished() ??
                                            0);
                                i++)
                              Theme.of(context).canvasColor,
                            for (int i = 0;
                                i <
                                    10 -
                                        10 *
                                            (widget.room.currentState
                                                    ?.percentFinished() ??
                                                0);
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
                            PlatformTextButton(
                              onPressed: () => Navigator.of(context).push(
                                platformPageRoute(
                                  context: context,
                                  builder: (_) => RoomStateBuilder(
                                    widget.room,
                                    isComeIn: true,
                                  ),
                                ),
                              ),
                              child: const Text("Come In!"),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          ...confetti(),
        ],
      );

  List<Widget> ownershipWrapper() => widget.room.currentState == null ||
          manualOverride
      ? [
          FutureBuilder(
              future: widget.room.isConnected(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.data == false)
                  return const Center(child: Text("No Bluetooth Connection"));
                return PlatformPicker<RoomState>(
                  thumbColor: widget.room.getColor(),
                  children: {
                    for (final e in widget.room.states) e: Text(e.name)
                  },
                  onValueChanged: (e) => e?.now().let((that) => widget.room
                      .setState(that)
                      .whenComplete(
                          () => widget.room.notifyState(notifyFriends: 0))),
                  groupValue:
                      widget.room.isComeIn ? widget.room.currentState : null,
                );
              }),
        ]
      : [
          Column(
            children: [
              PlatformTextButton(
                onPressed: () => setState(() => manualOverride = true),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    widget.room.state?.setter
                            ?.let((user) => UserBubble(user)) ??
                        Icon(
                          PlatformIcons(context).accountCircle,
                          size: 50,
                        ),
                    Icon(PlatformIcons(context).padLock)
                  ],
                ),
              ),
              StateDescription(widget.room.currentState)
            ],
          )
        ];

  List<Widget> confetti() => [
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirectionality: BlastDirectionality
                .explosive, // don't specify a direction, blast randomly
            shouldLoop:
                false, // start again as soon as the animation is finished
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ], // manually specify the colors to be used
            createParticlePath: drawStar, // define a custom shape/path.
          ),
        ),

        //CENTER RIGHT -- Emit left
        Align(
          alignment: Alignment.centerRight,
          child: ConfettiWidget(
            confettiController: _controllerCenterRight,
            blastDirection: pi, // radial value - LEFT
            particleDrag: 0.05, // apply drag to the confetti
            emissionFrequency: 0.05, // how often it should emit
            numberOfParticles: 20, // number of particles to emit
            gravity: 0.05, // gravity - or fall speed
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink
            ], // manually specify the colors to be used
            strokeWidth: 1,
            strokeColor: Colors.white,
          ),
        ),

        //CENTER LEFT - Emit right
        Align(
          alignment: Alignment.centerLeft,
          child: ConfettiWidget(
            confettiController: _controllerCenterLeft,
            blastDirection: 0, // radial value - RIGHT
            emissionFrequency: 0.6,
            minimumSize: const Size(10,
                10), // set the minimum potential size for the confetti (width, height)
            maximumSize: const Size(50,
                50), // set the maximum potential size for the confetti (width, height)
            numberOfParticles: 1,
            gravity: 0.1,
          ),
        ),

        //TOP CENTER - shoot down
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controllerTopCenter,
            blastDirection: pi / 2,
            maxBlastForce: 5, // set a lower max blast force
            minBlastForce: 2, // set a lower min blast force
            emissionFrequency: 0.05,
            numberOfParticles: 50, // a lot of particles at once
            gravity: 1,
          ),
        ),

        //BOTTOM CENTER
        Align(
          alignment: Alignment.bottomCenter,
          child: ConfettiWidget(
            confettiController: _controllerBottomCenter,
            blastDirection: -pi / 2,
            emissionFrequency: 0.01,
            numberOfParticles: 20,
            maxBlastForce: 100,
            minBlastForce: 80,
            gravity: 0.3,
          ),
        ),
      ];

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
