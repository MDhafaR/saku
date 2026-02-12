import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

void main() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // Call with minimal arguments to trigger "required argument missing" errors
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id: 0,
    scheduledDate: tz.TZDateTime.now(tz.local),
    notificationDetails: const NotificationDetails(),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}
