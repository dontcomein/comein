import 'package:comein/components/PFP.dart';
import 'package:comein/models/app_user.dart';
import 'package:flutter/material.dart';

class UserBubble extends StatelessWidget {
  const UserBubble(this.user, {super.key, this.size = 50});
  final AppUser user;
  final double size;
  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(300),
            child: Container(
              color: user.signature?.withOpacity(0.3),
              height: size * 1.5,
              width: size * 1.5,
              child: Column(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(user.displayName ?? "Anonymous"),
                  )
                ],
              ),
            ),
          ),
          PFP(user, size: size),
        ],
      );
}
