import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comein/components/user_tile.dart';
import 'package:comein/models/app_user.dart';
import 'package:comein/models/data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});
  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  EmailContact? _emailContact;
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) =>
      StreamBuilder<DocumentSnapshot<Object?>>(
        stream: dataModel.userStream,
        builder: (context, eventHandler) {
          if (eventHandler.hasData && !eventHandler.hasError) {
            dataModel.friends = (eventHandler.data?.get("friends")
                        as Map<String, dynamic>?)
                    ?.map(
                        (key, value) => MapEntry(key, AppUser.fromJson(value)))
                    .values
                    .toList() ??
                [];
          }
          return PlatformScaffold(
            appBar: PlatformAppBar(
              title: const Text('Add Friend'),
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
                            dataModel
                                .addFriend(emailController.text.trim())
                                .then((_) => Navigator.pop(context));
                            emailController.clear();
                          }
                        },
                        child: const Text('Share'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: dataModel.friends
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
