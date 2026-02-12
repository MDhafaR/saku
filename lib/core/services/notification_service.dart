import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _keyIsEnabled = 'reminder_enabled';
  static const String _keyTimes = 'reminder_times';
  static const String _keyMessageType = 'reminder_message_type';
  static const String _keyCustomMessage = 'reminder_custom_message';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    _configureLocalTimezone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // Request notification permissions (needed for Android 13+)
    await requestPermissions();

    // Reschedule notifications based on saved settings
    await rescheduleNotifications();
  }

  Future<void> requestPermissions() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  // ── Persistence ─────────────────────────────────────────────────────

  Future<void> saveReminderSettings({
    required bool isEnabled,
    required List<String> times,
    required int messageType,
    required String customMessage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsEnabled, isEnabled);
    await prefs.setStringList(_keyTimes, times);
    await prefs.setInt(_keyMessageType, messageType);
    await prefs.setString(_keyCustomMessage, customMessage);
  }

  Future<Map<String, dynamic>> loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isEnabled': prefs.getBool(_keyIsEnabled) ?? true,
      'times': prefs.getStringList(_keyTimes) ?? ['08:00', '20:00'],
      'messageType': prefs.getInt(_keyMessageType) ?? 1,
      'customMessage':
          prefs.getString(_keyCustomMessage) ??
          'Jangan lupa catat pengeluaran hari ini ya! 💸',
    };
  }

  /// Re-schedule all notifications from saved settings.
  /// Called at app startup to ensure alarms persist across reboots.
  Future<void> rescheduleNotifications() async {
    final settings = await loadReminderSettings();
    final bool isEnabled = settings['isEnabled'];
    final List<String> times = List<String>.from(settings['times']);
    final int messageType = settings['messageType'];
    final String customMessage = settings['customMessage'];

    await cancelAllNotifications();

    if (!isEnabled) return;

    String message = messageType == 0
        ? ' waktunya mencatat keuangan! '
        : customMessage;

    if (message.isEmpty) {
      message = 'Jangan lupa catat pengeluaran hari ini ya! 💸';
    }

    for (int i = 0; i < times.length; i++) {
      final parts = times[i].split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      await scheduleDailyNotification(
        id: i,
        title: 'Pengingat Harian',
        body: message,
        hour: hour,
        minute: minute,
      );
    }
  }

  // ── Instant (for testing / confirmation) ─────────────────────────────

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id: 999,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Notification for daily tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ── Scheduling ──────────────────────────────────────────────────────

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    print(
      '[NotificationService] Scheduling notification id=$id at $scheduledDate (tz.local=${tz.local.name})',
    );
    print('[NotificationService] Current time: ${tz.TZDateTime.now(tz.local)}');

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            'Daily Reminders',
            channelDescription: 'Notification for daily tasks',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('[NotificationService] zonedSchedule() completed successfully');

      // Verify the notification was registered
      final pending = await flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
      print('[NotificationService] Pending notifications: ${pending.length}');
      for (final p in pending) {
        print(
          '[NotificationService]   - id=${p.id}, title=${p.title}, body=${p.body}',
        );
      }
    } catch (e, stack) {
      print('[NotificationService] ERROR in zonedSchedule: $e');
      print('[NotificationService] Stack: $stack');
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  void _configureLocalTimezone() {
    final deviceTimeZoneName = DateTime.now().timeZoneName;
    print('[NotificationService] Device timeZoneName: $deviceTimeZoneName');
    print(
      '[NotificationService] Device offset: ${DateTime.now().timeZoneOffset}',
    );

    // 1. Try direct IANA name lookup
    try {
      tz.setLocalLocation(tz.getLocation(deviceTimeZoneName));
      print(
        '[NotificationService] Timezone set via IANA name: $deviceTimeZoneName',
      );
      return;
    } catch (_) {}

    // 2. Fallback: match timezone by UTC offset from the device
    final deviceOffset = DateTime.now().timeZoneOffset;
    final offsetMs = deviceOffset.inMilliseconds;

    // Prefer well-known timezones for common offsets (literal ms values)
    final offsetToTimezone = <int, String>{
      25200000: 'Asia/Jakarta', // WIB  UTC+7  (7*3600000)
      28800000: 'Asia/Makassar', // WITA UTC+8  (8*3600000)
      32400000: 'Asia/Jayapura', // WIT  UTC+9  (9*3600000)
      19800000: 'Asia/Kolkata', // IST  UTC+5:30
      0: 'UTC',
      -18000000: 'America/New_York', // UTC-5
      -21600000: 'America/Chicago', // UTC-6
      -25200000: 'America/Denver', // UTC-7
      -28800000: 'America/Los_Angeles', // UTC-8
      3600000: 'Europe/London', // UTC+1
    };

    if (offsetToTimezone.containsKey(offsetMs)) {
      final tzName = offsetToTimezone[offsetMs]!;
      tz.setLocalLocation(tz.getLocation(tzName));
      print('[NotificationService] Timezone set via offset map: $tzName');
      return;
    }

    // 3. Last resort: iterate all locations for matching offset
    for (final location in tz.timeZoneDatabase.locations.values) {
      if (location.currentTimeZone.offset == offsetMs) {
        tz.setLocalLocation(location);
        print(
          '[NotificationService] Timezone set via offset scan: ${location.name}',
        );
        return;
      }
    }

    print(
      '[NotificationService] WARNING: Could not determine timezone, using UTC',
    );
  }
}
