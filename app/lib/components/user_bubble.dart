import 'package:comein/components/pfp.dart';
import 'package:comein/models/app_user.dart';
import 'package:flutter/material.dart';

class UserBubble extends StatelessWidget {
  const UserBubble(this.user, {super.key, this.size = 50});
  final AppUser user;
  final double size;
  @override
  Widget build(BuildContext context) => PFP(user, size: size);
}
