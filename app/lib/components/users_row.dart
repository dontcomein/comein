import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:comein/components/pfp.dart';
import 'package:comein/models/app_user.dart';
import 'package:flutter/material.dart';

/// Displays [users] profile pictures in a row
class UsersRow extends StatelessWidget {
  const UsersRow({
    super.key,
    required this.users,
    this.showRole = false,
    this.size = 20,
  });
  final List<AppUser> users;
  final bool showRole;
  final double size;
  @override
  Widget build(BuildContext context) => RowSuper(
        invert: true,
        innerDistance: 10.0,
        children: users.map((user) => PFP(user, size: size)).toList(),
      );
}
