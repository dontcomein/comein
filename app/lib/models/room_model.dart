import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:comein/main.dart';
import 'package:comein/models/data_model.dart';
import 'package:comein/models/room_state.dart';
import 'package:comein/functions/extension_functions.dart';
import 'package:comein/models/app_user.dart';
import 'package:comein/providers/bluetooth_connect.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Room {
  String name;
  RoomState? state;
  List<RoomState> states;
  RoomState? get currentState => (state?.expired() ?? false) ? null : state;
  List<AppUser> roommates = [];
  GeoPoint? location;
  int number;
  AppUser? owner;
  String uid;
  bool isComeIn = false;

  Room({
    required this.name,
    required this.number,
    this.location,
    this.state,
    this.owner,
    this.states = const [],
    this.roommates = const [],
    required this.uid,
    this.isComeIn = false,
  });

  bool equals(Room other) =>
      uid == other.uid &&
      state == other.state &&
      name == other.name &&
      location == other.location;

  bool operator ==(other) => other is Room ? equals(other) : false;

  Room assign(Room other) {
    uid = other.uid;
    name = other.name;
    state = other.state;
    location = other.location;
    return this;
  }

  Future<HttpsCallableResult> shareRoom(
          {required String email, required Role role}) =>
      firebaseFunctions.httpsCallable('shareRoom').call({
        'room': toJson(),
        'uid': uid,
        'email': email,
        'role': role.toString(),
      });

  Future<HttpsCallableResult> notifyState({required int notifyFriends}) =>
      firebaseFunctions.httpsCallable('notifyState').call({
        'stateName': state?.name,
        'roomUid': uid,
        'roomName': name,
        'notifyFriends': notifyFriends,
      });

  Color getColor() {
    return currentState?.color ?? Colors.transparent;
  }

  Future<void> setState(RoomState? state) async {
    await bluetoothController
        .sendTextFieldValue(state?.broadcast() ?? "0,0,0,0");
    isComeIn = state?.isComeIn ?? false;
    // print(state.broadcast());
    return getRef().update({
      'state': state?.toJson(),
      'isComeIn': state?.isComeIn ?? false,
    });
  }

  Future<void> saveChanges() {
    return firebaseFirestore.collection('rooms').doc(uid).update(toJson());
  }

  Future<bool> isConnected() async {
    for (final connected in await flutterBlue.connectedDevices) {
      if (connected.name == deviceName) return true;
    }
    return false;
  }

  DocumentReference getRef() => firebaseFirestore.collection('rooms').doc(uid);

  Map<String, dynamic> toJson() => {
        'name': name,
        'number': number,
        'roommates': {
          for (final roommate in roommates) roommate.uid: roommate.toJson(),
        },
        'state': state?.toJson(),
        // 'location': location?.toJson(),
        'states': states.map((e) => e.toJson()).toList(),
        'owner': owner?.toJson(),
        'isComeIn': isComeIn,
      };

  void update(DocumentSnapshot? snapshot) {
    if (snapshot == null) return;
    final map = snapshot.data() as Map<String, dynamic>?;
    if (map == null) return;
    name = map['name'];
    // location = geoFromJson(map['location']);
    number = map['number'];
    state = (map['state'] as Map<String, dynamic>?)
        ?.let((that) => RoomState.fromJson(that));
    states =
        (map['states'] as List?)?.map((e) => RoomState.fromJson(e)).toList() ??
            [];
    roommates = (map['roommates'] as Map<String, dynamic>?)
            ?.map(
              (key, value) => MapEntry(
                key,
                AppUser.fromJson(value),
              ),
            )
            .values
            .toList() ??
        [];
    owner = AppUser.fromJson(map['owner']);
    isComeIn = map['isComeIn'] ?? false;
  }

  Room.fromJson(Map<String, dynamic> map, this.uid)
      : name = map['name'],
        location = geoFromJson(map['location']),
        number = map['number'],
        state = (map['state'] as Map<String, dynamic>?)
            ?.let((that) => RoomState.fromJson(that)),
        states = (map['states'] as List?)
                ?.map((e) => RoomState.fromJson(e))
                .toList() ??
            [],
        roommates = (map['roommates'] as Map<String, dynamic>?)
                ?.map(
                  (key, value) => MapEntry(
                    key,
                    AppUser.fromJson(value),
                  ),
                )
                .values
                .toList() ??
            [],
        isComeIn = map['isComeIn'] ?? false,
        owner = AppUser.fromJson(map['owner']);

  Room.testing()
      : name = "Alpha's Room",
        number = 702,
        uid = '000',
        roommates = [
          AppUser(
              displayName: "Joseph",
              uid: const Uuid().v4(),
              photoURL:
                  "https://res.cloudinary.com/dtpgi0zck/image/upload/s--SsFGdDoP--/c_fill,h_580,w_860/v1/EducationHub/photos/ocean-waves.jpg"),
          AppUser(
              displayName: "Alex",
              uid: const Uuid().v4(),
              photoURL:
                  "https://d32qe1r3a676y7.cloudfront.net/eyJidWNrZXQiOiJibG9nLWVjb3RyZWUiLCJrZXkiOiAiYmxvZy8wMDAxLzAxL2FkNDZkYmI0NDdjZDBlOWE2YWVlY2Q2NGNjMmJkMzMyYjBjYmNiNzkuanBlZyIsImVkaXRzIjp7InJlc2l6ZSI6eyJ3aWR0aCI6IDkwMCwiaGVpZ2h0IjowLCJmaXQiOiJjb3ZlciJ9fX0="),
          AppUser(
            displayName: "Victor",
            uid: const Uuid().v4(),
          ),
        ],
        states = [
          RoomState.busy(),
          RoomState.quiet(),
        ];
}
