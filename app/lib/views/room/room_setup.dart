import 'package:comein/components/platform_graphics.dart';
import 'package:comein/main.dart';
import 'package:comein/models/app_user.dart';
import 'package:comein/models/data_model.dart';
import 'package:comein/models/room_model.dart';
import 'package:comein/models/room_state.dart';
import 'package:comein/providers/bluetooth_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:uuid/uuid.dart';

class RoomSetup extends StatefulWidget {
  const RoomSetup({super.key});

  @override
  State<RoomSetup> createState() => _RoomSetupState();
}

class _RoomSetupState extends State<RoomSetup> {
  final Room room = Room(
    name: "Unnamed Room",
    number: 0,
    states: [RoomState.busy(), RoomState.quiet()],
    uid: const Uuid().v4(),
  );
  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text("Room Setup"),
        ),
        body: SafeArea(
          child: PlatformListView(
            children: [
              PlatformTextField(
                hintText: "Room Name",
                onChanged: (p0) => room.name = p0,
              ),
              PlatformTextField(
                hintText: "Room Number",
                keyboardType: TextInputType.number,
                onChanged: (p0) => room.number = int.tryParse(p0) ?? 0,
              ),
              BluetoothConnect(deviceName),
              PlatformTextButton(
                onPressed: () {
                  room.owner =
                      AppUser.fromFirebaseUser(firebaseAuth.currentUser);
                  firebaseFirestore
                      .collection("rooms")
                      .doc(room.uid)
                      .set(room.toJson())
                      .whenComplete(() => Navigator.of(context).pop());
                },
                child: const Text("Create Room"),
              ),
            ],
          ),
        ),
      );
}
