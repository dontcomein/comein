import 'package:comein/models/data_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class PushNotifications {
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    if (kDebugMode) {
      print('A background message just showed up :  ${message.messageId}');
    }
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              color: Colors.blue,
              playSound: true,
              icon: android.smallIcon,
            ),
            iOS: const IOSNotificationDetails(
              presentSound: true,
              presentBadge: true,
              presentAlert: true,
            )),
      );
    }
  }

  static final onNotifications = BehaviorSubject<String?>();
  static Future initialize({bool initScheduled = false}) async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsiOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsiOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) async {
        onNotifications.add(payload);
      },
    );

    FirebaseMessaging.onMessage.listen(onMessage);
  }

  static void onMessage(RemoteMessage message) {
    print('A message just showed up : ${message.messageId}');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              color: Colors.blue,
              playSound: true,
              icon: android?.smallIcon,
            ),
            iOS: const IOSNotificationDetails(
              presentSound: true,
              presentBadge: true,
              presentAlert: true,
            )),
      );
    }
  }

  static Future<String?> getToken() async {
    return messaging.getToken();
  }
}