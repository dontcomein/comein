import 'package:comein/providers/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});
  @override
  State<Verify> createState() => _Verify();
}

class _Verify extends State<Verify> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            Image.asset(
              "LoadingScreen.png",
            ),
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "A verfication email has been sent,",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const Text(
                        "Once verified, you will need to sign out and sign back in using these credentials",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      PlatformTextButton(
                        color: Colors.blue,
                        child: const Text("Send Email Again"),
                        onPressed: () async {
                          await context.read<User?>()?.sendEmailVerification();
                          showPlatformDialog(
                            context: context,
                            builder: (_) => PlatformAlertDialog(
                              title: const Text("Verification Email Sent"),
                              actions: [
                                PlatformDialogAction(
                                  child: const Text("Okay"),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      PlatformTextButton(
                        color: CupertinoColors.systemRed,
                        child: const Text("Sign Out"),
                        onPressed: () =>
                            context.read<AuthenticationService>().signOut(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
