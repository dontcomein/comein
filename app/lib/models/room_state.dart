import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comein/models/app_user.dart';
import 'package:comein/models/data_model.dart';
import 'package:flutter/material.dart';
import 'package:comein/functions/extension_functions.dart';
import 'package:uuid/uuid.dart';

class RoomState {
  String name;
  String description;
  Color color;
  Timestamp setAt;
  AppUser? setter;
  Duration? duration;
  bool isComeIn;
  String uid = const Uuid().v4();

  RoomState({
    required this.name,
    required this.description,
    required this.color,
    required this.setAt,
    this.setter,
    required this.duration,
    this.isComeIn = false,
  });

  @override
  operator ==(other) => other is RoomState ? equals(other) : false;

  bool equals(RoomState other) => uid == other.uid;

  double percentFinished() {
    double diff = (DateTime.now().difference(setAt.toDate()).inSeconds /
            (duration?.inSeconds ?? 1))
        .clamp(0, 1);
    return diff;
  }

  DateTime get endTime => setAt.toDate().add(duration ?? const Duration());

  bool expired() => isComeIn ? false : DateTime.now().isAfter(endTime);

  RoomState now() {
    setAt = Timestamp.now();
    setter = AppUser.fromFirebaseUser(firebaseAuth.currentUser);
    return this;
  }

  RoomState.quiet([AppUser? setter])
      : this(
          name: "Sleeping",
          description: "Enter quietly",
          color: const Color.fromARGB(255, 31, 153, 228),
          setAt: Timestamp.now(),
          setter: setter,
          duration: const Duration(minutes: 15),
          isComeIn: false,
        );

  RoomState.busy([AppUser? setter])
      : this(
          name: "Busy",
          description: "Do not enter",
          color: const Color.fromARGB(255, 255, 17, 0),
          setAt: Timestamp.now(),
          setter: setter,
          duration: const Duration(minutes: 15),
          isComeIn: false,
        );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'color': color.toJson(),
        'setAt': setAt.toJson(),
        'setter': setter?.toJson(),
        'duration': duration?.inMinutes,
        'isComeIn': isComeIn,
        'uid': uid,
      };

  String broadcast() =>
      "${color.red},${color.green},${color.blue},${duration?.inSeconds ?? 0}";

  RoomState.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? "Free",
        description = json['description'] ?? "Free",
        color = (json['color'] as Map<String, dynamic>?)
                ?.let((that) => colorFromJson(that)) ??
            Colors.green,
        setAt = timestampFromJson(json['setAt']),
        setter = AppUser.fromJson(json['setter']),
        duration =
            (json['duration'] as int?)?.let((that) => Duration(minutes: that)),
        uid = json['uid'],
        isComeIn = json['isComeIn'];
  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}
