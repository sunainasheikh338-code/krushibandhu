import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings: initializationSettings);

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();

    await androidImplementation?.requestExactAlarmsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String message,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'krushibandhu_reminders',
          'KrushiBandhu Reminders',
          channelDescription: 'Crop reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: id,
      title: title,
      body: message,
      notificationDetails: details,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String message,
    required DateTime scheduledDate,
  }) async {
    final scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'krushibandhu_reminders',
          'KrushiBandhu Reminders',
          channelDescription: 'Crop reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: message,
      scheduledDate: scheduledTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
