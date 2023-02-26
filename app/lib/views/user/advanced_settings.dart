import 'package:comein/components/platform_graphics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AdvancedSettings extends StatefulWidget {
  const AdvancedSettings({super.key});

  @override
  State<AdvancedSettings> createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text("Advanced Settings"),
        ),
        body: PlatformListView(
          children: [
            PlatformTextButton(
              child: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => showPlatformDialog(
                context: context,
                builder: (_) => PlatformAlertDialog(
                  title: const Text("Delete Account"),
                  content: const Text(
                      "Are you sure you want to delete your account? This action cannot be undone."),
                  actions: [
                    PlatformDialogAction(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    PlatformDialogAction(
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
}
