import 'package:comein/models/data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:comein/functions/extension_functions.dart';

enum Role { admin, editor, viewer }

class AppUser {
  String uid;
  String? displayName, photoURL, email, number;
  Role role = Role.viewer;
  Color? signature;

  AppUser({
    this.displayName,
    this.photoURL,
    this.email,
    this.number,
    this.signature,
    required this.uid,
  });

  void setSignature(Color color) => firebaseFirestore
      .collection('users')
      .doc(uid)
      .update({'signature': signature?.toJson()});

  Map<String, dynamic> toJson() => {
        'name': displayName,
        'photoUrl': photoURL,
        'role': role.toString(),
        'email': email,
        'number': number,
        'signature': signature?.toJson(),
        'uid': uid,
      };

  AppUser.fromJson(Map<String, dynamic>? map)
      : displayName = map?['name'],
        photoURL = map?['photoUrl'],
        email = map?['email'],
        number = map?['number'],
        signature = colorFromJson(map?['signature']),
        uid = map?['uid'] ?? "";

  AppUser.fromFirebaseUser(User? user)
      : email = user?.email,
        uid = user?.uid ?? "",
        photoURL = user?.photoURL,
        displayName = user?.displayName;
}
