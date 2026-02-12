import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

void main() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id: 0,
    title: 'title',
    body: 'body',
    scheduledDate: tz.TZDateTime.now(tz.local),
    notificationDetails: const NotificationDetails(),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}
