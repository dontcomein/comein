import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comein/models/room_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension LocationExt on GeoPoint {
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

extension ObjectExt<T> on T {
  R let<R>(R Function(T that) op) => op(this);
}

GeoPoint? geoFromJson(Map<String, dynamic>? map) =>
    map == null ? null : GeoPoint(map['latitude'], map['longitude']);

extension ColorExt on Color {
  Map<String, dynamic> toJson() => {
        'a': alpha,
        'r': red,
        'g': green,
        'b': blue,
      };
  Color inverse() => Color.fromARGB(alpha, 255 - red, 255 - green, 255 - blue);
}

extension RoomStateExt on RoomState {
  String toRep() {
    return name;
  }

  Color getColor() {
    return color;
  }
}

Color? colorFromJson(Map<String, dynamic>? map) =>
    map == null ? null : Color.fromARGB(map['a'], map['r'], map['g'], map['b']);
