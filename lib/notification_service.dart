import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'storage_service.dart';

// English notification action labels
const String _labelMarkDone = 'Mark as Done';
const String _labelSnooze = 'Snooze 5 Min';

// ─────────────────────────────────────────────────────────
// Helper: given the RAW medicine notificationId, return the
// base slot ID used when scheduling (slots 0-5 → baseId+0 … baseId+5).
// This must match exactly what scheduleMedicineReminder() uses.
// ─────────────────────────────────────────────────────────
int _calcBaseId(int rawId) => (rawId.abs() % 100000) * 10;

// ─────────────────────────────────────────────────────────
// Background isolate handler (called when app is killed/background)
// ─────────────────────────────────────────────────────────
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse details) async {
  WidgetsFlutterBinding.ensureInitialized();

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  // ── MARK AS DONE ──────────────────────────────────────
  if (details.actionId == 'MEDICINE_DONE') {
    try {
      if (details.payload != null) {
        final parts = details.payload!.split(':');
        // payload format: "rawId:medicineName:dose"
        if (parts.length >= 2) {
          final rawId = int.tryParse(parts[0]) ?? 0;
          final baseId = _calcBaseId(rawId);

          // Cancel ALL 6 reminder slots (now + every 5 min for 25 min)
          for (int i = 0; i <= 5; i++) {
            await plugin.cancel(baseId + i);
          }

          final medicineName = parts[1].toLowerCase().trim();

          await Hive.initFlutter();
          final box = await Hive.openBox('medicines');

          // Mark medicine as taken via pending list
          final List pending =
              List.from(box.get('pending_taken', defaultValue: []) as List);
          if (!pending.contains(medicineName)) {
            pending.add(medicineName);
            await box.put('pending_taken', pending);
          }

          // Track cancelled base IDs so reschedule logic can skip them
          final List cancelledBases =
              List.from(box.get('cancelled_bases', defaultValue: []) as List);
          if (!cancelledBases.contains(rawId)) {
            cancelledBases.add(rawId);
            await box.put('cancelled_bases', cancelledBases);
          }
        }
      }
    } catch (e) {
      // ignore in background
    }
  }

  // ── SNOOZE 5 MIN ──────────────────────────────────────
  if (details.actionId == 'SNOOZE_5') {
    try {
      if (details.payload != null) {
        final parts = details.payload!.split(':');
        if (parts.length >= 3) {
          final rawId = int.tryParse(parts[0]) ?? 0;
          final baseId = _calcBaseId(rawId);

          // Cancel all remaining slots for this medicine
          for (int i = 0; i <= 5; i++) {
            await plugin.cancel(baseId + i);
          }

          final medicineName = parts[1];
          final dose = parts[2];
          final snoozeTime = DateTime.now().add(const Duration(minutes: 5));

          await Hive.initFlutter();
          final box = await Hive.openBox('medicines');
          await box.put('snooze_medicine', medicineName);
          await box.put('snooze_dose', dose);
          await box.put('snooze_raw_id', rawId);
          await box.put('snooze_hour', snoozeTime.hour);
          await box.put('snooze_minute', snoozeTime.minute);
        }
      }
    } catch (e) {
      // ignore in background
    }
  }
}

// ─────────────────────────────────────────────────────────
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Callback to notify the UI of real-time notification actions
  VoidCallback? onNotificationActionTapped;

  // Change channel ID whenever button labels change (Android caches them)
  static const String _channelId = 'medicine_alarm_v6_english';
  static const String _channelName = 'Medicine Alarm';

  // ── INIT ────────────────────────────────────────────────
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onForegroundAction,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Delete old channels so cached Urdu labels are cleared
    for (final oldId in [
      'medicine_alarm_v4',
      'medicine_alarm_v5_english',
      'medicine_reminder_channel_id',
      'medicine_reminder_channel_v2',
      'medicine_reminder_english_v3',
    ]) {
      await androidPlugin?.deleteNotificationChannel(oldId);
    }

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Medicine alarm notifications',
        importance: Importance.max,
        sound: UriAndroidNotificationSound(
            'content://settings/system/alarm_alert'),
        enableVibration: true,
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );

    await androidPlugin?.requestNotificationsPermission();

    // Re-schedule all medicines so they get fresh English-label notifications
    await _rescheduleAllFromStorage();

    // Process any pending snooze requests saved while app was killed
    await _processPendingSnooze();
  }

  // ── RESCHEDULE ALL ──────────────────────────────────────
  Future<void> _rescheduleAllFromStorage() async {
    // Wipe ALL pending notifications first — this clears any old notifications
    // that may have been scheduled with the wrong payload format (old versions
    // stored the pre-multiplied baseId in the payload instead of the rawId).
    await _notifications.cancelAll();

    final medicines = StorageService.getAllMedicines();
    for (final med in medicines) {
      if (med.taken) continue; // skip already-taken medicines

      final rawId = med.notificationId != 0
          ? med.notificationId
          : _stableId(med.name, med.hour, med.minute);

      await scheduleMedicineReminder(
        id: rawId,
        medicineName: med.name,
        dose: med.dose,
        hour: med.hour,
        minute: med.minute,
      );
    }
  }

  // ── PROCESS SNOOZE SAVED BY BACKGROUND HANDLER ──────────
  Future<void> _processPendingSnooze() async {
    try {
      final box = await Hive.openBox('medicines');
      final snoozeMed = box.get('snooze_medicine');
      if (snoozeMed == null) return;

      final dose = box.get('snooze_dose', defaultValue: '') as String;
      final rawId = box.get('snooze_raw_id', defaultValue: 0) as int;
      final hour = box.get('snooze_hour', defaultValue: -1) as int;
      final minute = box.get('snooze_minute', defaultValue: -1) as int;

      if (hour < 0) return;

      // Clear snooze data
      await box.delete('snooze_medicine');
      await box.delete('snooze_dose');
      await box.delete('snooze_raw_id');
      await box.delete('snooze_hour');
      await box.delete('snooze_minute');

      // Schedule a single snooze reminder
      await _scheduleSnoozeReminder(
        rawId: rawId,
        medicineName: snoozeMed as String,
        dose: dose,
        hour: hour,
        minute: minute,
      );
    } catch (_) {}
  }

  // ── FOREGROUND ACTION HANDLER ────────────────────────────
  void _onForegroundAction(NotificationResponse details) async {
    if (details.payload == null) return;
    final parts = details.payload!.split(':');
    if (parts.length < 2) return;

    final rawId = int.tryParse(parts[0]) ?? 0;
    final medicineName = parts[1];
    final dose = parts.length >= 3 ? parts[2] : '';

    if (details.actionId == 'MEDICINE_DONE') {
      // Cancel ALL 6 slots
      await cancelNotification(rawId);

      // Mark taken in storage
      final box = Hive.box('medicines');
      final List pending =
          List.from(box.get('pending_taken', defaultValue: []) as List);
      final name = medicineName.toLowerCase().trim();
      if (!pending.contains(name)) {
        pending.add(name);
        box.put('pending_taken', pending);
      }

      final List cancelledBases =
          List.from(box.get('cancelled_bases', defaultValue: []) as List);
      if (!cancelledBases.contains(rawId)) {
        cancelledBases.add(rawId);
        box.put('cancelled_bases', cancelledBases);
      }

      // Trigger callback to refresh UI instantly
      if (onNotificationActionTapped != null) {
        onNotificationActionTapped!();
      }
    }

    if (details.actionId == 'SNOOZE_5') {
      // Cancel all remaining slots
      await cancelNotification(rawId);

      // Schedule one snooze 5 minutes from now
      final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
      await _scheduleSnoozeReminder(
        rawId: rawId,
        medicineName: medicineName,
        dose: dose,
        hour: snoozeTime.hour,
        minute: snoozeTime.minute,
      );

      // Trigger callback to refresh UI instantly
      if (onNotificationActionTapped != null) {
        onNotificationActionTapped!();
      }
    }
  }

  // ── PUBLIC: SCHEDULE MEDICINE REMINDER ─────────────────
  Future<void> scheduleMedicineReminder({
    required int id,
    required String medicineName,
    required String dose,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
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

    final baseId = _calcBaseId(id);

    // Schedule 6 notifications: at the exact time + every 5 min for 25 min
    for (int i = 0; i <= 5; i++) {
      final fireTime = scheduledDate.add(Duration(minutes: i * 5));
      await _scheduleAlarm(
        notifId: baseId + i,
        rawId: id,
        medicineName: medicineName,
        dose: dose,
        fireTime: fireTime,
        repeatIndex: i,
      );
    }
  }

  // ── SCHEDULE SINGLE SNOOZE REMINDER ─────────────────────
  Future<void> _scheduleSnoozeReminder({
    required int rawId,
    required String medicineName,
    required String dose,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var fireTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (fireTime.isBefore(now)) {
      fireTime = now.add(const Duration(minutes: 1));
    }

    // Use slot 0 for the snooze notification
    final baseId = _calcBaseId(rawId);
    await _scheduleAlarm(
      notifId: baseId, // reuse slot 0
      rawId: rawId,
      medicineName: medicineName,
      dose: dose,
      fireTime: fireTime,
      repeatIndex: 0,
      isSnooze: true,
    );
  }

  // ── INTERNAL: SCHEDULE A SINGLE ALARM ───────────────────
  Future<void> _scheduleAlarm({
    required int notifId,
    required int rawId,
    required String medicineName,
    required String dose,
    required tz.TZDateTime fireTime,
    required int repeatIndex,
    bool isSnooze = false,
  }) async {
    final isFirst = repeatIndex == 0 && !isSnooze;

    final title = isSnooze
        ? '⏰ Snooze Reminder — $medicineName'
        : isFirst
            ? '💊 Time to Take Your Medicine!'
            : '⚠️ Reminder #$repeatIndex — $medicineName';

    final body = isSnooze
        ? '$medicineName · $dose — Snooze time is up!'
        : isFirst
            ? '$medicineName · $dose — Please take now!'
            : 'You have not taken $medicineName ($dose) yet!';

    final bigText = isSnooze
        ? '💊 Medicine: $medicineName\n'
            '📋 Dose: $dose\n\n'
            'Your snooze is up. Please take your medicine now!'
        : isFirst
            ? '💊 Medicine: $medicineName\n'
                '📋 Dose: $dose\n\n'
                'Please take your medicine and tap ✅ Done!'
            : '⚠️ Medicine: $medicineName\n'
                '📋 Dose: $dose\n\n'
                'You haven\'t confirmed taking $medicineName yet.';

    final vibrationPattern =
        Int64List.fromList([0, 500, 200, 500, 200, 800]);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Medicine alarm',
      importance: Importance.max,
      priority: Priority.high,
      sound: const UriAndroidNotificationSound(
          'content://settings/system/alarm_alert'),
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      fullScreenIntent: true,
      autoCancel: false,   // ← keep visible until user acts
      ongoing: false,
      category: AndroidNotificationCategory.alarm,
      color: const Color(0xFFE8A0BF),
      colorized: true,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        bigText,
        contentTitle: '💊 $medicineName · $dose',
        summaryText: 'MediCare Reminder',
      ),
      actions: const [
        AndroidNotificationAction(
          'MEDICINE_DONE',
          _labelMarkDone,
          cancelNotification: true,  // dismiss the tapped notification
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'SNOOZE_5',
          _labelSnooze,
          cancelNotification: true,
          showsUserInterface: false,
        ),
      ],
    );

    await _notifications.zonedSchedule(
      notifId,
      title,
      body,
      fireTime,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // payload: "rawId:medicineName:dose"  ← rawId so cancel works correctly
      payload: '$rawId:$medicineName:$dose',
    );
  }

  // ── PUBLIC: CANCEL ALL SLOTS FOR ONE MEDICINE ───────────
  /// Pass the RAW medicine notificationId (same value stored in Medicine.notificationId).
  Future<void> cancelNotification(int rawId) async {
    final baseId = _calcBaseId(rawId);
    for (int i = 0; i <= 5; i++) {
      await _notifications.cancel(baseId + i);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // ── STABLE ID HELPER ────────────────────────────────────
  static int _stableId(String name, int hour, int minute) {
    return (name.hashCode.abs() + hour * 100 + minute).abs() % 100000;
  }

  Future<void> playTestSound() async {
    await _notifications.show(
      998,
      '🔔 Medicine Reminder',
      'This is how your medicine reminder will sound!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
          sound: UriAndroidNotificationSound(
              'content://settings/system/alarm_alert'),
          playSound: true,
          enableVibration: true,
          autoCancel: true,
        ),
      ),
    );
  }
}
