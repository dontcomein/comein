import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comein/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:comein/functions/extension_functions.dart';

class RoomState {
  String name;
  Color color;
  Timestamp lastSet;
  AppUser? lastSetter;
  Duration duration;
  bool isComeIn;

  RoomState({
    required this.name,
    required this.color,
    required this.lastSet,
    this.lastSetter,
    required this.duration,
    this.isComeIn = false,
  });

  double percentFinished() {
    double diff = (DateTime.now().difference(lastSet.toDate()).inSeconds /
            duration.inSeconds)
        .clamp(0, 1);
    return diff;
  }

  DateTime get endTime => lastSet.toDate().add(duration);

  RoomState.comeIn(AppUser setter)
      : this(
          name: "Come In!",
          color: Colors.yellow,
          lastSet: Timestamp.now(),
          lastSetter: setter,
          duration: const Duration(minutes: 15),
          isComeIn: true,
        );

  RoomState.quiet(AppUser setter)
      : this(
          name: "Quiet",
          color: Colors.purple,
          lastSet: Timestamp.now(),
          lastSetter: setter,
          duration: const Duration(minutes: 15),
          isComeIn: true,
        );

  RoomState.busy(AppUser setter)
      : this(
          name: "Busy",
          color: Colors.red,
          lastSet: Timestamp.now(),
          lastSetter: setter,
          duration: const Duration(minutes: 15),
          isComeIn: true,
        );

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color.value,
        'lastSet': lastSet,
        'lastSetter': lastSetter?.toJson(),
        'duration': duration.inMinutes,
        'isComeIn': isComeIn,
      };

  String broadcast() =>
      "${color.red}, ${color.green}, ${color.blue}, ${duration.inSeconds}";

  RoomState.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? "Free",
        color =
            (json['color'] as int?)?.let((that) => Color(that)) ?? Colors.green,
        lastSet = json['lastSet'],
        lastSetter = json['lastSetter'] != null
            ? AppUser.fromJson(json['lastSetter'])
            : null,
        duration = Duration(minutes: json['duration']),
        isComeIn = json['isComeIn'];
}
