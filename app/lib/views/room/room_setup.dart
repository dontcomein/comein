import 'package:comein/components/platform_graphics.dart';
import 'package:comein/main.dart';
import 'package:comein/models/data_model.dart';
import 'package:comein/models/room_model.dart';
import 'package:comein/providers/bluetooth_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class RoomSetup extends StatefulWidget {
  const RoomSetup({super.key});

  @override
  State<RoomSetup> createState() => _RoomSetupState();
}

class _RoomSetupState extends State<RoomSetup> {
  final Room room = Room(name: "Unnamed Room");
  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text("Room Setup"),
        ),
        body: PlatformListView(
          children: [
            PlatformTextField(
              hintText: "Room Name",
              onChanged: (p0) => room.name = p0,
            ),
            BluetoothConnect(
              deviceName: deviceName,
            ),
            PlatformTextButton(
              onPressed: () =>
                  firebaseFirestore.collection("rooms").add(room.toJson()),
              child: const Text("Create Room"),
            ),
          ],
        ),
      );
}
