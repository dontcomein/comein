import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comein/components/pfp.dart';
import 'package:comein/components/platform_graphics.dart';
import 'package:comein/main.dart';
import 'package:comein/models/app_user.dart';
import 'package:flutter/material.dart';

/// UI to check and change the role of users in an event
class UserTile extends StatefulWidget {
  const UserTile({
    super.key,
    required this.user,
    required this.ref,
    this.currentUser,
  });
  final AppUser user;
  final AppUser? currentUser;
  final DocumentReference? ref;
  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) => PlatformListTile(
        leading: PFP(widget.user),
        title: Text(
          widget.user.displayName ?? unknown,
        ),
        subtitle: Text(
          widget.user.email ?? unknown,
          style: Theme.of(context).textTheme.caption,
        ),
      );
}
