import 'package:firebase_auth/firebase_auth.dart';

enum Role { admin, editor, viewer }

class AppUser {
  String uid;
  String? displayName, photoURL, email;

  AppUser({
    this.displayName,
    this.photoURL,
    this.email,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'photoURL': photoURL,
        'email': email,
        'uid': uid,
      };

  AppUser.fromJson(Map<String, dynamic>? map)
      : displayName = map?['displayName'],
        photoURL = map?['photoURL'],
        email = map?['email'],
        uid = map?['uid'] ?? "";

  AppUser.fromFirebaseUser(User? user)
      : email = user?.email,
        uid = user?.uid ?? "",
        photoURL = user?.photoURL,
        displayName = user?.displayName;
}
