import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class MyNotification {
  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    tz.initializeTimeZones();
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  static Future showBigTextNotification(
      {var id = 0,
      required String title,
      required String body,
      var payload,
      required FlutterLocalNotificationsPlugin fln}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'poetry_ai_notification',
      'Poetry AI',
      playSound: true,
      // sound: RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high,
    );

    var notif = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails());
    await fln.show(0, title, body, notif);
  }

  static Future showScheduledNotif(
      {required int id,
      required String title,
      required String body,
      required int seconds,
      required FlutterLocalNotificationsPlugin fln}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'poetry_ai_notification',
      'Poetry AI',
      playSound: true,
      // sound: RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high,
    );

    var notif = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails());
    await fln.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(
            DateTime.now().add(Duration(seconds: seconds)), tz.local),
        notif,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  static Future<void> scheduleRepeatedNotifications(
      FlutterLocalNotificationsPlugin fln) async {
    // Schedule the first notification
    await showScheduledNotif(
      id: 1,
      title: 'Scheduled Notification',
      body: 'This is a scheduled notification.',
      seconds: 0, // Show immediately
      fln: fln,
    );

    // Schedule the subsequent notifications every 12 hours
    // for (int i = 1; i <= 100; i++) {
    //   await showScheduledNotif(
    //     id: i + 1,
    //     title: 'Scheduled Notification',
    //     body: 'This is a scheduled notification.',
    //     seconds: 12 * 60 * 60 * i, // 12 hours interval
    //     fln: fln,
    //   );
    // }
  }
}
