import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comein/models/data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  GeoPoint? lesserGeopoint;
  GeoPoint? greaterGeopoint;
  int distance = 3;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Permission.location.request(),
        builder: (context, snapshot) {
          if (snapshot.data?.isGranted ?? false) {
            return FutureBuilder(
              future: Location().getLocation(),
              builder: (context, snapshot) {
                double lat = 0.0144927536231884;
                double lon = 0.0181818181818182;
                final loc = snapshot.data;

                final userGeoPoint =
                    GeoPoint(loc?.latitude ?? 0, loc?.longitude ?? 0);
                double lowerLat = userGeoPoint.latitude - (lat * distance);
                double lowerLon = userGeoPoint.longitude - (lon * distance);

                double greaterLat = userGeoPoint.latitude + (lat * distance);
                double greaterLon = userGeoPoint.longitude + (lon * distance);

                lesserGeopoint = GeoPoint(lowerLat, lowerLon);
                greaterGeopoint = GeoPoint(greaterLat, greaterLon);
                return FirestoreListView(
                  loadingBuilder: (context) => Center(
                    child: PlatformCircularProgressIndicator(),
                  ),
                  query: firebaseFirestore
                      .collection("rooms")
                      // .where("location", isGreaterThan: lesserGeopoint)
                      // .where("location", isGreaterThan: greaterGeopoint)
                      .where("state", isEqualTo: "RoomState.comeIn")
                      //.orderBy("attendees", descending: true)
                      .limit(2),
                  itemBuilder: (context, snapshot) {
                    return ListTile();
                  },
                );
              },
            );
          } else {
            return Container();
          }
        });
  }
}
