import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:comein/models/data_model.dart';
import 'package:comein/models/room_state.dart';
import 'package:comein/functions/extension_functions.dart';
import 'package:comein/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Room {
  String name;
  String? message;
  RoomState? state;
  List<RoomState> states;
  List<AppUser> roommates = [];
  GeoPoint? location;
  int? floorNumber, roomNumber;
  AppUser? lastSetter;
  Timestamp? expirationDate;
  bool isLounge;
  late String uid;

  Room({
    required this.name,
    this.location,
    this.state,
    this.isLounge = false,
    this.message,
    this.expirationDate,
    this.states = const [],
  });

  bool equals(Room other) {
    final val = uid == other.uid &&
        state == other.state &&
        name == other.name &&
        message == other.message &&
        location == other.location &&
        isLounge == other.isLounge;
    return val;
  }

  bool operator ==(other) => other is Room ? equals(other) : false;

  Room assign(Room other) {
    uid = other.uid;
    name = other.name;
    message = other.message;
    state = other.state;
    location = other.location;
    isLounge = other.isLounge;
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

  Color getColor() {
    return state?.color ?? Colors.transparent;
  }

  void setState(RoomState state) => getRef().update({
        'state': state.toString(),
        'lastSetter': firebaseAuth.currentUser
            ?.let((that) => AppUser.fromFirebaseUser(that))
            .toJson(),
      });

  void saveChanges() =>
      firebaseFirestore.collection('rooms').doc(uid).update(toJson());

  // TODO: Implement this
  bool isConnected() => true;

  DocumentReference getRef() => firebaseFirestore.collection('rooms').doc(uid);

  Map<String, dynamic> toJson() => {
        'name': name,
        'floorNumber': floorNumber,
        'roomNumber': roomNumber,
        'roommates': {
          for (final roommate in roommates) roommate.uid: roommate.toJson(),
        },
        'state': state?.toJson(),
        'location': location?.toJson(),
        'lastSetter': lastSetter?.toJson(),
        'message': message,
        'isLounge': isLounge,
        'states': states.map((e) => e.toJson()).toList(),
        'expirationDate': expirationDate,
      };

  Room.fromJson(Map<String, dynamic> map, this.uid)
      : name = map['name'],
        location = geoFromJson(map['location']),
        floorNumber = map['floorNumber'],
        roomNumber = map['roomNumber'],
        state = (map['state'] as Map<String, dynamic>?)
            ?.let((that) => RoomState.fromJson(that)),
        states = (map['states'] as List?)
                ?.map((e) => RoomState.fromJson(e))
                .toList() ??
            [],
        message = map['message'],
        lastSetter = AppUser.fromJson(
          map['lastSetter'],
        ),
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
        isLounge = map['isLounge'],
        expirationDate = map['expirationDate'];

  Room.testing()
      : name = "Alpha's Room",
        floorNumber = 7,
        roomNumber = 702,
        uid = '000',
        roommates = [
          AppUser(
              displayName: "Joseph",
              uid: const Uuid().v4(),
              signature: Colors.deepOrange,
              photoURL:
                  "https://res.cloudinary.com/dtpgi0zck/image/upload/s--SsFGdDoP--/c_fill,h_580,w_860/v1/EducationHub/photos/ocean-waves.jpg"),
          AppUser(
              displayName: "Alex",
              uid: const Uuid().v4(),
              signature: Colors.deepPurple,
              photoURL:
                  "https://d32qe1r3a676y7.cloudfront.net/eyJidWNrZXQiOiJibG9nLWVjb3RyZWUiLCJrZXkiOiAiYmxvZy8wMDAxLzAxL2FkNDZkYmI0NDdjZDBlOWE2YWVlY2Q2NGNjMmJkMzMyYjBjYmNiNzkuanBlZyIsImVkaXRzIjp7InJlc2l6ZSI6eyJ3aWR0aCI6IDkwMCwiaGVpZ2h0IjowLCJmaXQiOiJjb3ZlciJ9fX0="),
          AppUser(
            displayName: "Victor",
            uid: const Uuid().v4(),
            signature: Colors.yellow,
          ),
        ],
        states = [
          RoomState(
            color: Colors.red,
            name: "Busy",
            lastSet: Timestamp.now(),
            duration: const Duration(minutes: 30),
          ),
          RoomState(
            color: Colors.green,
            name: "Free",
            lastSet: Timestamp.now(),
            duration: const Duration(minutes: 30),
          ),
          RoomState(
            color: Colors.yellow,
            name: "Quiet",
            lastSet: Timestamp.now(),
            duration: const Duration(minutes: 30),
          ),
        ],
        message = "Demon Time",
        isLounge = false;
}
