import 'dart:io';

import 'package:comein/providers/bluetooth_connector.dart';
import 'package:comein/providers/config_name_controller.dart';
import 'package:comein/models/data_model.dart';
import 'package:comein/providers/auth.dart';
import 'package:comein/providers/push_notifications.dart';
import 'package:comein/providers/snackbar_controller.dart';
import 'package:comein/views/auth/authentication_wrapper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  getIt.registerSingleton<ConfigNameController>(
    ConfigNameController(deviceName),
  );
  getIt.registerSingleton<SnackbarController>(SnackbarController());
  getIt.registerSingleton<BluetoothConnector>(BluetoothController());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  ); // ask for permission to receive push notifications
  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    await PushNotifications.initialize();
    dataModel.token = await PushNotifications.getToken();
  } else {
    if (kDebugMode) print('User declined or has not accepted permission');
  }
  HttpOverrides.global = MyHttpOverrides();
  runApp(const ComeIn());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

const String appTitle = "Come In!";
const String deviceName = "ESP32";
const Color primaryColor = Color.fromARGB(255, 18, 194, 230);
const Color secondaryColor = Color.fromARGB(255, 0, 230, 117);
const String unknown = "Unknown";

class ComeIn extends StatelessWidget {
  const ComeIn({super.key});
  @override
  build(BuildContext context) => MultiProvider(
        providers: [
          Provider<AuthenticationService>(
            create: (_) => AuthenticationService(firebaseAuth),
          ),
          StreamProvider(
            initialData: null,
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges,
          ),
        ],
        child: PlatformApp(
          debugShowCheckedModeBanner: false,
          title: appTitle,
          material: (context, platform) => MaterialAppData(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: primaryColor,
                secondary: secondaryColor,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
            ),
          ),
          cupertino: (context, platform) => CupertinoAppData(
            theme: const CupertinoThemeData(
              brightness: Brightness.light,
              primaryColor: primaryColor,
              primaryContrastingColor: secondaryColor,
            ),
          ),
          home: const AuthenticationWrapper(),
        ),
      );
}
