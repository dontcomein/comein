import 'package:comein/models/app_user.dart';
import 'package:comein/models/data_model.dart';
import 'package:comein/views/landing_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'verify_auth.dart';
import 'login_view.dart';
import 'package:comein/functions/extension_functions.dart';

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapper();
}

class _AuthenticationWrapper extends State<AuthenticationWrapper> {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    firebaseUser
        ?.let((user) => dataModel.currentUser = AppUser.fromFirebaseUser(user));
    if (firebaseUser == null) {
      return const LoginView();
    } else {
      return const LandingPage();
    }
  }
}
