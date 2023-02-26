import 'package:comein/components/color_picker.dart';
import 'package:comein/components/pfp.dart';
import 'package:comein/components/platform_graphics.dart';
import 'package:comein/models/app_user.dart';
import 'package:comein/models/data_model.dart';
import 'package:comein/providers/auth.dart';
import 'package:comein/views/user/advanced_settings.dart';
// import 'package:cupertino_lists/cupertino_lists.dart';
import 'package:flutter/cupertino.dart';
import 'package:comein/functions/extension_functions.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class UserView extends StatefulWidget {
  const UserView({super.key, required this.appUser});
  final AppUser appUser;
  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(
          children: [
            PFP(dataModel.currentUser ?? AppUser(uid: "")),
            PlatformListTileGroup(
              header: Text(widget.appUser.displayName ?? "Guest"),
              children: [
                PlatformListTile(
                  title: const Text("Advanced Settings"),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => Navigator.push(
                    context,
                    platformPageRoute(
                      context: context,
                      builder: (_) => const AdvancedSettings(),
                    ),
                  ),
                ),
                PlatformTextButton(
                  child: const Text(
                    "Sign Out",
                    style: TextStyle(color: CupertinoColors.systemRed),
                  ),
                  onPressed: () => showPlatformDialog(
                    context: context,
                    builder: (context) => PlatformAlertDialog(
                      title: const Text("Sign Out"),
                      content: const Text("Are you sure you want to sign out?"),
                      actions: [
                        PlatformDialogAction(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        PlatformDialogAction(
                          child: const Text("Confirm",
                              style:
                                  TextStyle(color: CupertinoColors.systemRed)),
                          onPressed: () => context
                              .read<AuthenticationService>()
                              .signOut()
                              .then((value) => Navigator.pop(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
