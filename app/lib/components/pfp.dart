// Profile Picture
import 'package:comein/models/app_user.dart';
import 'package:flutter/material.dart';

/// Displays a [user]'s profile picture
class PFP extends StatelessWidget {
  const PFP(
    this.user, {
    super.key,
    this.size = 50,
  });
  final AppUser user;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: size,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            user.photoURL != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(300),
                    child: Image.network(
                      user.photoURL!,
                      height: size,
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: size,
                  ),
          ],
        ),
      );
}
