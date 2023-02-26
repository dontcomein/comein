import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comein/components/user_tile.dart';
import 'package:comein/models/app_user.dart';
import 'package:comein/models/room_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

class RoomShare extends StatefulWidget {
  const RoomShare(this.room, {super.key});
  final Room room;
  @override
  State<RoomShare> createState() => _RoomShareState();
}

class _RoomShareState extends State<RoomShare> {
  EmailContact? _emailContact;
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) =>
      StreamBuilder<DocumentSnapshot<Object?>>(
        stream: widget.room.getRef().snapshots(),
        builder: (context, eventHandler) {
          // if (eventHandler.hasData && !eventHandler.hasError) {
          //   widget.room.assign(
          //     Room.fromJson(
          //       json.decode(
          //         json.encode(eventHandler.data?.data()),
          //       ),
          //       widget.room.uid,
          //     ),
          //   );
          // }
          return PlatformScaffold(
            appBar: PlatformAppBar(
              title: const Text('Share Room'),
            ),
            body: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      PlatformIconButton(
                        onPressed: _onPressed,
                        icon: Icon(PlatformIcons(context).personAdd),
                        color: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.all(20),
                      ),
                      Expanded(
                        child: PlatformTextField(
                          textInputAction: TextInputAction.done,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          autocorrect: false,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: PlatformTextButton(
                        color: Colors.green,
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          if (emailController.text.trim().isNotEmpty) {
                            showPlatformDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => PlatformAlertDialog(
                                content: Center(
                                  child: PlatformCircularProgressIndicator(),
                                ),
                              ),
                            );
                            await widget.room.shareRoom(
                              email: emailController.text.trim(),
                              role: Role.editor,
                            );
                            emailController.clear();
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Share'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: widget.room.roommates
                          .map(
                            (roommate) => UserTile(
                              user: roommate,
                              ref: null,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  void _onPressed() async {
    _emailContact = await FlutterContactPicker.pickEmailContact();
    emailController.text = _emailContact?.email?.email ?? '';
  }
}
