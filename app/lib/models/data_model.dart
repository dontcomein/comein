import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:comein/models/app_user.dart';
import 'package:comein/models/room_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:comein/functions/extension_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFunctions firebaseFunctions = FirebaseFunctions.instance;
FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
FirebaseMessaging messaging = FirebaseMessaging.instance;
DataModel dataModel = DataModel();

class DataModel {
  List<Room> rooms = [];
  List<Room> inbox = [];
  List<AppUser> friends = [];
  AppUser? currentUser;
  String? token;

  Stream<DocumentSnapshot<Map<String, dynamic>>> get userStream =>
      firebaseFirestore
          .collection('users')
          .doc(firebaseAuth.currentUser?.uid ?? "")
          .snapshots();

  void update(Map<String, dynamic> json) {
    (json['rooms'] as Map<String, dynamic>?)?.let(
      (that) => rooms = that
          .map((key, value) => MapEntry(key, Room.fromJson(value, key)))
          .values
          .toList(),
    );
    (json['inbox'] as Map<String, dynamic>?)?.let(
      (that) => inbox = that
          .map((key, value) => MapEntry(key, Room.fromJson(value, key)))
          .values
          .toList(),
    );
  }

  Future<HttpsCallableResult> addFriend(String email) =>
      firebaseFunctions.httpsCallable('addFriend').call({'email': email});
}
