import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _notificationIdCounter = 0; // Counter for incrementing notification IDs

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> showNotification(String title, String message) async {
    _notificationIdCounter++; // Increment the counter for each notification

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high channel',
      'Very important notification!!',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      icon: '@mipmap/launcher_icon',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      _notificationIdCounter, // Use the incremented counter as the notification ID
      title,
      message,
      platformChannelSpecifics,
      payload:
          'HomeApp', // You can pass a payload to identify which page to navigate to
    );
  }
}




  // Future<void> initializeNotifications() async {
  //   AndroidInitializationSettings initializationSettingsAndroid =
  //     AndroidInitializationSettings('@mipmap/ic_launcher');
  //   const DarwinInitializationSettings initializationSettingsIOS =
  //       DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestSoundPermission: true,
  //   );
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');

  //   const InitializationSettings initializationSettings =
  //       InitializationSettings(
  //     android: initializationSettingsAndroid,
  //     iOS: initializationSettingsIOS,
  //   );
  //   await flutterLocalNotificationsPlugin.initialize(
  //     initializationSettings,
  //     // onSelectNotification: (String? payload) async {
  //     //   Navigator.push(
  //     //       context,
  //     //       MaterialPageRoute(
  //     //         builder: (context) => const HomeApp(),
  //     //       ));
  //     // }
  //   );
  // }