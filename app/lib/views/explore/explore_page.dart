import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comein/components/platform_graphics.dart';
import 'package:comein/models/data_model.dart';
import 'package:comein/models/room_model.dart';
import 'package:comein/views/explore/open_room_tile.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  GeoPoint? lesserGeopoint;
  GeoPoint? greaterGeopoint;
  int distance = 3;

  List<Room> rooms = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebaseFirestore
          .collection("rooms")
          // .where("location", isGreaterThan: lesserGeopoint)
          // .where("location", isGreaterThan: greaterGeopoint)
          .where("isComeIn", isEqualTo: true)
          //.orderBy("attendees", descending: true)
          .limit(6)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data as QuerySnapshot;
          final docs = data.docs;
          rooms = docs.map((e) {
            final room = Room(name: "", uid: e.id, number: 1);
            room.update(e);
            return room;
          }).toList();
        }
        return SafeArea(
          child: PlatformListView(
            children: rooms.map((room) => OpenRoomTile(room)).toList(),
          ),
        );
      },
    );
  }
}
