import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/promises/domain/promise_model.dart';
import '../../features/promises/domain/promise_enums.dart' as domain;
import '../../features/money/domain/money_model.dart';
import '../../features/borrow/domain/item_model.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  static Future<void> schedulePromiseNotification(Promise promise) async {
    await _plugin.cancel(promise.id); // Always cancel existing first

    if (promise.status == domain.PromiseStatus.completed || promise.dueDate == null) return;

    DateTime scheduledTime = promise.dueDate!;
    if (promise.dueTime != null) {
      scheduledTime = DateTime(
        promise.dueDate!.year, promise.dueDate!.month, promise.dueDate!.day,
        promise.dueTime!.hour, promise.dueTime!.minute,
      );
    } else {
      scheduledTime = DateTime(
        scheduledTime.year, scheduledTime.month, scheduledTime.day, 9, 0
      ); // Default 9 AM
    }

    if (scheduledTime.isBefore(DateTime.now())) return;

    await _schedule(promise.id, 'Promise Due Today', promise.title, scheduledTime);
  }

  static Future<void> cancelPromiseNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> scheduleMoneyNotification(MoneyRecord record) async {
    final int id = record.id + 1000000;
    await _plugin.cancel(id);

    if (record.status != domain.MoneyStatus.pending || record.dueDate == null) return;

    DateTime scheduledTime = DateTime(
      record.dueDate!.year, record.dueDate!.month, record.dueDate!.day, 9, 0
    );
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _schedule(id, 'Payment Due Today', '${record.currency} ${record.amount}', scheduledTime);
  }

  static Future<void> cancelMoneyNotification(int id) async {
    await _plugin.cancel(id + 1000000);
  }

  static Future<void> scheduleBorrowNotification(BorrowItem item) async {
    final int id = item.id + 2000000;
    await _plugin.cancel(id);

    if (item.status == domain.ItemStatus.returned || item.expectedReturn == null) return;

    DateTime scheduledTime = DateTime(
      item.expectedReturn!.year, item.expectedReturn!.month, item.expectedReturn!.day, 9, 0
    );
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _schedule(id, 'Item Return Due', item.name, scheduledTime);
  }

  static Future<void> cancelBorrowNotification(int id) async {
    await _plugin.cancel(id + 2000000);
  }

  static Future<void> _schedule(int id, String title, String body, DateTime time) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pactora_reminders',
          'Pactora Reminders',
          channelDescription: 'Reminders for your promises and commitments',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancel(int notificationId) async {
    await _plugin.cancel(notificationId);
  }
}
