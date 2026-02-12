import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  tz.initializeTimeZones();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Attempt to call with the "fixed" signature
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id: 0,
    title: 'test',
    body: 'test',
    scheduledDate: tz.TZDateTime.now(tz.local),
    notificationDetails: const NotificationDetails(),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );
  print('Success');
}
