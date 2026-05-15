import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/promises/domain/promise_model.dart';
import '../../features/promises/domain/promise_enums.dart' as domain;
import '../../features/money/domain/money_model.dart';
import '../../features/borrow/domain/item_model.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> init() async {
    try {
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
      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  static Future<void> schedulePromiseNotification(Promise promise) async {
    try {
      await cancelPromiseNotification(promise.id);

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
    } catch (e) {
      debugPrint('schedulePromiseNotification error: $e');
    }
  }

  static Future<void> cancelPromiseNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('cancelPromiseNotification error: $e');
    }
  }

  static Future<void> scheduleMoneyNotification(MoneyRecord record) async {
    try {
      final int id = record.id + 1000000;
      await cancelMoneyNotification(record.id);

      if (record.status != domain.MoneyStatus.pending || record.dueDate == null) return;

      DateTime scheduledTime = DateTime(
        record.dueDate!.year, record.dueDate!.month, record.dueDate!.day, 9, 0
      );
      if (scheduledTime.isBefore(DateTime.now())) return;

      await _schedule(id, 'Payment Due Today', '${record.currency} ${record.amount}', scheduledTime);
    } catch (e) {
      debugPrint('scheduleMoneyNotification error: $e');
    }
  }

  static Future<void> cancelMoneyNotification(int id) async {
    try {
      await _plugin.cancel(id + 1000000);
    } catch (e) {
      debugPrint('cancelMoneyNotification error: $e');
    }
  }

  static Future<void> scheduleBorrowNotification(BorrowItem item) async {
    try {
      final int id = item.id + 2000000;
      await cancelBorrowNotification(item.id);

      if (item.status == domain.ItemStatus.returned || item.expectedReturn == null) return;

      DateTime scheduledTime = DateTime(
        item.expectedReturn!.year, item.expectedReturn!.month, item.expectedReturn!.day, 9, 0
      );
      if (scheduledTime.isBefore(DateTime.now())) return;

      await _schedule(id, 'Item Return Due', item.name, scheduledTime);
    } catch (e) {
      debugPrint('scheduleBorrowNotification error: $e');
    }
  }

  static Future<void> cancelBorrowNotification(int id) async {
    try {
      await _plugin.cancel(id + 2000000);
    } catch (e) {
      debugPrint('cancelBorrowNotification error: $e');
    }
  }

  static Future<void> _schedule(int id, String title, String body, DateTime time) async {
    if (!_isInitialized) return;
    try {
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
    } catch (e) {
      // Ignore notification scheduling errors (e.g. missing EXACT_ALARM permission)
      debugPrint('Failed to schedule notification: $e');
    }
  }

  static Future<void> cancel(int notificationId) async {
    try {
      await _plugin.cancel(notificationId);
    } catch (e) {
      debugPrint('cancel error: $e');
    }
  }
}
